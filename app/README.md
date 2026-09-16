# TryHub mobile

Flutter client for the existing TryHub backend. The server remains authoritative
for authentication, social data, live state, coins, gifts, earnings, PK scores,
wallets, and transactions.

## Environment

Supply production endpoints at build or run time with Dart defines:

```powershell
flutter run --dart-define=API_BASE_URL=https://api.example.com/api --dart-define=SOCKET_BASE_URL=https://api.example.com
```

Local development defaults to `http://10.225.252.162:3000` for physical-phone testing.
Build the local 64-bit ARM APK with `./scripts/build_android_local.ps1`; use
`-TargetPlatform android-arm` for a 32-bit ARM phone, and
`-ServerAddress <PC-LAN-IP>` if the computer's address changes. Keep the backend
running and the phone on the same network. For an Android emulator, override
the host with `10.0.2.2`. Cleartext
HTTP is permitted only in Android debug/profile builds; release builds require
HTTPS.

## Verification

```powershell
flutter analyze
flutter test
flutter build apk --release
flutter build appbundle --release
```

The repository includes Android and iOS runners. Building, signing, simulator
testing, and device validation for iOS require macOS with Xcode. Open
`ios/Runner.xcworkspace` on macOS and select an Apple development team before
running or archiving the iOS application.
