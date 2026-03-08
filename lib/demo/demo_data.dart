enum DemoActivityStatus { success, warning, error }

class DemoUser {
  final String id;
  final String name;
  final String email;
  final String role;
  final DateTime joinedAt;

  const DemoUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.joinedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'joinedAt': joinedAt.toIso8601String(),
      };

  factory DemoUser.fromJson(Map<String, dynamic> data) => DemoUser(
        id: data['id'] as String,
        name: data['name'] as String,
        email: data['email'] as String,
        role: data['role'] as String,
        joinedAt: DateTime.parse(data['joinedAt'] as String),
      );
}

class DemoActivity {
  final DateTime timestamp;
  final String event;
  final DemoActivityStatus status;

  const DemoActivity({
    required this.timestamp,
    required this.event,
    required this.status,
  });
}

enum DemoReportType { summary, compliance, alerts }

class DemoReport {
  final String title;
  final String detail;
  final DemoReportType type;
  final int value;

  const DemoReport({
    required this.title,
    required this.detail,
    required this.type,
    required this.value,
  });
}

class DemoSetting {
  final String key;
  final String label;
  final bool defaultValue;

  const DemoSetting({
    required this.key,
    required this.label,
    required this.defaultValue,
  });
}

class DemoData {
  static final users = <DemoUser>[
    DemoUser(
      id: 'u1',
      name: 'Shivani Patel',
      email: 'shivani@parkalert.in',
      role: 'Operations',
      joinedAt: DateTime.utc(2025, 11, 4),
    ),
    DemoUser(
      id: 'u2',
      name: 'Amar Kulkarni',
      email: 'amar@parkalert.in',
      role: 'Field Agent',
      joinedAt: DateTime.utc(2025, 12, 12),
    ),
    DemoUser(
      id: 'u3',
      name: 'Priya Khanna',
      email: 'priya@parkalert.in',
      role: 'Owner',
      joinedAt: DateTime.utc(2026, 1, 19),
    ),
    DemoUser(
      id: 'u4',
      name: 'Nikhil Rao',
      email: 'nikhil@parkalert.in',
      role: 'Support',
      joinedAt: DateTime.utc(2026, 2, 1),
    ),
  ];

  static final activity = <DemoActivity>[
    DemoActivity(
      timestamp: DateTime.utc(2026, 2, 6, 9, 5),
      event: 'Alert acknowledged',
      status: DemoActivityStatus.success,
    ),
    DemoActivity(
      timestamp: DateTime.utc(2026, 2, 6, 9, 30),
      event: 'Owner notified',
      status: DemoActivityStatus.success,
    ),
    DemoActivity(
      timestamp: DateTime.utc(2026, 2, 6, 10, 4),
      event: 'Field agent dispatched',
      status: DemoActivityStatus.warning,
    ),
    DemoActivity(
      timestamp: DateTime.utc(2026, 2, 6, 10, 32),
      event: 'QR validation',
      status: DemoActivityStatus.success,
    ),
    DemoActivity(
      timestamp: DateTime.utc(2026, 2, 6, 11, 15),
      event: 'Manual override',
      status: DemoActivityStatus.success,
    ),
    DemoActivity(
      timestamp: DateTime.utc(2026, 2, 6, 11, 40),
      event: 'Alert escalated',
      status: DemoActivityStatus.error,
    ),
    DemoActivity(
      timestamp: DateTime.utc(2026, 2, 6, 12, 5),
      event: 'Alert resolved',
      status: DemoActivityStatus.success,
    ),
    DemoActivity(
      timestamp: DateTime.utc(2026, 2, 6, 12, 24),
      event: 'Summary report generated',
      status: DemoActivityStatus.success,
    ),
  ];

  static final reports = <DemoReport>[
    DemoReport(
      title: 'Daily Scan Compliance',
      detail: '97% of expected scans completed today.',
      type: DemoReportType.summary,
      value: 97,
    ),
    DemoReport(
      title: 'Alert Trends',
      detail: '4 new alerts in the last 2 hours.',
      type: DemoReportType.alerts,
      value: 4,
    ),
    DemoReport(
      title: 'Compliance Exceptions',
      detail: '1 alert needs manual review.',
      type: DemoReportType.compliance,
      value: 1,
    ),
  ];

  static final settings = <DemoSetting>[
    DemoSetting(key: 'auto_notify', label: 'Auto-notify owners', defaultValue: true),
    DemoSetting(key: 'quiet_mode', label: 'Enable quiet hours', defaultValue: false),
    DemoSetting(key: 'photo_archive', label: 'Archive alert snapshots', defaultValue: true),
    DemoSetting(key: 'cross_check', label: 'Require cross-check before resolve', defaultValue: false),
  ];
}
