# Development guide

## Purpose

Flutter parking-contact prototype using QR-mediated alerts, privacy-aware demo data, Firebase services, and optional Cloud Functions.

## Prerequisites

Flutter/Dart, Firebase Auth/Firestore/Messaging/Analytics, TypeScript Cloud Functions.

## Install

```powershell
flutter pub get
```

## Run

```powershell
flutter run --dart-define=DEMO_MODE=true
```

## Verify

- Tests: `flutter analyze; flutter test`
- Build: `Flutter platform build (not executed in this audit)`

See [TEST_REPORT.md](TEST_REPORT.md) for the latest audited results. Copy example environment files instead of committing real values. Generated dependencies, caches, logs, databases, and build output must remain untracked.

