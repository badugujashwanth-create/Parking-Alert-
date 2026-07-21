import 'package:cloud_firestore/cloud_firestore.dart';

import '../../features/scan/models/scan_preview.dart';

class ScanService {
  ScanService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<ScanPreview> loadPreview(String qrId) async {
    final snapshot = await _firestore.collection('qr').doc(qrId).get();
    if (!snapshot.exists) {
      throw ScanException('invalid_qr', 'QR not recognized');
    }
    final data = snapshot.data();
    final ownerUid = data?['ownerUid'] as String?;
    final vehicleId = data?['vehicleId'] as String?;
    final isActive = data?['isActive'] as bool? ?? true;
    if (ownerUid == null || vehicleId == null) {
      throw ScanException('invalid_qr', 'QR metadata is malformed');
    }
    if (!isActive) {
      throw ScanException('qr_disabled', 'Owner disabled this QR');
    }
    return ScanPreview(
      qrId: qrId,
      ownerUid: ownerUid,
      vehicleId: vehicleId,
      vehicleNumber: data?['vehicleLabel'] as String? ?? 'Private vehicle',
      city: '',
      qrActive: isActive,
    );
  }

  Future<void> recordAlert({
    required ScanPreview preview,
    required String reason,
    String? note,
    required String scannerDeviceId,
    String? scannerPhone,
    String? appVersion,
  }) async {
    throw const ScanException(
      'trusted_backend_required',
      'Alert delivery is disabled until an owner-verified backend, rules, App Check, and abuse controls are deployed.',
    );
  }
}

class ScanException implements Exception {
  const ScanException(this.code, this.message);

  final String code;
  final String message;
}
