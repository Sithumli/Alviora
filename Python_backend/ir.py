import time
from datetime import datetime
import random
import firebase_admin
from firebase_admin import credentials, db

cred = credentials.Certificate("serviceAccountKey.json")
firebase_admin.initialize_app(cred, {
    'databaseURL': 'https://alviora-10650-default-rtdb.firebaseio.com'
})

sensor_ref = db.reference("sensor_data/ir_motion")
alert_ref = db.reference("alerts")

NO_MOVEMENT_LIMIT_DAY = 600
NO_MOVEMENT_LIMIT_NIGHT = 7200
SLEEP_START = 22
SLEEP_END = 6

last_motion_time = time.time()

def is_sleep_time():
    current_hour = datetime.now().hour
    return current_hour >= SLEEP_START or current_hour < SLEEP_END

def read_ir():
    if is_sleep_time():
        motion = random.random() < 0.2
    else:
        motion = random.random() < 0.7
    return {"motion_detected": motion}

def push_to_firebase(data):
    if data["emergency"]:
        alert_data = {
            "type": "no_movement",
            "timestamp": datetime.now().isoformat(),
            "details": {
                "no_motion_seconds": data["no_motion_seconds"],
                "is_sleep_time": is_sleep_time()
            },
            "status": "active",
            "severity": "high",
            "action_required": True,
            "actions": {
                "call_emergency": True,
                "dismiss": True,
                "view_360": True
            },
            "emergency_number": "1990",
            "title": "No Movement Detected",
            "message": f"No movement detected for {data['no_motion_seconds']} seconds",
            "sound": "alert_sound.mp3"
        }
        alert_ref.push(alert_data)
    sensor_ref.push(data)

while True:
    motion = read_ir()["motion_detected"]
    if motion:
        last_motion_time = time.time()
    elapsed = time.time() - last_motion_time
    no_movement_limit = NO_MOVEMENT_LIMIT_NIGHT if is_sleep_time() else NO_MOVEMENT_LIMIT_DAY
    emergency = elapsed > no_movement_limit
    data = {
        "motion_detected": motion,
        "no_motion_seconds": int(elapsed),
        "emergency": emergency,
        "timestamp": datetime.now().isoformat()
    }
    push_to_firebase(data)
    print(f"[{datetime.now().isoformat()}] Motion: {motion}, No movement: {int(elapsed)}s, Emergency: {emergency}")
    if emergency:
        print("🚨 EMERGENCY: No movement detected for too long!")
    time.sleep(5)