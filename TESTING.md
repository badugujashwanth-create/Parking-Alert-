# ParkAlert India Testing Checklist

## Happy path tests
1. **Owner login → add vehicle → view QR**
   - Sign in with a valid Indian phone number.
   - Add a vehicle (e.g., `KA 01 AB 1234`) and verify it appears in `My Vehicles`.
   - Open the QR display, confirm the QR renders, and the `qrViewed` analytics event is logged.
2. **Scanner flow → send alert → owner receives → resolves**
   - Scan the QR with a device (or use payload) to trigger the scan confirmation sheet.
   - Select a reason, add an optional note, and send the alert.
   - Verify the alert appears under `users/{ownerUid}/alerts`, the owner receives the notification, and the status can be resolved.
3. **Rate limit enforcement**
   - Trigger two alerts from the same scanner/device for the same QR within 5 minutes.
   - Verify the second attempt fails with `rate_limited` and the analytics event is logged.
4. **Quiet hours suppression**
   - Enable quiet hours on the owner profile (e.g., 22:00–07:00).
   - Use a non-priority reason (e.g., “No Parking”) and confirm the alert is created but notifications are suppressed (check `notifyStatus`).
5. **High priority exception**
   - Send an alert with reason “Fire” or “Ambulance blocked” during quiet hours.
   - Confirm notification (push or SMS) is still dispatched.
6. **Block scanner flows**
   - From the Alert Details screen, block the scanner phone or device.
   - Attempt another alert from the blocked identifier and confirm it fails with `blocked`.

## Negative tests
- **Invalid QR payload**: Scan a random string, ensure the app shows “Invalid QR.”
- **QR disabled**: Toggle QR off on the owner side, then scan the QR to see the disabled warning.
- **No internet**: Put the device in airplane mode before sending the alert and ensure the flow surfaces a network error.
- **Missing notification token**: Remove stored FCM tokens (delete from Firestore) and confirm SMS fallback is triggered when configured.

## Debug checklist
- Clear app data/cache and re-run the app.
- Re-login with the owner phone and verify the profile reloads.
- Inspect Firestore:
  - `users/{uid}/vehicles/{vehicleId}` for `status`/`qrActive`.
  - `users/{uid}/alerts/{alertId}` for `status`, `ownerNote`, `resolvedAt`, and `notifyStatus`.
  - `users/{uid}/blocks/{blockId}` for any scanner blocks.
  - `scanLogs/{scanId}` for scanner metadata and `scannerDeviceId`.
