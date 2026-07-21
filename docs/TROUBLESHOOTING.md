# Troubleshooting

## Demo opens the Firebase error screen

Rebuild with the explicit safe flag:

```powershell
flutter run -d chrome --dart-define=DEMO_MODE=true
```

Do not add a real Firebase configuration merely to bypass the error.

## Alert delivery reports `trusted_backend_required`

This is the expected fail-closed result in real mode. No trusted alert backend is included or verified. Use the local simulation; do not weaken rules or restore direct client writes.

## Tests or build fail

Run `flutter pub get`, repair the first actionable error, and rerun the smallest affected command before the complete gate.

## Sensitive configuration

Never paste keys, tokens, QR identifiers, phone numbers, plates, or console screenshots containing private values into an issue or demo. Repository cleanup cannot rotate a historically exposed key.
