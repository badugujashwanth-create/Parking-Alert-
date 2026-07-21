# ParkAlert testing

## Repository-safe checks

```bash
flutter analyze
flutter test
flutter build web --release --dart-define=DEMO_MODE=true
```

The test suite must prove the local simulation and fail-closed client/rules boundaries without a credential or network service.

## External release checklist

The following tests require an owner-approved Firebase project and owned devices. They are not complete:

- emulator denial of unauthenticated, cross-user, QR-list, direct-alert, scan-log, and unknown-path access;
- owned-user vehicle/token/block operations and backend-only alert creation;
- App Check enforcement, authorized domains, key restrictions, quotas, and abuse controls;
- authentication and notification permission denial/recovery;
- token refresh/removal, foreground/background delivery, failure/retry, blocking, and deletion;
- data retention and account deletion;
- latency/reliability measurement only after security approval.

Do not publish a test number, OTP, key, token, plate, QR, or real notification payload as evidence.
