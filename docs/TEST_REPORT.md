# Test report

Audited on 2026-07-17 using the checked-out `portfolio-polish` branch on Windows.

| Command | Result | Evidence / notes |
|---|---|---|
| `flutter pub get` | Pass | Dependencies resolved |
| `flutter analyze` | Pass | No issues found |
| `GitHub Actions stable Flutter analyze` | Pass with informational warning | Flutter 3.44 reports the existing `Switch.activeColor` deprecation; CI keeps informational diagnostics visible without treating them as errors |
| `flutter test` | Pass | 1 smoke test passed |
| `flutter build web --release --dart-define=DEMO_MODE=true` | Pass | Credential-free demo release bundle generated |

## Overall status

Verified for the commands listed above. Demo mode bypasses Firebase initialization only when explicitly compiled with `DEMO_MODE=true`; real mode still requires local Firebase configuration.

Warnings and missing checks remain limitations, even when another check passes.
