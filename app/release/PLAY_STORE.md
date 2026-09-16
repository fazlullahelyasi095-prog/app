# Google Play submission preparation — draft, do not publish

## Listing draft

- App name: TryHub (6 characters; maximum 30).
- Short description: Watch videos, connect with creators, and join live conversations.
- Suggested category: Social. Owner must confirm audience and classification.
- Support email, public website, developer legal identity and privacy-policy URL: pending owner input.

Full description draft (use only for features verified in the signed release):

> Discover creator videos and live conversations on TryHub. Browse your feed,
> follow creators, and share photos and videos from your profile.
>
> Join live rooms, take part in comments, and react to moments you enjoy.
> Connect through messages and share photos or videos in your conversations.
>
> Keep up with activity notifications and manage the creators you follow.
> Report content or block users through the available in-app controls.

Do not advertise push delivery, deposits, withdrawals, guaranteed earnings or coin
purchases: those mobile integrations are not complete. No store listing was created.

## Visual assets

- Store icon: 512 x 512 PNG, up to 1 MB; use approved TryHub artwork. Android launcher icons currently still need final branding review.
- Feature graphic: 1024 x 500 JPEG or 24-bit PNG without alpha.
- At least two actual application screenshots; JPEG or 24-bit PNG, each dimension 320–3840px, maximum dimension no more than twice the minimum. Confirm device-specific requirements for every form factor you distribute.
- Capture suggested phone screenshots: feed, profile, conversation, live room, notifications. Use an actual signed build with consenting test content; conceal real messages, balances and account identifiers. Do not fabricate UI screenshots or represent mockups as working screens.
- Provide localized descriptions/captions for supported listing languages. No screenshots are marked complete while the APK/device test is pending.

Source: [Google preview assets](https://support.google.com/googleplay/android-developer/answer/9866151), [listing guidance](https://support.google.com/googleplay/android-developer/answer/13393723).

## Privacy policy requirements — owner information required

Publish a publicly accessible policy identifying TryHub and the operating legal
entity, support/privacy contact, collection purposes, providers/recipients,
retention, account/data deletion, security measures actually implemented, and
children/age rules. Describe uploaded content, camera/microphone live media,
messages, social actions, ad events and financial history. State actual LiveKit,
hosting and payment-provider arrangements rather than assuming self-hosting.

Link the policy from Google Play AND inside the app. The current registration
checkbox has no readable policy/terms links. These links and accessible terms
must be implemented once the real public documents exist. A blank template is
not a published privacy policy.

Account creation is available. Implement and verify both the in-app deletion
request flow and a public web deletion-request URL against a real backend
contract, including what is deleted and any justified retention. No account
deletion endpoint was found in the inspected user-facing routes. Do not invent
one in Flutter or claim deletion is supported.

Sources: [User data](https://support.google.com/googleplay/android-developer/answer/10144311), [account deletion](https://support.google.com/googleplay/android-developer/answer/13327111).

## Data safety worksheet — not ready for submission

| Data | Evidence in current app | What must be confirmed |
| --- | --- | --- |
| Name/username, email, user ID | Registration/login/profile APIs | Required collection, retention, processors and deletion |
| Photos/video | Profile/post/chat multipart uploads | Storage locations, visibility, moderation and retention |
| Audio/video live media | LiveKit and PK WebRTC | Provider routing, ephemeral handling, recording policy and sharing classification |
| Messages/other user content | Chat/comments/reports | Stored content, recipients, moderation access and deletion |
| App interactions | Likes, follows, ad delivery/impression/click events | Exact events retained and their use for personalization/ads |
| Financial information | Wallet/gift/transaction/earnings APIs | Actual transaction retention; no mobile card-entry flow was found |
| Device/network identifiers | Network requests; device-related transitive plugins | Inspect actual backend/provider logs and SDK behavior; dependency presence alone is not evidence of collection |
| Diagnostics | No dedicated crash-reporting service configured | Decide support workflow; review Play Android vitals and SDK diagnostics |

For each row the owner must establish collected/shared classification, optional
versus required, purposes, ephemeral processing, retention and deletion. Do not
answer “no data collected”, “no sharing”, or “encrypted in transit” without
verifying all production services. HTTPS does not exist yet. Never include JWTs,
passwords, TURN credentials or private keys in screenshots, logs or this form.

## Content and app declarations

- Complete IARC content rating using the actual UGC/live/chat experience.
- Declare ads: the current feed includes backend-served advertisements.
- Confirm intended age groups; do not select children/families just to broaden reach.
- Complete social-app child-safety standards declarations, published standards and safety contact.
- Verify report/block controls in every relevant UGC surface and the actual moderation response process. Admin operations remain web-only.
- Declare app access: provide a functioning restricted reviewer account directly in Play Console, never committed credentials. Include instructions for gated live features.
- Assess financial-features declarations against the shipped wallet/gift behavior. Mobile purchase/payout gaps are not solved by a declaration.
- Before selling digital coins, complete the applicable Play Billing and server verification integration. Do not wire an unverified generic purchase route into checkout.
- Review final merged permissions, SDK disclosures, export-control answers and the actual privacy policy before submission.

Sources: [UGC requirements](https://support.google.com/googleplay/android-developer/answer/9876937), [Developer Programme Policy](https://support.google.com/googleplay/android-developer/answer/17105854).

## Testing tracks — preparation only

1. Register/verify the developer account, confirm the application ID and enroll in Play App Signing. Keep the upload key backed up privately.
2. Once all blockers are resolved, build and verify a signed AAB locally. Upload manually to internal testing only after owner review; this task uploads nothing.
3. Install the Play-delivered build through the opt-in link; run the production checklist, pre-launch report and Android vitals review. Keep test financial activity isolated and explicitly authorized.
4. For personal accounts created after November 13, 2023, current requirements include at least 12 closed-test testers opted in continuously for 14 days before applying for production access. Confirm the requirement shown for the actual account.
5. Record feedback, crashes/ANRs, device coverage, resolved issues and rollback/release notes. Promote only after the owner approves a verified artifact and completed declarations.

Source: [Personal account testing requirements](https://support.google.com/googleplay/android-developer/answer/14151465).
