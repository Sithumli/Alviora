
# Alviora Project

Alviora is an AI-powered eldercare system that integrates:
- 📱 **Phone interface** for family members and caregivers
- 💻 **Tablet interface** for eldercare robots
- 🧠 **Python backend** for processing (e.g. WebRTC, emotion detection)

---

## 📂 Project structure

```
Alviora/
├── Alviora_phone_app/      # Flutter app for the caregiver's phone
├── Alviora_tablet_app/     # Flutter app for the eldercare tablet
├── Python_backend/         # Python backend for services (e.g. video, emotion detection, IOT backend)
└── .idea/                  # IDE config (can be ignored)
```

---

## 🚀 Getting started

### 📱 Phone app
```bash
cd Alviora_phone_app
flutter pub get
flutter run
```

---

### 💻 Tablet app
```bash
cd Alviora_tablet_app
flutter pub get
flutter run
```

---

### 🧠 Python Backend
```bash
# Navigate to the backend directory
cd Python_backend

# Create a virtual environment (recommended)
python -m venv venv

# Activate the virtual environment
# For Windows:
.\venv\Scripts\activate
# For Linux/Mac:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Start the backend
python main.py
```

## ⚙ Prerequisites

- [Flutter](https://flutter.dev/docs/get-started/install) (for phone and tablet apps)
- [Python 3.x](https://www.python.org/downloads/) (for backend)
- Any required Python packages (check `requirements.txt` or install manually)

---
