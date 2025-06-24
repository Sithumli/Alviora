import cv2
import mediapipe as mp
import time
import firebase_admin
from firebase_admin import credentials, db

# Initialize Firebase
cred = credentials.Certificate("serviceAccountKey.json")  # Replace with your file path
firebase_admin.initialize_app(cred, {
    'databaseURL': 'https://alviora-10650-default-rtdb.firebaseio.com'  # Replace with your actual database URL
})

fall_ref = db.reference("fall_alerts")

mp_pose = mp.solutions.pose
pose = mp_pose.Pose()

video_path = "fall_test/2.mp4"
cap = cv2.VideoCapture(video_path)

prev_nose_y = None
fall_detected = False
fall_threshold = 0.1

while cap.isOpened():
    ret, frame = cap.read()
    if not ret:
        print("End of video or can't read the frame.")
        break

    image_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    results = pose.process(image_rgb)

    if results.pose_landmarks:
        landmarks = results.pose_landmarks.landmark
        nose_y = landmarks[0].y

        if prev_nose_y is not None:
            if nose_y - prev_nose_y > fall_threshold:
                if not fall_detected:
                    fall_detected = True
                    frame_number = int(cap.get(cv2.CAP_PROP_POS_FRAMES))
                    timestamp = cap.get(cv2.CAP_PROP_POS_MSEC) / 1000

                    print(f"⚠️ Fall detected at frame {frame_number}, time {timestamp:.2f}s")

                    # Send fall event to Firebase
                    fall_ref.push({
                        "frame": frame_number,
                        "time": timestamp,
                        "detected": True,
                        "timestamp_unix": int(time.time())
                    })
            else:
                fall_detected = False

        prev_nose_y = nose_y

        mp.solutions.drawing_utils.draw_landmarks(
            frame, results.pose_landmarks, mp_pose.POSE_CONNECTIONS)

    if fall_detected:
        cv2.putText(frame, "🚨 FALL DETECTED!", (50, 50),
                    cv2.FONT_HERSHEY_SIMPLEX, 1.5, (0, 0, 255), 3)

    cv2.imshow("Fall Detection on Video", frame)
    if cv2.waitKey(30) & 0xFF == 27:
        break

cap.release()
cv2.destroyAllWindows()
