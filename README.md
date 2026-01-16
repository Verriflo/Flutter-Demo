# Verriflo Classroom Demo

A reference implementation showing how to integrate the Verriflo Classroom SDK into a Flutter app. Use this as a starting point or study the code to understand the integration pattern.

## Features

- **Live Video Streaming** — Watch classes via WebRTC
- **Event Handling** — Class ended, kicked, reconnecting states
- **Quality Control** — Auto-adaptive or manual quality selection
- **Fullscreen Mode** — Landscape orientation with overlay controls
- **Responsive Layout** — Adapts to portrait/landscape

## Getting Started

### Prerequisites

- Flutter 3.0+
- iOS 13+ / Android API 21+
- A Verriflo organization account

### Installation

```bash
# Clone and enter the demo directory
cd flutter-sdk/demo_app

# Install dependencies
flutter pub get

# Run on connected device or simulator
flutter run
```

### Firebase Setup (Android)

1. Download `google-services.json` from Firebase Console
2. Place it in `android/app/google-services.json`
3. Add your SHA-1 fingerprint to Firebase

## How It Works

### Join Flow

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  JoinScreen │ ──► │   API Call  │ ──► │ ClassroomScreen │
│  (form)     │     │ /sdk/join   │     │ (player)      │
└─────────────┘     └─────────────┘     └─────────────┘
```

1. User enters room ID, name, and UID
2. App calls Verriflo API to get streaming token
3. `VerrifloPlayer` connects using the provided iframe URL

### API Integration

```dart
// Use VerrifloClient to join or create rooms
final response = await client.joinRoom(
  'math-101',
  JoinRoomRequest(
    participant: Participant(
      uid: 'user-123',
      name: 'John Doe',
      role: ParticipantRole.student,
    ),
  ),
);
```

### Player Integration

```dart
VerrifloPlayer(
  iframeUrl: response.iframeUrl,
  onClassEnded: () {
    Navigator.pop(context);
  },
  onKicked: (reason) {
    showDialog(...);
  },
  onEvent: (event) {
    print('${event.type}: ${event.message}');
  },
)
```

## Project Structure

```
demo_app/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── screens/
│   │   ├── home_screen.dart         # Landing page
│   │   ├── join_screen.dart         # Form to join class
│   │   └── classroom_screen.dart    # Video player page
│   ├── services/
│   │   └── api_service.dart         # API client
│   └── widgets/
│       ├── gradient_button.dart     # Styled button
│       └── classroom_tabs.dart      # Chat/polls placeholder
├── android/
│   └── app/
│       ├── google-services.json     # Firebase config (add this)
│       └── build.gradle.kts         # Signing config
├── ios/
│   └── Runner/
│       └── Info.plist               # Permissions
|── pubspec.yaml
```

## Configuration

### Form Fields

| Field               | Description                |
| ------------------- | -------------------------- |
| **API URL**         | Your Verriflo API endpoint |
| **Organization ID** | VF-ORG-ID header value     |
| **Room ID**         | Classroom identifier       |
| **Name**            | Display name in class      |
| **User ID (UID)**   | Unique identifier for user |

### Events

The player emits these events via `onEvent`:

- `connected` — Joined successfully
- `disconnected` — Left the classroom
- `classEnded` — Teacher ended session
- `participantKicked` — Removed from class
- `reconnecting` — Connection dropped, trying again
- `error` — Something went wrong

## Building for Release

### Android

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### iOS

```bash
flutter build ios --release
# Then archive in Xcode for App Store
```

## Customization

This demo is designed to be forked and customized:

- **Branding** — Update colors in `main.dart`
- **Screens** — Modify layouts in `screens/`
- **API** — Adjust `api_service.dart` for your backend
- **Events** — Handle additional events in `classroom_screen.dart`

## Troubleshooting

**Video not loading**

- Check network permissions in AndroidManifest.xml
- Verify the teacher has started the class

**"Room not found" error**

- The classroom doesn't exist yet
- Teacher needs to start the class first

**iOS build fails**

- Open `ios/Runner.xcworkspace` in Xcode
- Select a Development Team under Signing

## License

Proprietary — Part of the Verriflo SDK package.
