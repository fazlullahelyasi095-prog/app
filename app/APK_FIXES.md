# APK alignment and interaction fixes

The existing Flutter client, HTTP endpoints, Socket.IO events, LiveKit rooms,
authentication storage, and backend remain in use. No web source, database schema,
or backend logic was changed. The only server-side file edit is the local IP in
`LIVEKIT_URL` in `.env`, required because the computer's Wi-Fi address changed.

## Files changed

| File | Change and reason |
| --- | --- |
| `../.env` | Change only the LiveKit host to `10.184.130.162`; the previous IP no longer belongs to this computer. |
| `lib/core/app_config.dart` | Use `10.184.130.162:3000` for debug API and socket defaults. Existing build-time overrides and release requirements are preserved. |
| `scripts/build_android_local.ps1` | Keep the local APK build script on the same server IP. |
| `lib/widgets/app_navigation.dart` | Add the existing web destinations: Home, Discover, Upload, Messages, Profile. Reuse the app's existing routes. |
| `lib/main.dart` | Show that navigation around the authenticated feed. |
| `lib/core/app_router.dart` | Show the same navigation around existing primary destination screens. |
| `lib/core/app_theme.dart` | Match the web accent/background colors and rounded dark inputs. |
| `lib/screens/feed/feed_screen.dart` | Remove the mobile-only top toolbar; move the account menu away from the like/comment buttons. Preserve account, wallet, notification and logout access. |
| `lib/widgets/feed_video_card.dart` | Match the mobile web cover layout and action position, keep a confirmed like visible when its count refresh fails, and update comments independently of sheet dismissal. |
| `lib/screens/comments/comments_sheet.dart` | Keep the composer above the keyboard, avoid updates after disposal, and report successful posts immediately. Optional service injection permits isolated tests. |
| `lib/services/social_service.dart` | Allow an optional Dio client for contract tests; production requests and payloads are unchanged. |
| `lib/live/live_screen.dart` | Match the Go Live start card/list and live media overlay; refresh the list, initialize existing counts, provide explicit viewer leave/camera controls, preserve camera if microphone fails, and report disconnected live actions. |
| `lib/live/live_preview.dart` | Subscribe only to video in the existing LiveKit room for list previews; do not publish or join the live interaction socket. Dispose previews when navigating into a live. |
| `lib/socket/socket_service.dart` | Allow retrying an existing disconnected socket; keep authentication and room rejoin behavior. |
| `test/social_interactions_test.dart` | Check existing like/comment API contracts, keyboard layout, comment notification before dismissal, and mobile navigation destinations. |
| `APK_FIXES.md` | This file-by-file explanation and device acceptance procedure. |

## Checks

From the `app` directory:

```powershell
flutter analyze --no-pub
flutter test --no-pub
flutter build apk --debug --no-pub --target-platform=android-arm64
```

## Exact device testing steps

1. Keep the computer and phone on the same local network. The checked addresses
   were computer `10.184.130.162`, phone `10.184.130.177`. Restart the existing
   backend after changing `.env` so the media server advertises the new address.
   Start it with `npm start` from `www` if it is not already running.
2. Install `build/app/outputs/flutter-apk/app-debug.apk`. Start TryHub and log in.
   A previously installed APK retains its compiled address until rebuilt and installed.
3. On Home, verify full-screen media and the five bottom navigation destinations.
   Tap the heart on a test post: it should turn pink and update the count. Tap
   again to unlike. Reopen the post and confirm the server state persists.
4. Open comments on that post, open the keyboard, and send a test comment. Check
   that the send control stays visible and the comment appears. Dismiss with
   Android Back or a swipe and confirm the feed count was updated. Verify the
   comment on the web, then verify another comment after reopening the sheet.
5. Open Discover. Verify the Go Live form and Currently Live list. Start a live
   from the web; once the creator enables the camera, its preview should play in
   the app without audio. Tap it to watch with live audio/video.
6. As a viewer, send a live like and comment, and verify them on the creator's web
   screen. Use Leave Live, rejoin, then close the viewer app: the creator should
   keep broadcasting. Temporarily interrupt Wi-Fi and retry after reconnecting.
7. Start another live from the app. Tap Enable camera and grant camera/microphone
   permissions. Verify video/audio from a second device using the web. End Live
   as the creator and confirm viewers see the ended state.
8. Open Profile, Messages, and Upload through bottom navigation. Return Home and
   verify feed playback resumes. Account and settings at the top left still
   provides Wallet, Notifications, and Log out.

A successful local API request does not prove that LiveKit media ports are reachable.
Cross-device live audio/video and account interactions need the two-device checks
above. If Wi-Fi changes the computer's IP again, update local configuration or use
existing `--dart-define` endpoint overrides and rebuild; no public server is assumed.
