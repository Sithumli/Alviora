import cv2
import numpy as np
import pyaudio
import wave
import threading
import queue
import time
import firebase_admin
from firebase_admin import credentials, db
import mediapipe as mp
import librosa
from datetime import datetime
import logging
from webrtc_streamer import WebRTCStreamer
import os
from deepface import DeepFace

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

class StreamManager:
    def __init__(self, enable_firebase=True):
        # Initialize Firebase if enabled
        self.firebase_enabled = enable_firebase
        if enable_firebase:
            try:
                if not firebase_admin._apps:
                    # Get the directory where stream_manager.py is located
                    current_dir = os.path.dirname(os.path.abspath(__file__))
                    service_account_path = os.path.join(current_dir, "serviceAccountKey.json")
                    
                    if not os.path.exists(service_account_path):
                        logger.warning(f"Firebase service account key not found at {service_account_path}. Firebase features will be disabled.")
                        self.firebase_enabled = False
                    else:
                        cred = credentials.Certificate(service_account_path)
                        firebase_admin.initialize_app(cred, {
                            'databaseURL': 'https://alviora-10650-default-rtdb.firebaseio.com'
                        })
                        logger.info("Firebase initialized successfully")
            except Exception as e:
                logger.error(f"Failed to initialize Firebase: {str(e)}")
                self.firebase_enabled = False
        
        # Firebase references
        self.alert_ref = None
        self.stream_ref = None
        self.emotion_ref = None
        if self.firebase_enabled:
            self.alert_ref = db.reference("alerts")
            self.stream_ref = db.reference("stream_status")
            self.emotion_ref = db.reference("emotion_status")
        
        # Video capture settings
        self.camera = None
        self.frame_queue = queue.Queue(maxsize=30)
        self.is_streaming = False
        
        # Audio settings
        self.audio_queue = queue.Queue(maxsize=100)
        self.CHUNK = 1024
        self.FORMAT = pyaudio.paFloat32
        self.CHANNELS = 1
        self.RATE = 44100
        self.audio = pyaudio.PyAudio()
        
        # Detection settings
        self.mp_pose = mp.solutions.pose
        self.pose = self.mp_pose.Pose()
        self.cough_threshold = 20  # Number of coughs to trigger emergency
        self.cough_count = 0
        self.cough_window = 300  # 5 minutes window for cough counting
        self.cough_timestamps = []
        
        # Fall detection settings
        self.last_fall_alert_time = 0
        self.fall_alert_cooldown = 30  # 30 seconds cooldown between fall alerts
        self.confirmed_fall = False

        # Emotion detection settings
        self.last_emotion = None
        self.emotion_confidence_threshold = 0.7
        self.emotion_alert_cooldown = 60  # 60 seconds cooldown between emotion alerts
        self.last_emotion_alert_time = 0
        self.emotion_window = []
        self.emotion_window_size = 10  # Track last 10 emotions for stability
        
        # WebRTC streamer
        try:
            self.webrtc_streamer = WebRTCStreamer(self.frame_queue)
            logger.info("WebRTC streamer initialized successfully")
        except Exception as e:
            logger.error(f"Failed to initialize WebRTC streamer: {str(e)}")
            raise
        
        # Initialize streams
        self.init_video()
        self.init_audio()
    
    def init_video(self):
        """Initialize video capture"""
        try:
            # Try to open the default camera (usually webcam)
            self.camera = cv2.VideoCapture(0)
            if not self.camera.isOpened():
                raise Exception("Failed to open camera")
            
            # Set camera properties
            self.camera.set(cv2.CAP_PROP_FRAME_WIDTH, 640)
            self.camera.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)
            self.camera.set(cv2.CAP_PROP_FPS, 30)
            
            logger.info("Video capture initialized successfully")
        except Exception as e:
            logger.error(f"Failed to initialize video: {str(e)}")
            raise
    
    def init_audio(self):
        """Initialize audio capture"""
        try:
            self.stream = self.audio.open(
                format=self.FORMAT,
                channels=self.CHANNELS,
                rate=self.RATE,
                input=True,
                frames_per_buffer=self.CHUNK
            )
            logger.info("Audio capture initialized successfully")
        except Exception as e:
            logger.error(f"Failed to initialize audio: {str(e)}")
            raise
    
    def process_audio(self):
        """Process audio chunks for cough detection"""
        while self.is_streaming:
            try:
                data = self.stream.read(self.CHUNK, exception_on_overflow=False)
                audio_data = np.frombuffer(data, dtype=np.float32)
                
                # Simple energy-based cough detection
                energy = np.mean(np.abs(audio_data))
                if energy > 0.1:  # Threshold for cough detection
                    current_time = time.time()
                    self.cough_timestamps.append(current_time)
                    
                    # Remove coughs older than the window
                    self.cough_timestamps = [t for t in self.cough_timestamps 
                                          if current_time - t <= self.cough_window]
                    
                    self.cough_count = len(self.cough_timestamps)
                    
                    if self.cough_count >= self.cough_threshold:
                        self.send_emergency_alert("cough", {
                            "count": self.cough_count,
                            "window_minutes": self.cough_window / 60
                        })
                
            except Exception as e:
                logger.error(f"Error processing audio: {str(e)}")
    
    def process_video(self):
        """Process video frames for fall detection and emotion detection"""
        fall_detection_window = []  # Store recent pose states
        window_size = 15  # Increased window size for better temporal analysis
        fall_threshold = 0.4  # Increased threshold for more certainty
        min_confidence = 0.8  # Increased minimum confidence
        consecutive_frames_required = 8  # More frames required for confirmation
        
        # Fall detection parameters
        max_standing_height = 0.7  # Maximum height for standing position
        min_lying_height = 0.3  # Minimum height for lying position
        max_vertical_angle = 30  # Maximum angle (in degrees) for standing
        
        while self.is_streaming:
            try:
                ret, frame = self.camera.read()
                if not ret:
                    continue
                
                # Emotion Detection
                try:
                    result = DeepFace.analyze(frame, 
                                           actions=['emotion'],
                                           enforce_detection=False,
                                           silent=True)
                    
                    if result:
                        emotion = result[0]['dominant_emotion']
                        emotion_scores = result[0]['emotion']
                        confidence = emotion_scores[emotion] / 100.0  # Convert to 0-1 scale
                        
                        # Add to emotion window for stability
                        self.emotion_window.append((emotion, confidence))
                        if len(self.emotion_window) > self.emotion_window_size:
                            self.emotion_window.pop(0)
                        
                        # Calculate most frequent emotion in window with high confidence
                        high_conf_emotions = [(e, c) for e, c in self.emotion_window if c > self.emotion_confidence_threshold]
                        if high_conf_emotions:
                            emotion_counts = {}
                            for e, _ in high_conf_emotions:
                                emotion_counts[e] = emotion_counts.get(e, 0) + 1
                            stable_emotion = max(emotion_counts.items(), key=lambda x: x[1])[0]
                            
                            # Check if emotion has changed significantly
                            if stable_emotion != self.last_emotion:
                                self.last_emotion = stable_emotion
                                
                                # Send real-time emotion update
                                self.send_emotion_update({
                                    "emotion": stable_emotion,
                                    "confidence": confidence
                                })
                        
                        # Draw emotion on frame
                        (text_width, text_height), _ = cv2.getTextSize(f"{emotion}: {confidence:.2f}", cv2.FONT_HERSHEY_SIMPLEX, 0.9, 2)
                        cv2.rectangle(frame, (10, 30 - text_height - 5), (10 + text_width, 30 + 5), (0, 0, 0), -1)
                        cv2.putText(frame, f"{emotion}: {confidence:.2f}", 
                                  (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 
                                  0.9, (255, 255, 255), 2)
                except Exception as e:
                    logger.debug(f"No face detected or error in emotion detection: {str(e)}")

                # Convert to RGB for MediaPipe
                rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
                results = self.pose.process(rgb_frame)
                
                if results.pose_landmarks:
                    landmarks = results.pose_landmarks.landmark
                    
                    # Get key points for fall detection
                    nose = landmarks[0]
                    left_shoulder = landmarks[11]
                    right_shoulder = landmarks[12]
                    left_hip = landmarks[23]
                    right_hip = landmarks[24]
                    left_ankle = landmarks[27]
                    right_ankle = landmarks[28]
                    left_knee = landmarks[25]
                    right_knee = landmarks[26]
                    
                    # Calculate pose metrics
                    shoulder_height = (left_shoulder.y + right_shoulder.y) / 2
                    hip_height = (left_hip.y + right_hip.y) / 2
                    ankle_height = (left_ankle.y + right_ankle.y) / 2
                    knee_height = (left_knee.y + right_knee.y) / 2
                    
                    # Calculate body orientation and angles
                    body_vertical = abs(shoulder_height - hip_height)
                    body_horizontal = abs(hip_height - ankle_height)
                    
                    # Calculate body angle
                    body_angle = np.degrees(np.arctan2(
                        (shoulder_height - hip_height),
                        (left_shoulder.x - left_hip.x)
                    ))
                    
                    # Calculate confidence scores
                    confidence_scores = [
                        nose.visibility,
                        left_shoulder.visibility,
                        right_shoulder.visibility,
                        left_hip.visibility,
                        right_hip.visibility,
                        left_knee.visibility,
                        right_knee.visibility
                    ]
                    avg_confidence = sum(confidence_scores) / len(confidence_scores)
                    
                    # Determine if person is in a lying position
                    is_lying = False
                    if avg_confidence > min_confidence:
                        # Check multiple conditions for fall detection
                        height_conditions = (
                            hip_height > max_standing_height or  # Person is too low
                            abs(shoulder_height - hip_height) < 0.1  # Body is horizontal
                        )
                        
                        angle_conditions = (
                            abs(body_angle) > max_vertical_angle or  # Body is tilted
                            body_horizontal > body_vertical  # Body is more horizontal than vertical
                        )
                        
                        # Check for sudden height change
                        height_ratio = hip_height / shoulder_height
                        sudden_fall = height_ratio > 1.5  # Sudden increase in height ratio
                        
                        # Check for knee bending (common in falls)
                        knee_bend = abs(knee_height - hip_height) < 0.1
                        
                        # Combine all conditions
                        is_lying = (
                            (height_conditions and angle_conditions) or
                            (sudden_fall and knee_bend) or
                            (body_horizontal > 1.5 * body_vertical and height_conditions)
                        )
                    
                    # Add current state to window
                    fall_detection_window.append(is_lying)
                    if len(fall_detection_window) > window_size:
                        fall_detection_window.pop(0)
                    
                    # Check for fall if we have enough frames
                    if len(fall_detection_window) == window_size:
                        fall_probability = sum(fall_detection_window) / window_size
                        current_time = time.time()
                        
                        # Check for confirmed fall
                        if fall_probability > fall_threshold:
                            if not self.confirmed_fall:
                                # Count consecutive frames with high fall probability
                                consecutive_frames = sum(1 for x in fall_detection_window[-consecutive_frames_required:] if x)
                                if consecutive_frames >= consecutive_frames_required:
                                    self.confirmed_fall = True
                                    # Only send alert if cooldown period has passed
                                    if current_time - self.last_fall_alert_time > self.fall_alert_cooldown:
                                        self.send_emergency_alert("fall", {
                                            "confidence": float(fall_probability),
                                            "metrics": {
                                                "body_vertical": float(body_vertical),
                                                "body_horizontal": float(body_horizontal),
                                                "height_ratio": float(height_ratio),
                                                "body_angle": float(body_angle),
                                                "pose_confidence": float(avg_confidence),
                                                "knee_bend": bool(knee_bend)
                                            }
                                        })
                                        self.last_fall_alert_time = current_time
                        else:
                            # Reset confirmed fall state if person is standing
                            self.confirmed_fall = False
                
                # Draw pose landmarks
                mp.solutions.drawing_utils.draw_landmarks(
                    frame, results.pose_landmarks, self.mp_pose.POSE_CONNECTIONS)
                
                # Add text overlay with detection status
                status_text = "Testing Mode - Local Webcam"
                if len(fall_detection_window) > 0:
                    fall_prob = sum(fall_detection_window) / len(fall_detection_window)
                    status_text += f" - Fall Probability: {fall_prob:.2f}"
                    if self.confirmed_fall:
                        status_text += " (FALL CONFIRMED)"
                cv2.putText(frame, status_text, (10, 70),
                           cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 255, 0), 2)
                
                # Put frame in queue for streaming
                if not self.frame_queue.full():
                    self.frame_queue.put(frame)
                
            except Exception as e:
                logger.error(f"Error processing video: {str(e)}")
    
    def send_emergency_alert(self, alert_type, details):
        """Send emergency alert to Firebase if enabled"""
        if not self.firebase_enabled:
            logger.warning(f"Firebase disabled. Alert not sent: {alert_type}")
            return
            
        try:
            alert_data = {
                "type": alert_type,
                "timestamp": datetime.now().isoformat(),
                "details": details,
                "status": "active",
                "severity": "high",
                "action_required": True,
                "actions": {
                    "call_emergency": True,
                    "dismiss": True,
                    "view_360": True
                },
                "emergency_number": "1990",
                "sound": "alert_sound.mp3"
            }

            if alert_type == "cough":
                alert_data.update({
                    "title": "Excessive Coughing Detected",
                    "message": f"Patient has coughed {details['count']} times in {details['window_minutes']:.1f} minutes"
                })
            elif alert_type == "fall":
                alert_data.update({
                    "title": "Fall Detected",
                    "message": f"Fall detected with confidence {details['confidence']:.2f}"
                })

            self.alert_ref.push(alert_data)
            logger.warning(f"Emergency alert sent: {alert_type}")

        except Exception as e:
            logger.error(f"Failed to send alert: {str(e)}")
    
    def send_emotion_update(self, emotion_data):
        """Send real-time emotion data to Firebase."""
        if not self.firebase_enabled:
            return
            
        try:
            update_data = {
                "emotion": emotion_data.get("emotion"),
                "confidence": emotion_data.get("confidence"),
                "last_update": datetime.now().isoformat()
            }
            self.emotion_ref.set(update_data)
            logger.info(f"Emotion status updated: {emotion_data.get('emotion')}")
        except Exception as e:
            logger.error(f"Failed to send emotion update: {str(e)}")

    def start_streaming(self):
        """Start both video and audio streaming"""
        self.is_streaming = True

        # Start processing threads
        video_thread = threading.Thread(target=self.process_video)
        audio_thread = threading.Thread(target=self.process_audio)

        video_thread.start()
        audio_thread.start()

        # Start WebRTC streamer in a separate thread
        webrtc_thread = threading.Thread(target=self.webrtc_streamer.run)
        webrtc_thread.start()

        logger.info("Streaming started")

        # Track last known state to avoid unnecessary Firebase writes
        last_cough_count = -1
        last_update_time = 0

        try:
            while self.is_streaming:
                if self.firebase_enabled:
                    current_time = time.time()
                    changed = self.cough_count != last_cough_count

                    if changed or (current_time - last_update_time > 30):  # also update every 30 sec minimum
                        last_cough_count = self.cough_count
                        last_update_time = current_time

                        self.stream_ref.set({
                            "status": "active",
                            "last_update": datetime.now().isoformat(),
                            "cough_count": self.cough_count,
                            "stream_url": "http://localhost:8080"
                        })
                        logger.info("Stream status updated to Firebase")

                time.sleep(1)
        except KeyboardInterrupt:
            self.stop_streaming()

    
    def stop_streaming(self):
        """Stop all streams and cleanup"""
        self.is_streaming = False
        
        if self.camera:
            self.camera.release()
        
        if self.stream:
            self.stream.stop_stream()
            self.stream.close()
        
        if self.audio:
            self.audio.terminate()
        
        cv2.destroyAllWindows()
        logger.info("Streaming stopped")

if __name__ == "__main__":
    try:
        manager = StreamManager()
        manager.start_streaming()
    except Exception as e:
        logger.error(f"Fatal error: {str(e)}")
        if 'manager' in locals():
            manager.stop_streaming() 