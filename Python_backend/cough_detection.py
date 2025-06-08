import moviepy as mp
import numpy as np
import librosa
from scipy.ndimage import label
import firebase_admin
from firebase_admin import credentials, db
from datetime import datetime
import os

# Initialize Firebase Realtime Database
def initialize_firebase():
    if not firebase_admin._apps:
        cred = credentials.Certificate("serviceAccountKey.json")
        # Replace URL with your Realtime Database URL
        firebase_admin.initialize_app(cred, {
            'databaseURL': 'https://alviora-10650-default-rtdb.firebaseio.com'
        })

def extract_audio_from_video(video_path, audio_path='extracted_audio.wav'):
    clip = mp.VideoFileClip(video_path)
    clip.audio.write_audiofile(audio_path, codec='pcm_s16le')
    clip.close()
    return audio_path

def detect_coughs(audio_path, sr=22050, frame_length=2048, hop_length=512, 
                 energy_threshold=0.02, min_cough_duration=0.1, max_cough_duration=1.5):
    y, sr = librosa.load(audio_path, sr=sr)
    energy = np.array([
        sum(abs(y[i:i+frame_length]**2))
        for i in range(0, len(y), hop_length)
    ])
    energy = librosa.util.normalize(energy)
    cough_frames = energy > energy_threshold
    labeled_array, num_features = label(cough_frames)
    cough_count = 0
    cough_timestamps = []
    for i in range(1, num_features + 1):
        indices = np.where(labeled_array == i)[0]
        start_frame = indices[0]
        end_frame = indices[-1]
        start_time = start_frame * hop_length / sr
        end_time = end_frame * hop_length / sr
        duration = end_time - start_time
        if min_cough_duration <= duration <= max_cough_duration:
            cough_count += 1
            cough_timestamps.append((start_time, end_time))
    return cough_count, cough_timestamps

def upload_to_realtime_db(video_path, cough_count, cough_timestamps):
    try:
        ref = db.reference('cough_analyses')
        # Convert tuples to dicts
        timestamps_dicts = [{'start': s, 'end': e} for s, e in cough_timestamps]
        data = {
            'video_filename': os.path.basename(video_path),
            'cough_count': cough_count,
            'cough_timestamps': timestamps_dicts,
            'analysis_date': datetime.now().isoformat(),
            'status': 'completed'
        }
        # Push creates a new unique key automatically
        new_ref = ref.push(data)
        print(f"Uploaded analysis to Realtime Database with key: {new_ref.key}")
    except Exception as e:
        print(f"Realtime Database upload error: {e}")

if __name__ == '__main__':
    initialize_firebase()
    
    video_path = 'cough_test/3.mp4'
    try:
        audio_path = extract_audio_from_video(video_path)
        cough_count, cough_timestamps = detect_coughs(audio_path)
        print(f"Detected {cough_count} coughs")
        print("Cough timestamps (seconds):", cough_timestamps)
        upload_to_realtime_db(video_path, cough_count, cough_timestamps)
    except Exception as e:
        print(f"Error processing video: {str(e)}")
    finally:
        if os.path.exists('extracted_audio.wav'):
            os.remove('extracted_audio.wav')
