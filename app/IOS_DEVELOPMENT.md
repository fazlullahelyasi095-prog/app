# TryHub iOS: nine-step implementation and acceptance

This configures the existing `app/ios` runner. No separate Flutter architecture,
backend, API, socket protocol, financial calculation or Android setting was added.
The shared Android work present before this change is preserved.

## 1. Platform and dependency audit — inspected

The app already uses Dio/Bearer JWT, Socket.io authentication, LiveKit for ordinary
live rooms, flutter_webrtc for PK, image_picker for uploads, video_player for feed,
url_launcher for received attachments and flutter_secure_storage for auth/gift intents.
Native iOS plugins in the resolved lockfile support iOS 13. Their Package.swift
files are present. path_provider_foundation is a Dart/FFI implementation and needs
no native plugin registration. Keep the existing iOS 13 target and Swift Package
Manager integration; Flutter regenerates its ephemeral package on the Mac. Do not
copy Windows Generated.xcconfig or edit dependency sources. AppDelegate and
SceneDelegate already register Flutter plugins through the implicit engine.

Test: on the Mac run `flutter doctor -v`, `flutter pub get`, then the simulator
build in step 8. Resolve plugin binaries with Xcode; a successful Dart test alone
does not verify native linking.

## 2. Permissions and uploads — configured

Info.plist now describes camera and microphone use for live/PK. Existing photo
library access remains for posts, avatars and chat attachments. Local-network
access has a purpose string for configured development servers. No save-to-library,
Face ID, Bluetooth scanning or broad filesystem permission was added: the app
does not call those APIs. Native plugins request camera/mic access on use.

Test on an iPhone: deny camera, then microphone; verify the error is shown without
a crash. Grant access in Settings and enable live media again. Select a photo,
video and limited-library item for a post/avatar/chat as applicable; cancel the
picker and verify the draft remains. Send JPEG/HEIC and video samples to the
existing upload endpoints and verify playback on Android and web. Test a failed
upload and the server's file-size rejection. Simulator media behavior is not a
substitute for real camera/HEIC testing.

## 3. LiveKit and PK WebRTC — existing protocol retained

Both plugins already provide iOS implementations and share the existing WebRTC
binary. No manual framework copy, TURN credential, signaling event, permission
bypass or architecture workaround was introduced. LiveKit still obtains a token
from the existing backend; PK still obtains ICE configuration and publishing
authorization from Socket.io.

Test with two test accounts: iPhone hosts/Android watches, then reverse; repeat
with web. Check video/audio, denied permissions, receiver rendering, Wi-Fi/cellular
reconnect, PK invite/accept/leave, comments/likes, and server-authoritative gift
scores. Leave/end a room and confirm microphone/camera indicators stop. Repeat
the financial reconciliation procedures in DEVELOPMENT.md.

## 4. Authentication and secure storage — configured

All Runner configurations use the same bundle-scoped Keychain entitlement. Keep
the bundle identifier `com.tryhub.tryhubApp` and Apple team stable to retain
Keychain access. Existing key names, default unlocked accessibility, JWT handling,
logout and user-scoped pending gift persistence remain unchanged.

Test: run `flutter test integration_test/ios_smoke_test.dart -d <ios-device-id>`.
It checks an isolated Keychain test value and login form validation; it does not
log in or change real credentials. Then log in with a test account, force-close,
reopen, log out, and switch accounts. Verify no private routes remain after expiry.
Repeat pending-gift retry after logout. Record reinstall behavior separately:
iOS Keychain entries may outlive an uninstall.

## 5. Networking and deep links — existing interfaces retained

ATS defaults remain enabled: no arbitrary-load or certificate-validation bypass
was added. Configure trusted HTTPS API/media and Socket.io endpoints using the
existing API_BASE_URL and SOCKET_BASE_URL defines. The server's LiveKit URL must
also be reachable and secure. Android's default `10.0.2.2` is not an iOS host.
Use a trusted HTTPS test environment for iOS; a local-network purpose string does
not exempt HTTP from ATS. The build helper requires explicit HTTPS configuration.

No inbound URL scheme, universal-link association, OAuth callback or payment
callback contract exists in the inspected Flutter implementation. None was
invented. Ordinary received HTTPS attachment links continue through url_launcher.

Test: run against the existing HTTPS test backend; verify login/feed/upload,
Socket.io reconnect and LiveKit media. Confirm invalid certificates fail. Open
an attachment in the external browser and return to the same conversation.

## 6. Notifications and background behavior — scoped configuration

Existing in-app notifications use GET /notifications and the notification socket
event. They do not require iOS notification authorization. There is no APNs token
registration/sending service or native push plugin in this app. Push permission,
aps-environment, remote-notification and VoIP modes are intentionally not enabled.
System push delivery remains unimplemented until an actual backend contract and
Apple push credentials exist; a permission prompt alone would not implement it.

Only audio background mode is enabled for an active live audio session. Existing
feed/ad widgets already pause when the app backgrounds, and media rooms dispose
when left. iOS controls background camera interruption; this does not promise
background video, offline gift delivery or sockets surviving process termination.

Test on iPhone: background/lock during live audio, return, interrupt with a phone
call, use wired/Bluetooth headphones, leave/end live, then lock again and confirm
audio stops. Verify feed/ad audio pauses. Trigger a notification from account B,
open notifications as A, mark one/all read and compare with web. Do not mark
background push as passed.

## 7. App icon and splash — configured

Flutter placeholder icons were replaced by a simple TH monogram using the existing
black/white/#ff2d55 theme. This is a development brand asset, not a claim of approved
brand artwork. All existing icon catalog sizes remain, including opaque 1024px
App Store artwork. The native launch storyboard now shows white TryHub text on
black, matching the existing Flutter splash. Android assets remain unchanged.

