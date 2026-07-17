# Project Improvement Plan

## Current state

Parking Alert addresses a meaningful mobile safety problem, but its Firebase cloud rules, API-key restrictions, and deployed console configuration cannot be verified from this repository. The release is on security hold.

## Findings

- **Works:** mobile workflow, current-tree secret scan, build-oriented documentation, and one smoke test.
- **Does not / missing:** verified deployed Firebase rules/restrictions, broader notification tests, abuse controls, and device delivery evidence.
- **UX / architecture:** notification/recovery behavior needs device validation; Firebase coupling concentrates trust in external configuration.
- **Testing / security:** a redacted client configuration remains visible in history. Repository cleanup cannot prove console-side restriction.
- **Performance / docs / demo:** notification latency/reliability is unmeasured; safe deployment cannot be asserted.

## Recommendations

### Critical

- Verify Firebase Security Rules, App Check where applicable, authorized domains, key restrictions, and least-privilege console settings before merge/public promotion.
- Rotate/restrict any credential whose history exposure is uncertain.

### High value

- Add emulator-based unauthorized-access and notification state tests.
- Add device recovery evidence for permission denial and delivery failure.

### Optional

- Measure notification latency after the security gate passes.

## Delivery constraints

- **Priority:** blocking security gate; **complexity:** medium; **dependencies:** authorized Firebase console access.
- **Acceptance:** independently captured rules/restriction evidence plus green emulator/build/smoke checks.
- **Excluded:** merging, renaming, or advertising a live deployment while console state is unverified.
