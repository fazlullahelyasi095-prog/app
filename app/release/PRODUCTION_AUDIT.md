# TryHub Android production-readiness audit

Audit date: September 7, 2026. Decision: **NO-GO for Google Play production**.
The owner confirmed there is no HTTPS production backend, no registered Play app,
and no upload keystore. The eight mobile feature phases are not fully accepted.
This preparation does not turn the app into a completed or published product.

## Identity and build baseline

| Item | Inspected value / status |
| --- | --- |
| Application ID / namespace | com.tryhub.tryhub_app — preserved; confirm before first Play registration |
| Display name | TryHub |
| Flutter version | 3.44.6; Dart 3.12.2 in the local toolchain |
| Version name / versionCode | pubspec 1.0.0+1; Gradle reads Flutter values |
| Minimum / target SDK | Flutter defaults resolve to 24 / 36 |
| Compile SDK | 37, required by the existing secure-storage plugin |
| Native dependencies | LiveKit, flutter_webrtc, video_player, secure storage, image picker and their locked dependencies |
| Signing before audit | Release incorrectly used Android debug signing |
| Signing after preparation | Dedicated upload signing from ignored android/key.properties; missing values block release |
| Endpoint before audit | Android emulator HTTP defaults applied to release too |
| Endpoint after preparation | Debug defaults preserved; release defaults empty; Gradle requires explicit public HTTPS defines |
| Play assets | Android launcher branding, actual screenshots and feature graphic still require acceptance |

