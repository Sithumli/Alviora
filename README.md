# Alviora Project Setup Guide

## Repository
```bash
https://github.com/Sithumli/Alviora.git
```

## Prerequisites

Before you begin, ensure you have the following installed:
- [Git](https://git-scm.com/downloads)
- [Flutter](https://docs.flutter.dev/get-started/install) (latest stable version)
- [Python](https://www.python.org/downloads/) (3.8 or higher)
- [Android Studio](https://developer.android.com/studio) (for Android development)
- [Xcode](https://developer.apple.com/xcode/) (for iOS development, macOS only)
- [VS Code](https://code.visualstudio.com/) (recommended IDE)

## Project Structure
```
Alviora/
├── Alviora_phone_app/    # Mobile application for users
├── Alviora_tablet_app/   # Tablet application for caregivers
└── Python_backend/       # Backend services and ML models
```

## Installation Steps

### 1. Clone the Repository
```bash
git clone https://github.com/Sithumli/Alviora.git
cd Alviora
```

### 2. Phone App Setup (Alviora_phone_app)
```bash
cd Alviora_phone_app

# Install Flutter dependencies
flutter pub get

# Configure Firebase
# 1. Create a new Firebase project at https://console.firebase.google.com/
# 2. Add an Android app and download google-services.json
# 3. Place google-services.json in android/app/
# 4. For iOS, download GoogleService-Info.plist and place in ios/Runner/

# Run the app
flutter run
```

### 3. Tablet App Setup (Alviora_tablet_app)
```bash
cd ../Alviora_tablet_app

# Install Flutter dependencies
flutter pub get

# Configure Firebase (similar to phone app)
# 1. Use the same Firebase project
# 2. Add another Android app and download google-services.json
# 3. Place google-services.json in android/app/
# 4. For iOS, download GoogleService-Info.plist and place in ios/Runner/

# Run the app
flutter run
```

### 4. Python Backend Setup (Python_backend)
```bash
cd ../Python_backend

# Create a virtual environment
python -m venv venv

# Activate virtual environment
# On Windows:
venv\Scripts\activate
# On macOS/Linux:
source venv/bin/activate

# Install required packages
pip install -r requirements.txt

# Run the backend server
python app.py
```

## Development Environment Setup

### VS Code Extensions
Install the following VS Code extensions:
- Flutter
- Dart
- Python
- Firebase Explorer
- Git History
- Git Lens

### Android Studio Setup
1. Install the Flutter and Dart plugins
2. Configure Android SDK
3. Set up Android Emulator

### iOS Development (macOS only)
1. Install Xcode from the App Store
2. Install Xcode Command Line Tools
3. Set up iOS Simulator

## Firebase Configuration

1. Create a new Firebase project at https://console.firebase.google.com/
2. Enable the following services:
   - Authentication
   - Cloud Firestore
   - Cloud Storage
   - Cloud Functions (if needed)
3. Configure each app (phone and tablet) with the appropriate Firebase config files

## Running the Applications

### Phone App
```bash
cd Alviora_phone_app
flutter run
```

### Tablet App
```bash
cd Alviora_tablet_app
flutter run
```

### Backend Server
```bash
cd Python_backend
python app.py
```

## Troubleshooting

### Common Issues

1. Flutter pub get fails:
   - Check your internet connection
   - Try deleting pubspec.lock and running flutter pub get again

2. Firebase configuration issues:
   - Verify google-services.json is in the correct location
   - Check Firebase project settings
   - Ensure package names match in Firebase console

3. Python backend issues:
   - Verify virtual environment is activated
   - Check all required packages are installed
   - Ensure correct Python version is being used

### Getting Help
- Check the [Flutter documentation](https://docs.flutter.dev/)
- Visit the [Firebase documentation](https://firebase.google.com/docs)
- Open an issue in the repository
- Contact the development team

## Contributing
1. Fork the repository
2. Create a new branch
3. Make your changes
4. Submit a pull request

