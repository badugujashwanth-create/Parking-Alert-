import 'package:cloud_firestore/cloud_firestore.dart';

class AlertItem {
  const AlertItem({
    required this.alertId,
    required this.scanId,
    required this.vehicleId,
    required this.qrId,
    required this.reason,
    required this.status,
    this.note,
    this.createdAt,
    this.resolvedAt,
    this.ownerNote,
    this.scannerPhone,
    this.scannerDeviceId,
    this.isDeleted = false,
  });

  final String alertId;
  final String scanId;
  final String vehicleId;
  final String qrId;
  final String reason;
  final String status;
  final String? note;
  final DateTime? createdAt;
  final DateTime? resolvedAt;
  final String? ownerNote;
  final String? scannerPhone;
  final String? scannerDeviceId;
  final bool isDeleted;

  factory AlertItem.fromDocument(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return AlertItem(
      alertId: data?['alertId'] ?? snapshot.id,
      scanId: data?['scanId'] ?? '',
      vehicleId: data?['vehicleId'] ?? '',
      qrId: data?['qrId'] ?? '',
      reason: data?['reason'] ?? '',
      status: data?['status'] ?? 'new',
      note: data?['note'],
      createdAt: (data?['createdAt'] as Timestamp?)?.toDate(),
      resolvedAt: (data?['resolvedAt'] as Timestamp?)?.toDate(),
      ownerNote: data?['ownerNote'],
      scannerPhone: data?['scannerPhone'],
      scannerDeviceId: data?['scannerDeviceId'],
      isDeleted: data?['isDeleted'] ?? false,
    );
  }
}
