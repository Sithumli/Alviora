from datetime import datetime
import firebase_admin
from firebase_admin import credentials, db
import time

# Initialize Firebase (only once)
cred = credentials.Certificate("serviceAccountKey.json")
firebase_admin.initialize_app(cred, {
    'databaseURL': 'https://alviora-10650-default-rtdb.firebaseio.com'
})

gas_ref = db.reference("gas_sensor")
alert_ref = db.reference("alerts")

def push_mock_gas_data():
    # Hardcoded mock values
    mq2_val = 45.0    # Example: 45% gas detected
    mq135_val = 70.0  # Example: 70% gas detected

    # Thresholds
    mq2_threshold = 50.0
    mq135_threshold = 60.0

    emergency = mq2_val > mq2_threshold or mq135_val > mq135_threshold

    data = {
        "mq2": mq2_val,
        "mq135": mq135_val,
        "emergency": emergency,
        "timestamp": datetime.now().isoformat()
    }
    gas_ref.push(data)
    print("Pushed mock gas data:", data)

    if emergency:
        alert_data = {
            "type": "gas_leak",
            "timestamp": datetime.now().isoformat(),
            "details": {
                "mq2_level": mq2_val,
                "mq135_level": mq135_val,
                "mq2_threshold": mq2_threshold,
                "mq135_threshold": mq135_threshold
            },
            "status": "active",
            "severity": "critical",
            "action_required": True,
            "actions": {
                "call_emergency": True,
                "dismiss": True,
                "view_360": True
            },
            "emergency_number": "1990",
            "title": "Gas Leak Detected",
            "message": f"Dangerous gas levels detected (MQ2: {mq2_val}%, MQ135: {mq135_val}%)",
            "sound": "alert_sound.mp3"
        }
        alert_ref.push(alert_data)
        print("🚨 EMERGENCY ALERT: Gas leak detected!")

if __name__ == "__main__":
    while True:
        push_mock_gas_data()
        time.sleep(5)