Test: cold-launch on iPhone and iPad in both orientations; inspect the home-screen
icon, native splash and Flutter splash transition. Check Xcode's asset validation.
Run `python3 scripts/verify_ios.py` to validate all 19 catalog slots. Regenerate
the 15 unique icon PNGs on Windows with `pwsh -File scripts/generate_ios_icons.ps1`.

## 8. Signing, release and payments — prepared, external setup pending

Automatic signing and common entitlements are wired for Debug/Profile/Release.
Copy ios/Flutter/Signing.xcconfig.example to Signing.xcconfig on the Mac and set
your real DEVELOPMENT_TEAM (or select your team in Xcode). That local file is
ignored. No team ID, certificate or provisioning profile was fabricated. Register
the existing bundle ID with the correct Apple account. Existing pubspec version
and Xcode release optimization settings are preserved.

From app/ on macOS, export the actual existing test URLs, then run:

```sh
sh scripts/build_ios.sh simulator
sh scripts/build_ios.sh unsigned
flutter devices
flutter test integration_test/ios_smoke_test.dart -d <ios-device-id>
flutter run -d <ios-device-id> --dart-define=API_BASE_URL="$API_BASE_URL" --dart-define=SOCKET_BASE_URL="$SOCKET_BASE_URL"
# After configuring the Apple team, signing and actual release endpoints:
sh scripts/build_ios.sh ipa
```

Set API_BASE_URL to the full HTTPS URL ending in /api, and SOCKET_BASE_URL to the
HTTPS Socket.io origin. The helper builds locally; it does not upload/publish.
Review the archive in Xcode before distribution. App Store privacy disclosures,
dependency privacy manifests, export-compliance answers and signed-device testing
still require review of the final archive and actual service configuration.

The Flutter wallet currently displays server balances/transactions/earnings and
does not sell coins. Existing backend coin purchase routes are not App Store
transaction verification. StoreKit, product IDs and Apple transaction verification
are absent. No iOS coin checkout was added; real purchases remain a separate
integration requiring server-side verified transaction handling.

## 9. Regression and acceptance — record actual results

```sh
python3 scripts/verify_ios.py
flutter analyze --no-pub
flutter test --no-pub
flutter test integration_test/android_smoke_test.dart -d <android-device-id>
flutter test integration_test/ios_smoke_test.dart -d <ios-device-id>
flutter build apk --debug --no-pub
```

The owner confirmed no Mac is available. This workspace runs on Windows,
without Xcode or an iOS simulator/device. iOS
compilation, real Keychain/media, signed archive and iPhone/iPad acceptance cannot
be reported as passed here. No Android device is currently connected; prior
physical-device reconnection was declined. Two-account acceptance also needs an
available existing backend; its startup was previously declined.

Portable iOS checks passed: purpose strings, scoped entitlements, three build
configurations, storyboard XML and 19 correctly sized opaque icon slots.
Shared Flutter regression suite: 16 passed. Strict Dart analysis: no issues found.
Portable iOS validation, shell syntax validation and app-scoped git diff checks
passed. The Android build installed SDK 35/36, then failed in device_info_plus's
Kotlin incremental cache because the plugin cache is on C: and this project is on
E:. A local retry uses `-Pkotlin.incremental=false` and
`-Pkotlin.compiler.execution.strategy=in-process`, without changing Android source.
An APK and Android device test pass are not yet confirmed. The iOS smoke test is
provided but has not run on an Apple device or simulator.

## File-by-file changes

- ios/Runner/Info.plist: camera/mic/local-network descriptions and live background audio.
- ios/Runner/Runner.entitlements: app-scoped Keychain access.
- ios/Runner.xcodeproj/project.pbxproj: connect that entitlement and automatic signing in all three Runner configurations.
- ios/Flutter/Debug.xcconfig and Release.xcconfig: optional local signing include (Profile already uses Release).
- ios/Flutter/Signing.xcconfig.example: explain where the real Apple team is supplied.
- ios/.gitignore: exclude local signing configuration.
- ios/Runner/Base.lproj/LaunchScreen.storyboard: branded text and dark background.
- ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png: App Store icon.
- In the same icon directory, Icon-App-20x20@1x.png, @2x.png and @3x.png: small icon slots.
- Icon-App-29x29@1x.png, @2x.png and @3x.png: settings icon slots.
- Icon-App-40x40@1x.png, @2x.png and @3x.png: medium icon slots.
- Icon-App-60x60@2x.png and @3x.png: iPhone home-screen slots.
- Icon-App-76x76@1x.png and @2x.png, and Icon-App-83.5x83.5@2x.png: iPad slots.
- scripts/generate_ios_icons.ps1: reproducible geometric artwork without font/image dependencies.
- scripts/verify_ios.py: portable configuration and asset validation; no Xcode claim.
- scripts/build_ios.sh: explicit HTTPS builds on macOS, with simulator/unsigned/IPA modes.
- integration_test/ios_smoke_test.dart: native Keychain round-trip and login validation.
- IOS_DEVELOPMENT.md: inspected contracts, nine steps, exact tests and pending dependencies.

References: [Flutter iOS release guide](https://docs.flutter.dev/deployment/ios),
[Flutter SwiftPM transition](https://flutter.dev/blog/whats-new-in-flutter-3-44),
[Apple background modes](https://developer.apple.com/documentation/Xcode/configuring-background-execution-modes).
Plugin-specific requirements were checked against the installed, locked package source.
