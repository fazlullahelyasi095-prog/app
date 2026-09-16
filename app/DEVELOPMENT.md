# Mobile changes and testing

This extends the existing Flutter app; React, Express and the database were not
rewritten. Existing auth, feed, profiles, follow, comments, likes and uploads remain.

## Files changed

- lib/services/gift_intent_store.dart: securely persist the exact pending gift request until acknowledgement.
- lib/core/storage.dart: clear authentication keys on logout while retaining user-scoped pending gift keys.
- test/gift_intent_store_test.dart: verify logout persistence and user/live isolation.
- android/app/build.gradle.kts: compile SDK 37 required by the existing secure-storage plugin; the default NDK selection is preserved.
- lib/main.dart: rebuild navigation on authenticated-user changes to remove private routes after logout/expiry; attach route observer.
- lib/core/app_router.dart: add messages, live, wallet and notifications routes and route observer.
- lib/screens/feed/feed_screen.dart: expose feature routes in the profile menu; pause feed/ad playback behind another route.
- lib/screens/profile/profile_screen.dart: start a backend conversation from a profile.
- lib/services/chat_service.dart: injectable HTTP adapter for existing conversation/send/read APIs; optional multipart media preserves text-only JSON requests; read acknowledgements are limited to unread incoming messages to avoid the backend's conversation_updated refresh loop.
- lib/chat/chat_screen.dart: conversation list, text chat, photo/video selection and sending, received attachment opening, refresh and socket cleanup. Failed sends retain the selected attachment and caption.
- lib/socket/socket_service.dart: JWT socket connection, reconnect callbacks, acknowledgements and disposal.
- lib/live/live_screen.dart: list/create/end live, LiveKit room, camera/mic controls, server comments/likes/viewers, gifts, PK requests/state, earnings entry.
- lib/pk/pk_media.dart: existing PK WebRTC protocol, server-authorized publishing, remote rendering and ICE queuing.
- lib/wallet/wallet_screen.dart: server wallet amounts, paginated transaction history and per-live creator earnings.
- lib/screens/notifications_screen.dart: paginated notifications, socket refresh and read actions.
- android/app/src/main/AndroidManifest.xml: camera/microphone/audio permissions; camera and mic are optional hardware.
- pubspec.yaml/pubspec.lock: direct flutter_webrtc dependency (already present via LiveKit), SDK integration_test dependency and resolved lock entries.
- test/chat_contract_test.dart: verify text/multipart request shapes, rejected-send behavior and convergence after read broadcasts.
- integration_test/android_smoke_test.dart: Android login validation without modifying accounts or stored credentials.
- BACKEND_CONTRACTS.md: source-backed API/event inventory and existing backend caveats.
- DEVELOPMENT.md: this file-by-file explanation and test procedure.

## Repeatable local checks

From app/:

```powershell
flutter pub get
flutter analyze --no-pub
flutter test --no-pub
flutter devices
flutter test integration_test/android_smoke_test.dart -d <android-device-id> --no-pub
flutter build apk --debug --no-pub
```

Local builds default to the development PC at 10.225.252.162:3000.
Run `./scripts/build_android_local.ps1` to build a debug APK for that address,
or pass `-ServerAddress <PC-LAN-IP>` if it changes.
For emulator use API_BASE_URL=http://10.0.2.2:3000/api and
SOCKET_BASE_URL=http://10.0.2.2:3000. For a phone use the development PC's LAN IP:

```powershell
flutter run -d <android-device-id> --dart-define=API_BASE_URL=http://<PC-LAN-IP>:3000/api --dart-define=SOCKET_BASE_URL=http://<PC-LAN-IP>:3000
```

Use HTTPS production defines for release. The server-provided LiveKit URL must
also be reachable from each device; API connectivity alone does not test media.

## Exact feature checks (two test accounts, A and B)

1. Auth: register A with legal consent; log in; restart app; confirm restored user. Log out, log in B, verify no A private routes/data remain. Expire a test JWT and open wallet: expect login and no private back-navigation.
2. Existing social: play feed; open profile and confirm feed audio pauses. Follow/unfollow B, like/unlike and comment on B's post; confirm on web. Upload a test post and profile picture with the existing controls.
3. Chat: A opens B profile > Message, sends text. B sees it on web/app; reply and verify refresh. Leave/reopen conversation and reconnect Wi-Fi; verify no repeated rows. After B reads a message, verify POST /chat/read stops repeating. Attach a photo/video using the paperclip, confirm the filename, remove it, select again and send with/without a caption. Open the received attachment on web/app. Cancel the picker without changing the draft. Check blocked-user server errors and confirm a failed send retains its attachment/caption. The existing server enforces its 50 MB upload limit.
4. Live: A uses Live > Go live, enters title, enables camera/microphone. B joins from web/app. Verify both-direction audio/video, permission-denial messaging, viewer count, comments and likes. Leave/rejoin and interrupt Wi-Fi. End live as A; B must see ended state and media stop.
5. Gifts: fund only test accounts through the existing server workflow. B selects a gift and recipient. Compare backend wallet/transactions and creator earnings before/after. Double-tap while pending and simulate lost acknowledgement; retry must retain the same key and charge once. Test insufficient balance. Do not infer money correctness from UI alone.
6. PK: B requests PK while watching A; A accepts. Enable PK cameras on participants. Verify Android-to-web and web-to-Android video/audio, server scores following gifts to each participant, and restoration after the server ends PK. Deny camera permission and reconnect during PK.
7. Wallet: compare coins/cash/pending amounts against web; navigate multiple transaction pages. As live owner open Earnings and compare server totals. Verify another user cannot read the owner's earnings.
8. Notifications: trigger a follow/comment/message from B; A opens notifications, pages older rows and marks one/all read. Verify against web. Background push is not implemented because the backend has no inspected push registration service.

## Validation boundaries

Automated checks do not replace the two-account network/media/financial checks.
No emulator was configured and Android SDK cmdline-tools were absent at inspection.
The connected Samsung Android 13 phone changed from USB to wireless during testing.
Record actual test results separately; do not treat a launched command as a pass.

Remaining hardening: chat document/audio selection, background push, production signing, and full network/interoperability acceptance need follow-up. Photo/video attachments use the existing image picker; received documents/audio can already be opened. The app should not
be treated as production-ready until the acceptance checks above pass.

## Results recorded during this implementation

- Flutter unit/widget tests: 14 passed, including chat contracts and gift persistence.
- First device build: blocked by incomplete NDK 28.2.13676358 (missing source.properties).
- NDK 30 override attempt also failed because JNI requires NDK 28.2. The override was removed and installation of the required NDK was started.
- Emulator creation initially failed because avdmanager was missing. Official command-line tools were downloaded and SHA-256 verified; image installation was attempted.
- Local API port 3000 refused connections. Starting the existing backend was declined; no live backend data was modified for acceptance testing.
- Strict Dart analysis with --fatal-infos: passed, no issues found. App-scoped git diff --check: passed.

## Continuation on September 7

- Physical-device reconnection was declined; physical-device acceptance remains pending.
- A workspace-local Gradle init script was used to try the already installed NDK 30 across all Android modules, without changing the app's default NDK or dependency sources. SDK Platform 36 installed; the build subsequently requested SDK Platform 35. No APK or device pass is implied by these setup steps.
- The required default NDK 28 archive is downloading separately; installation and checksum verification remain pending until the download completes.
- Full Flutter unit/widget suite after the chat changes: 16 passed, including read-loop convergence and multipart media contracts.
