import time
from datetime import datetime
import random
import firebase_admin
from firebase_admin import credentials, db

# Firebase setup - update with your own
cred = credentials.Certificate("serviceAccountKey.json")  # Replace with your file path
firebase_admin.initialize_app(cred, {
    'databaseURL': 'https://alviora-10650-default-rtdb.firebaseio.com'  # Replace with your actual database URL
})

# Reference to your Firebase DB path
sensor_ref = db.reference("sensor_data/ir_motion")

NO_MOVEMENT_LIMIT_DAY = 600        # 10 minutes
NO_MOVEMENT_LIMIT_NIGHT = 7200     # 2 hours

SLEEP_START = 22  # 10 PM
SLEEP_END = 6     # 6 AM

last_motion_time = time.time()

def is_sleep_time():
    current_hour = datetime.now().hour
    return current_hour >= SLEEP_START or current_hour < SLEEP_END

def read_ir():
    # Mock: simulate motion randomly with different probabilities day/night
    if is_sleep_time():
        motion = random.random() < 0.2
    else:
        motion = random.random() < 0.7
    return {"motion_detected": motion}

def push_to_firebase(data):
    sensor_ref.push(data)

while True:
    motion = read_ir()["motion_detected"]

    if motion:
        last_motion_time = time.time()

    elapsed = time.time() - last_motion_time

    if is_sleep_time():
        no_movement_limit = NO_MOVEMENT_LIMIT_NIGHT
    else:
        no_movement_limit = NO_MOVEMENT_LIMIT_DAY

    emergency = elapsed > no_movement_limit

    timestamp = datetime.now().isoformat()

    data = {
        "motion_detected": motion,
        "no_motion_seconds": int(elapsed),
        "emergency": emergency,
        "timestamp": timestamp
    }

    push_to_firebase(data)

    print(f"[{timestamp}] Motion: {motion}, No movement: {int(elapsed)}s, Emergency: {emergency}")

    if emergency:
        print("🚨 EMERGENCY: No movement detected for too long!")

    time.sleep(5)
