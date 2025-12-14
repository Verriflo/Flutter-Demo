# Verriflo SDK Demo App

A complete demonstration of the Verriflo Classroom SDK integration flow.

## What This Demo Shows

1. **API Integration** — Calls `/v1/live/sdk/join` to obtain streaming credentials
2. **VerrifloPlayer Widget** — Displays live video with quality controls
3. **Event Handling** — Responds to connection state and class lifecycle events

## Running the Demo

```bash
cd demo_app
flutter pub get
flutter run
```

## Usage Flow

### Step 1: Enter Configuration

| Field | Description |
|-------|-------------|
| API URL | Your Verriflo API endpoint |
| Organization ID | Your VF-ORG-ID |
| Room ID | Class/room identifier to join |
| Student Name | Display name in classroom |
| Student Email | Email for identification |

### Step 2: Join Class

Tap **Join Class** to:
1. Call the SDK join API with student details
2. Receive streaming access token
3. Auto-connect the VerrifloPlayer

### Step 3: Watch Stream

- Tap video to show/hide controls
- **⚙️ Settings** (bottom-right) — Change video quality
- **⛶ Fullscreen** (bottom-left) — Toggle fullscreen mode

## Project Structure

```
demo_app/
├── lib/
│   └── main.dart          # Complete demo implementation
├── pubspec.yaml           # Dependencies
└── README.md              # This file
```

## Integration Example

The demo shows the complete integration pattern:

```dart
// 1. Call API to get token
final response = await http.post(
  Uri.parse('$apiUrl/v1/live/sdk/join'),
  headers: {'VF-ORG-ID': orgId, 'Content-Type': 'application/json'},
  body: jsonEncode({'roomId': roomId, 'name': name, 'email': email}),
);
final token = jsonDecode(response.body)['data']['livekitToken'];

// 2. Use in player widget
VerrifloPlayer(
  config: VerrifloConfig(serverUrl: serverUrl, token: token),
  onEvent: (event) => handleEvent(event),
)
```

## Requirements

- Flutter 3.0+
- iOS 12+ / Android API 21+
- Active Verriflo organization account
