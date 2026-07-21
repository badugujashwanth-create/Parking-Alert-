# Development guide

## Safe local workflow

Requires Flutter stable.

```powershell
flutter pub get
flutter run -d chrome --dart-define=DEMO_MODE=true
```

The demo uses synthetic fixtures and no credential.

## Verify

```powershell
flutter analyze
flutter test
flutter build web --release --dart-define=DEMO_MODE=true
```

Do not generate or commit Firebase platform files while working on the local simulation. Real-service development requires an owner-approved separate environment and the gates in [../PROJECT_COMPLETION_REPORT.md](../PROJECT_COMPLETION_REPORT.md).
