import logging
import threading
import time
import firebase_admin
from firebase_admin import credentials, db
import cv2
from datetime import datetime
import os

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('alviora.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

# Initialize Firebase - single initialization point
try:
    cred = credentials.Certificate("serviceAccountKey.json")
    firebase_app = firebase_admin.initialize_app(cred, {
        'databaseURL': 'https://alviora-10650-default-rtdb.firebaseio.com'
    })
    logger.info("Firebase initialized successfully")
except ValueError as e:
    logger.warning(f"Firebase already initialized: {str(e)}")
    firebase_app = firebase_admin.get_app()

# Status reference in Firebase
status_ref = db.reference("system_status")

class ServiceManager:
    def __init__(self):
        self.services = {}
        self.running = True
        self.status = {
            "last_update": datetime.now().isoformat(),
            "services": {},
            "system_health": "healthy"
        }
        self.firebase_app = firebase_app  # Store the Firebase app instance

    def start_service(self, name, target_func):
        """Start a service in a separate thread"""
        thread = threading.Thread(target=self._service_wrapper, args=(name, target_func))
        thread.daemon = True
        thread.start()
        self.services[name] = thread
        logger.info(f"Started service: {name}")

    def _service_wrapper(self, name, target_func):
        """Wrapper to handle service crashes and logging"""
        while self.running:
            try:
                target_func()
            except Exception as e:
                logger.error(f"Service {name} crashed: {str(e)}")
                self.status["services"][name] = "error"
                time.sleep(5)  # Wait before restarting
            finally:
                self.status["services"][name] = "running"

    def update_status(self):
        """Update system status in Firebase"""
        while self.running:
            try:
                self.status["last_update"] = datetime.now().isoformat()
                status_ref.set(self.status)
                time.sleep(30)  # Update every 30 seconds
            except Exception as e:
                logger.error(f"Failed to update status: {str(e)}")

    def start(self):
        """Start all services"""
        # Start status updater
        threading.Thread(target=self.update_status, daemon=True).start()

        # Import and start your services
        from fall_detection import run_fall_detection
        from cough_detection import run_cough_detection
        from dht22 import run_dht22
        from gas import run_gas_sensor
        from ir import run_ir_sensor

        # Start each service
        self.start_service("fall_detection", run_fall_detection)
        self.start_service("cough_detection", run_cough_detection)
        self.start_service("dht22", run_dht22)
        self.start_service("gas_sensor", run_gas_sensor)
        self.start_service("ir_sensor", run_ir_sensor)

        try:
            while True:
                time.sleep(1)
        except KeyboardInterrupt:
            self.running = False
            logger.info("Shutting down services...")

if __name__ == "__main__":
    manager = ServiceManager()
    manager.start() 