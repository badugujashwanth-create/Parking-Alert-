import 'package:cloud_firestore/cloud_firestore.dart';

class Vehicle {
  const Vehicle({
    required this.vehicleId,
    required this.ownerUid,
    required this.vehicleNumber,
    required this.city,
    required this.status,
    required this.qrId,
    required this.qrActive,
    this.lastScannedAt,
  });

  final String vehicleId;
  final String ownerUid;
  final String vehicleNumber;
  final String city;
  final String status;
  final String qrId;
  final bool qrActive;
  final DateTime? lastScannedAt;

  factory Vehicle.fromDocument(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return Vehicle(
      vehicleId: data?['vehicleId'] ?? snapshot.id,
      ownerUid: data?['ownerUid'] ?? '',
      vehicleNumber: data?['vehicleNumber'] ?? '',
      city: data?['city'] ?? '',
      status: data?['status'] ?? 'active',
      qrId: data?['qrId'] ?? '',
      qrActive: data?['qrActive'] ?? true,
      lastScannedAt: (data?['lastScannedAt'] as Timestamp?)?.toDate(),
    );
  }
}
