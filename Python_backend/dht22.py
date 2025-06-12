from datetime import datetime
import firebase_admin
from firebase_admin import credentials, db
import time

try:
    firebase_app = firebase_admin.get_app()
except ValueError:
    cred = credentials.Certificate("serviceAccountKey.json")
    firebase_app = firebase_admin.initialize_app(cred, {
        'databaseURL': 'https://alviora-10650-default-rtdb.firebaseio.com'
    })

dht_ref = db.reference("dht22_sensor")
alert_ref = db.reference("alerts")

last_alert_time = 0
ALERT_COOLDOWN = 300

def push_mock_dht22_data():
    global last_alert_time
    temperature = 36.5
    humidity = 18.0

    temp_threshold_high = 35
    temp_threshold_low = 20
    humidity_threshold_low = 20
    humidity_threshold_high = 80

    emergency = (temperature > temp_threshold_high or 
                temperature < temp_threshold_low or 
                humidity < humidity_threshold_low or 
                humidity > humidity_threshold_high)

    data = {
        "temperature_c": temperature,
        "humidity": humidity,
        "emergency": emergency,
        "timestamp": datetime.now().isoformat()
    }
    dht_ref.push(data)
    print("Pushed mock DHT22 data:", data)

    if emergency and (time.time() - last_alert_time) >= ALERT_COOLDOWN:
        last_alert_time = time.time()
        alert_data = {
            "type": "environmental",
            "timestamp": datetime.now().isoformat(),
            "details": {
                "temperature": temperature,
                "humidity": humidity,
                "temperature_threshold_high": temp_threshold_high,
                "temperature_threshold_low": temp_threshold_low,
                "humidity_threshold_high": humidity_threshold_high,
                "humidity_threshold_low": humidity_threshold_low
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
            "title": "Environmental Alert",
            "message": f"Unsafe conditions! Temp: {temperature}°C, Humidity: {humidity}%",
            "sound": "alert_sound.mp3"
        }
        alert_ref.push(alert_data)
        print("🚨 EMERGENCY: Environmental conditions outside safe range!")

def run_dht22():
    while True:
        push_mock_dht22_data()
        time.sleep(5)

if __name__ == "__main__":
    run_dht22()