# Security policy

## Supported status

Only the credential-free synthetic simulation is qualified. Real Firebase and notification paths are unsupported and release-blocked.

## Enforced repository boundaries

- Real Firebase platform files stay local and ignored.
- Placeholder configuration contains no usable project identifiers or keys.
- Direct client alert and scan-log writes fail closed.
- Reference Firestore rules deny alert creation, scan-log access, public QR lookup, unknown paths, and cross-user access.
- Synthetic demo data must not contain a real plate, phone number, address, token, QR identifier, or person.

The rules file is not evidence of deployed rules. Firebase Admin SDK code also bypasses Firestore rules and requires a separate review.

## Owner verification required before release

Key rotation/restriction, project ownership, App Check, authorized domains, authentication, deployed rules, backend authorization, quotas/rate limits, token storage, notification delivery, data retention/deletion, logging, and device recovery must be independently evidenced.

## Reporting

Use GitHub private vulnerability reporting when enabled, or an existing verified private owner channel. Never place a secret, token, private URL, real QR, phone number, plate, or personal record in a public issue.

No production support or response-time commitment is implied.
