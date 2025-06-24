
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

### 🧠 Python backend
```bash
cd Python_backend
# Example command to start your backend server
python app.py
```

*(Replace `app.py` with your actual entry point if different.)*

---

## ⚙ Prerequisites

- [Flutter](https://flutter.dev/docs/get-started/install) (for phone and tablet apps)
- [Python 3.x](https://www.python.org/downloads/) (for backend)
- Any required Python packages (check `requirements.txt` or install manually)

---