The installed Flutter target is API 36. Check the actual merged manifest and
current Play Console requirement before uploading; do not infer target SDK from
compile SDK. [Target API requirements](https://developer.android.com/google/play/requirements/target-sdk).

## Source and credentials review

Inspected the Flutter library inventory, authentication/storage, API client,
Socket.io, media dependencies, Android manifests/resources, Gradle settings,
versioning and existing tests. Runtime source contained no print/debugPrint or
Dio request logger in the searched code. The test username, example email and
fake tokens exist in test fixtures, not runtime assets; these must remain tests.
No real user/test account credentials were supplied for release.

The portable preflight scans lib/ and android/app/src for selected private-key and
API-key signatures and reports locations without printing values. This is a
heuristic check, not proof that no possible secret exists. Review the final APK/AAB
assets/native configuration as well. Do not package the repository's backend .env,
database dumps, keystores, certificates or test fixture files into Flutter assets.
Current pubspec does not declare those as assets. API URLs are configuration,
not secrets; JWTs and TURN/media tokens must continue to come from the backend.

## Network and permissions

Release explicitly disables cleartext HTTP and app backup. Debug's existing HTTP
exception remains available for local development. No certificate-validation
bypass was found in inspected application code. Before release, configure valid
TLS for the EXISTING backend, Socket.io, uploaded media and server-returned LiveKit
URL. Verify redirects do not downgrade to HTTP. The Gradle gate checks URL format,
not DNS ownership, certificate validity, service health or production readiness.

| Permission / capability | Justification and acceptance |
| --- | --- |
| INTERNET | Existing API, uploads, media and sockets |
| ACCESS_NETWORK_STATE | Declared by the installed connectivity_plus plugin for connection status |
| CAMERA | User-enabled live/PK video; deny/re-enable must be tested |
| RECORD_AUDIO | User-enabled live/PK microphone; verify indicators stop on leave/end |
| MODIFY_AUDIO_SETTINGS | WebRTC audio routing |
| Camera/microphone hardware | Optional, so devices without them can use viewing features |
| POST_NOTIFICATIONS | Not requested: current notifications are in-app, not OS push |
| Broad storage/contacts/location | Not requested by the application manifest; inspect final dependency-merged manifest |
| Backup | Release disables Android backup for auth and pending sensitive operation data; verify restore behavior on device |

The final merged RELEASE manifest remains the authority, including plugin-added
permissions. Justify/remove unexpected permissions only after checking the
dependency and feature that declares them. Do not add privacy-sensitive permissions
merely to make a build pass. The system photo picker supplies selected media.

## Crash handling, optimization and native checks

- Existing API screens catch request errors; auth expiry removes private navigation.
- Fixed the startup path where secure-storage read/cleanup failures could escape
  restoration and leave the splash screen stuck. Added a regression test.
- This is not a global crash-recovery claim. Native crashes, ANRs, background media
  interruptions and memory pressure still need real-device testing. No new crash
  telemetry service or data collection was introduced. Review Android vitals and
  choose a documented support/diagnostics process before rollout.
- The installed Flutter Gradle plugin enables release minification and resource
  shrinking and supplies its ProGuard rules. Keep that normal integration; no blanket keep-all rules or
  --no-shrink workaround was introduced. Test the actual shrunk release across
  JNI, secure storage, LiveKit and PK. Archive any generated mapping/symbol files
  with the exact versionCode in private release storage.
- Check 16 KB page-size support for every native library, especially Flutter,
  WebRTC and JNI. NDK version alone is not proof; inspect ELF/ZIP alignment and
  test a 16 KB device/image using the official procedure.
  [Android page-size checks](https://developer.android.com/guide/practices/page-sizes).

## Release blockers and production checklist

- [ ] Existing backend has trusted production HTTPS; API/Socket.io/media/LiveKit work from mobile networks.
- [ ] Owner confirms application ID, developer account and ownership before registration.
- [ ] Upload keystore created securely, backed up privately and connected to Play App Signing.
- [ ] Public privacy policy, terms, support email and legal identity supplied.
- [ ] Readable privacy/terms links implemented inside the app (registration currently only has checkbox text).
- [ ] Actual account/data deletion API/workflow and in-app plus web request path implemented; no inspected user-facing deletion route exists yet.
- [ ] Remaining mobile feature gaps resolved or intentionally removed from launch scope, with matching store copy. Chat audio/files/presence, financial operations and live/PK recovery still have acceptance gaps.
- [ ] UGC report/block/moderation and social child-safety requirements verified across shipped surfaces.
- [ ] Data safety and content declarations completed from actual backend/provider behavior, not assumptions.
- [ ] Real signed APK/AAB builds successfully using the production configuration.
- [ ] Verify signing certificate, non-debuggable manifest, versionCode, target/min SDK, permissions, cleartext=false, backup policy and absence of development endpoints in the final artifact.
- [ ] R8, 16 KB/native library alignment, startup and process-death behavior verified.
- [ ] Physical Android tests completed; no Android device is currently available.
- [ ] Two-account feed/auth/chat/live/gift/PK/wallet reconciliation against existing web passes.
- [ ] Crash/ANR, poor-network, denied-permission, background/foreground and memory tests pass.
- [ ] Real screenshots, approved icon/feature graphic, reviewer access and internal/closed testing plan prepared.
- [ ] Owner approves the concrete artifact and declarations before any upload/promotion.

See PLAY_STORE.md for metadata draft, privacy/data-safety worksheet, screenshots,
content declarations and testing-track requirements. Nothing is submitted by these scripts.

## Exact local build procedure (after blockers are resolved)

1. Copy release/production.example.json to release/production.json and provide the
   actual HTTPS API URL ending in /api and HTTPS Socket.io origin. Do not use example domains.
2. Create the real upload key using an interactive password prompt on the owner's
   machine, or use an existing key. The command below is preparation guidance only;
   it was NOT run, and it must not overwrite an existing keystore:

   ```powershell
   keytool -genkeypair -v -keystore <private-path>/tryhub-upload.jks -alias upload -keyalg RSA -keysize 2048 -validity 10000
   ```

3. Copy android/key.properties.example to android/key.properties. Enter the real
   storeFile, storePassword, keyAlias and keyPassword locally. Use forward slashes
   for Windows paths. These files are ignored; do not paste passwords into chat.
4. From app/:

   ```powershell
   python scripts/release_preflight.py
   pwsh -File scripts/build_android_release.ps1 -Artifact appbundle -BuildName 1.0.0 -BuildNumber 1
   pwsh -File scripts/build_android_release.ps1 -Artifact apk -BuildName 1.0.0 -BuildNumber 1
   ```

5. Expected output paths only (not claims that files exist):
   build/app/outputs/bundle/release/app-release.aab and
   build/app/outputs/flutter-apk/app-release.apk. Verify APK signing with the SDK's
   `apksigner verify --verbose --print-certs <apk>` and AAB signing with
   `jarsigner -verify -verbose -certs <aab>`. Compare certificate fingerprints to
   the owner's upload key. Inspect the AAB with bundletool/Play's bundle explorer
   and install Play-generated splits in internal testing.
6. VersionCode must increase for each new Play upload. Since there is no registered
   app yet, 1.0.0+1 is retained; use the next unused number if registration/history
   changes. Keep the ID and signing identity stable to preserve updates.

Source: [Flutter Android release/signing guide](https://docs.flutter.dev/deployment/android).

## Testing the changes made in this audit

- Run `flutter test --no-pub` and `flutter analyze --no-pub` from app/.
- Run `python scripts/release_preflight.py` without local configuration: expect
  exit 1 and missing HTTPS/signing blockers, with no secret values printed.
- Run `./gradlew.bat :app:validateProductionRelease` from app/android: expect
  missing-URL rejection. Supply real encoded Flutter defines later to exercise
  the missing-key rejection, then verify the actual signed build. Do not fabricate
  production hosts or keys simply to get a passing build.
- On Android, cold-start with working and unavailable secure storage; expect login
  instead of an indefinite splash when storage fails. Test normal auth restore,
  expiry and logout. Grant/deny live permissions and test upgrade/reinstall backup
  behavior separately. Full device steps are also in DEVELOPMENT.md.

## Files modified in this release preparation

- android/app/build.gradle.kts: dedicated upload signing; apply the release guard.
- android/app/production.gradle.kts: validate explicit public HTTPS configuration
  and real upload signing before preReleaseBuild; debug remains unaffected.
- android/app/src/release/AndroidManifest.xml: release-only cleartext/backup restrictions.
- android/key.properties.example: empty signing template, containing no credentials.
- lib/core/app_config.dart: remove emulator fallback from release constant values.
- lib/auth/auth_controller.dart: handle secure-storage startup/cleanup failures.
- test/auth_controller_test.dart: regression for unavailable secure storage.
- .gitignore: ignore local production endpoint configuration.
- release/production.example.json: empty existing-API configuration template.
- scripts/release_preflight.py: read-only configuration/selected-secret audit.
- scripts/build_android_release.ps1: explicit local release workflow; no publishing.
- release/PLAY_STORE.md: store listing draft and declaration/testing requirements.
- release/PRODUCTION_AUDIT.md: findings, blockers, per-file explanation and exact tests.

## Result record

No signed production APK/AAB exists from this preparation. Missing HTTPS and
upload signing are confirmed owner-supplied blockers. The earlier debug build
retry was stopped while compiling; it was not a release artifact or test pass.
Verification results below must reflect completed commands, not started processes.

- Shared Flutter unit/widget suite: **17 passed**, including the new startup regression.
- Strict Dart analysis: **no issues found**. App-scoped git diff whitespace check
  and release PowerShell syntax validation passed.
- Gradle configured the project and executed validateProductionRelease: **expected
  failure** rejecting the missing API_BASE_URL. This validates the rejection path,
  not a successful signed release. The check used the existing workspace-local
  NDK override to bypass the machine's previously incomplete default installation;
  no Android NDK source setting was changed by this audit.
- Python preflight: **expected exit 1** for absent HTTPS API/socket URLs and upload
  signing. Scanned 47 source/configuration files with no selected secret-pattern
  matches. This is not a comprehensive credential or artifact audit.
