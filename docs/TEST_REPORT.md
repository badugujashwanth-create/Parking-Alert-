# Test report

Audit date: 2026-07-21

Branch: `phase4-parkalert-security-completion`

## Targeted evidence

| Check | Result | Evidence |
|---|---|---|
| Flutter analysis | Pass | No issues after safe lifecycle and fail-closed client changes |
| Flutter tests | Pass | 5 tests: local lifecycle, disabled precondition, validators, rules structure, and no direct alert writes |
| Release web build | Pass | `flutter build web --release --dart-define=DEMO_MODE=true` |
| Diff integrity | Pass | `git diff --check` |
| Secret pattern scan | Pass | No Firebase, private-key, AWS, GitHub-token, or Slack-token pattern in the candidate tree |
| Media verification | Pass | 3:08.6 MP4/WebM, 1280×720, narrated audio, 7 cues, inspected frames, matching SHA-256 manifest |
| Real Firebase | Not run | No owner-approved local configuration or console evidence |
| Rules deployment | Not claimed | `firestore.rules` is reference configuration only |
| Notifications/devices | Not run | Owned-device and backend evidence required |

## Final repository gate

The candidate passed Flutter analysis, all 5 tests, and the credential-free release web build locally. The final MP4 and WebM are 1280×720, include audible narration, run for 188.6 seconds, have 7 caption cues, and were inspected at representative frames across the workflow. Secret and repository-diff checks are recorded before handoff; CI remains a pull-request check rather than a release authorization.

External Firebase and device gates remain excluded rather than inferred from green repository checks.
