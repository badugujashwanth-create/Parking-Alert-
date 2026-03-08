import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../features/scan/models/scan_preview.dart';

class ScanService {
  ScanService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();

  CollectionReference<Map<String, dynamic>> _vehiclesCollection(String uid) {
    return _firestore.collection('users').doc(uid).collection('vehicles');
  }

  CollectionReference<Map<String, dynamic>> get _scanLogs => _firestore.collection('scanLogs');

  CollectionReference<Map<String, dynamic>> _alertsCollection(String uid) {
    return _firestore.collection('users').doc(uid).collection('alerts');
  }

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
    final vehicleSnapshot = await _vehiclesCollection(ownerUid).doc(vehicleId).get();
    if (!vehicleSnapshot.exists) {
      throw ScanException('invalid_vehicle', 'Vehicle not found');
    }
    final vehicleData = vehicleSnapshot.data();
    return ScanPreview(
      qrId: qrId,
      ownerUid: ownerUid,
      vehicleId: vehicleId,
      vehicleNumber: vehicleData?['vehicleNumber'] ?? '',
      city: vehicleData?['city'] ?? '',
      qrActive: vehicleData?['qrActive'] as bool? ?? true,
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
    final scanId = _uuid.v4();
    final alertId = _uuid.v4();
    final now = FieldValue.serverTimestamp();
    final scanRef = _scanLogs.doc(scanId);
    final alertRef = _alertsCollection(preview.ownerUid).doc(alertId);
    await _firestore.runTransaction((transaction) async {
      transaction.set(scanRef, {
        'scanId': scanId,
        'qrId': preview.qrId,
        'vehicleId': preview.vehicleId,
        'ownerUid': preview.ownerUid,
        'reason': reason,
        'note': note ?? '',
        'createdAt': now,
        'scannerDeviceId': scannerDeviceId,
        'scannerPhone': scannerPhone,
        'appVersion': appVersion,
      });
      transaction.set(alertRef, {
        'alertId': alertId,
        'scanId': scanId,
        'vehicleId': preview.vehicleId,
        'qrId': preview.qrId,
        'reason': reason,
        'note': note ?? '',
        'status': 'new',
        'createdAt': now,
        'resolvedAt': null,
        'ownerNote': '',
        'scannerDeviceId': scannerDeviceId,
        'isDeleted': false,
      });
    });
  }
}

class ScanException implements Exception {
  const ScanException(this.code, this.message);

  final String code;
  final String message;
}
