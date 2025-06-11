from datetime import datetime
import firebase_admin
from firebase_admin import credentials, db
import time

# Initialize Firebase (only once)
cred = credentials.Certificate("serviceAccountKey.json")  # Replace with your file path
firebase_admin.initialize_app(cred, {
    'databaseURL': 'https://alviora-10650-default-rtdb.firebaseio.com'  # Replace with your actual database URL
})

gas_ref = db.reference("gas_sensor")

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

if __name__ == "__main__":
    while True:
        push_mock_gas_data()
        time.sleep(5)
