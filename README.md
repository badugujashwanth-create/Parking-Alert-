# ParkAlert India

[![Watch the ParkAlert India demo](https://jashwanth-portfolio-ten.vercel.app/media/parkalert/poster.png)](https://jashwanth-portfolio-ten.vercel.app/work/parking-alert/)

[Open MP4](https://jashwanth-portfolio-ten.vercel.app/media/parkalert/demo.mp4) · [Download WebM](https://jashwanth-portfolio-ten.vercel.app/media/parkalert/demo.webm) · [Captions](https://jashwanth-portfolio-ten.vercel.app/media/parkalert/demo-captions.vtt)

Day 4 expands the MVP with real QR scanning, audit-friendly scan logs, a push-powered owner inbox, and Firebase Cloud Functions that deliver notifications when an alert arrives.

## Tech stack

- Flutter (stable, Material 3)
- Firebase: `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_messaging`
- Provider for shared state plus services/controllers per feature
- `mobile_scanner` for RT QR scanning
- Firebase Cloud Functions (TypeScript) for the `sendAlertNotification` trigger

## Getting started

1. Open a terminal inside the project root.
2. Fetch packages: `flutter pub get`
3. Start the app: `flutter run`

## Firebase setup (Android & Web)

1. Download `google-services.json` (Android) or `GoogleService-Info.plist` (iOS/Web) and drop it under the respective platform folder.
2. Enable **Phone Authentication** (`Authentication > Sign-in method`) and add Firebase Auth test numbers (e.g., `+91 99999 11111` → code `123456`).
3. Register SHA-1/SHA-256 fingerprints (`./gradlew signingReport` or `flutterfire configure`) in the Firebase console.
4. Enable **Cloud Messaging** (FCM) and configure the Android notification icon:
   - Add `android/app/src/main/res/drawable/ic_notification.xml` (Material icon) or use the default `ic_launcher`.
   - Ensure `android/app/src/main/AndroidManifest.xml` declares `DEFAULT_LIGHT` and permission entries if needed.
5. Deploy Cloud Functions after installing dependencies:
   ```bash
   cd functions
   npm install
   # Deploy the push notification trigger
   firebase deploy --only functions
   ```

## Cloud Functions

- `functions/index.ts` exports `sendAlertNotification`, a Firestore trigger on `users/{ownerUid}/alerts/{alertId}` that reads owner tokens and sends a multicast message via FCM.
- The payload includes `alertId`, `vehicleId`, `qrId`, and `reason`, so the Flutter app can deep-link to the right alert.
- Update the FCM tokens by letting Flutter upload them to `users/{uid}/tokens/{token}` whenever the user logs in (handled inside `NotificationService`).

## Project highlights

- `lib/core/services/scan_service.dart` (plus `ScanController`) resolves QR metadata, validates the QR state, and writes both `scanLogs/{scanId}` and `users/{ownerUid}/alerts/{alertId}` in a transaction.
- `ScanQRScreen` uses `mobile_scanner` to detect QR codes, shows a confirmation sheet (reason/note), respects loading states, and surfaces errors like invalid or disabled QR codes.
- Alerts flow gained filters, swipe-to-resolve/delete, owner notes, and a mark-resolved CTA in `AlertDetailsScreen`.
- Vehicle controls now expose quick QR toggles in the list plus status/last-scanned info inside `QRDisplayScreen`, with batched writes keeping Firestore `qr` + `vehicles` docs consistent.
- `AlertsInboxScreen` and `AlertDetailsScreen` stream alerts, allow owners to view reason/note/scanner identity, and mark alerts as resolved.
- `NotificationService` requests FCM permissions, keeps Firestore tokens in sync, and `ParkAlertApp` listens to `FirebaseMessaging.onMessageOpenedApp` to deep-link to `AlertDetailsScreen`.
- Routing now exposes `/alerts/details` so push taps or deep links can show a specific alert.

## Testing guidance

1. Sign in with a Firebase Auth test phone number (`+91 99999 11111` → `123456`).
2. Switch to the Scan tab, point the camera at `https://parkalert.in/q/<qrId>` or a raw `qrId`, choose a reason/note, and tap **Send Alert**.
3. Verify Firestore:
   - `scanLogs/{scanId}` includes `scannerDeviceId`, `scannerPhone` (if logged in), and `reason`.
   - `users/{ownerUid}/alerts/{alertId}` contains `status: "new"` and the same reason/note.
4. Observe the owner inbox:
   - The Alerts tab displays the incoming alert.
   - Tap it to open `AlertDetailsScreen`, review the scanner identity (masked phone or “Public user”), and mark it resolved.
5. Ensure notifications arrive (app in foreground/background) and tapping a notification routes to the alert details screen. The FCM message payload includes `alertId`.

## Notes

- The scanner keeps a persistent `scannerDeviceId` using `SharedPreferences`, so every alert can be tied to the device even when the user is logged out.
- Quiet hours/sample advanced usage are still on the roadmap (Day 5+), but the basic scan-to-alert flow is end-to-end.
