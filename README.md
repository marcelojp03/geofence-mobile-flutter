# Geofence Mobile App

[![Flutter](https://img.shields.io/badge/Flutter-3.9-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.9-blue.svg)](https://dart.dev/)
[![Riverpod](https://img.shields.io/badge/Riverpod-2.6-purple.svg)](https://riverpod.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-FCM-orange.svg)](https://firebase.google.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Mobile application for real-time child location tracking and geofence monitoring. Supports two modes: **Parent Mode** (monitoring) and **Child Mode** (tracking).

---

## Features

### Parent Mode 👨‍👩‍👧
- **Login/Authentication** with JWT
- **View children list** with status indicators
- **Real-time location** on interactive map
- **Battery level** monitoring
- **Geofence alerts** (entry/exit notifications)
- **QR code generation** for device pairing
- **Push notifications** via Firebase Cloud Messaging

### Child Mode 📱
- **QR code scanning** for quick device setup
- **Foreground tracking** every 30 seconds
- **Background tracking** via WorkManager (~15 min intervals)
- **Battery level** reporting
- **Automatic device registration** with backend

---

## Prerequisites

- Flutter SDK >= 3.9.x
- Dart SDK >= 3.9.x
- Android Studio / VS Code
- Firebase project configured
- Backend API running

---

## Installation

### 1. Clone the repository

```bash
git clone https://github.com/marcelojp03/geofence-mobile-flutter.git
cd geofence-mobile-flutter
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure environment variables

Create a `.env` file in the root directory:

```env
API_URL=https://your-backend-url.com/api
```

### 4. Configure Firebase

Follow the instructions in [FIREBASE_SETUP.md](FIREBASE_SETUP.md) to configure:
- `google-services.json` (Android)
- `GoogleService-Info.plist` (iOS)

### 5. Run the application

```bash
# Development
flutter run

# Release build
flutter build apk --release
flutter build ios --release
```

---

## Project Structure

```
lib/
├── config/
│   ├── router/         # GoRouter navigation
│   └── theme/          # App theme & colors
├── core/
│   ├── api/            # Dio HTTP client
│   ├── services/       # Location, Device, Notification services
│   └── storage/        # Secure storage
├── shared/
│   ├── utils/          # Responsive utilities
│   └── widgets/        # Reusable UI components
└── features/
    ├── auth/           # Login & authentication
    ├── mode_selector/  # Parent/Child mode selection
    ├── children/       # Children list & detail
    ├── parent_mode/    # Parent dashboard
    ├── child_mode/     # Child tracking & setup
    ├── tracking/       # GPS tracking repository
    ├── devices/        # Device management
    ├── alerts/         # Geofence alerts
    └── notifications/  # FCM push notifications
```

---

## App Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                      MODE SELECTOR                               │
│                                                                  │
│    ┌──────────────────┐        ┌──────────────────┐            │
│    │  Parent Mode     │        │   Child Mode     │            │
│    │  (Monitoring)    │        │   (Tracking)     │            │
│    └────────┬─────────┘        └────────┬─────────┘            │
└─────────────┼───────────────────────────┼───────────────────────┘
              │                           │
              ▼                           ▼
┌─────────────────────────┐    ┌─────────────────────────┐
│        LOGIN            │    │      QR SCANNER         │
│   email + password      │    │   Scan parent's QR      │
└───────────┬─────────────┘    └───────────┬─────────────┘
            │                              │
            ▼                              ▼
┌─────────────────────────┐    ┌─────────────────────────┐
│     PARENT HOME         │    │    TRACKING ACTIVE      │
│  • Children list        │    │  • GPS every 30s        │
│  • Last locations       │    │  • Background ~15min    │
│  • Generate QR          │    │  • Battery reporting    │
│  • Push notifications   │    │  • Auto-reconnect       │
└─────────────────────────┘    └─────────────────────────┘
```

---

## API Integration

| Endpoint | Method | Auth | Description |
|----------|--------|------|-------------|
| `/auth/login` | POST | ❌ | Parent authentication |
| `/auth/me` | GET | 🔒 | Get current user |
| `/children/my-children` | GET | 🔒 | List parent's children |
| `/children/:id` | GET | 🔒 | Child details |
| `/alerts/child/:id` | GET | 🔒 | Child alerts |
| `/devices` | POST | ❌ | Register device |
| `/devices/link` | POST | ❌ | Link device to child |
| `/tracking/positions` | POST | ❌ | Send GPS position |
| `/devices/fcm-token` | POST | 🔒 | Register FCM token |

---

## Technology Stack

| Category | Technology |
|----------|------------|
| **Framework** | Flutter 3.9 |
| **Language** | Dart 3.9 |
| **State Management** | Riverpod 2.6 |
| **Navigation** | GoRouter 14.x |
| **HTTP Client** | Dio 5.x |
| **Maps** | flutter_map + OpenStreetMap |
| **Location** | Geolocator 13.x |
| **Background Tasks** | WorkManager |
| **Push Notifications** | Firebase Cloud Messaging |
| **QR Code** | mobile_scanner + qr_flutter |
| **Storage** | SharedPreferences |
| **Theme** | FlexColorScheme |

---

## Permissions

### Android (`AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

### iOS (`Info.plist`)
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<key>NSCameraUsageDescription</key>
<key>UIBackgroundModes</key>
<array>
    <string>location</string>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

---

## Documentation

| Document | Description |
|----------|-------------|
| [FIREBASE_SETUP.md](FIREBASE_SETUP.md) | Firebase configuration guide |
| [docs/API_MOBILE_FLUTTER.md](docs/API_MOBILE_FLUTTER.md) | API reference |

---

## Related Projects

| Repository | Description |
|------------|-------------|
| [geofence-be-nest](https://github.com/marcelojp03/geofence-be-nest) | NestJS Backend API |
| [geofence-fe-next](https://github.com/marcelojp03/geofence-fe-next) | Next.js Admin Panel |

---

## License

MIT
