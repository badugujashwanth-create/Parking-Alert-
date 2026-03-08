import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../features/vehicles/models/vehicle.dart';

class VehicleService {
  VehicleService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _vehiclesCollection(String uid) {
    return _firestore.collection('users').doc(uid).collection('vehicles');
  }

  CollectionReference<Map<String, dynamic>> get _qrCollection => _firestore.collection('qr');

  Stream<List<Vehicle>> watchVehicles(String uid) {
    return _vehiclesCollection(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Vehicle.fromDocument).toList());
  }

  Stream<Vehicle?> watchVehicle(String uid, String vehicleId) {
    return _vehiclesCollection(uid).doc(vehicleId).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return Vehicle.fromDocument(snapshot);
    });
  }

  Future<void> addVehicle({
    required String uid,
    required String vehicleNumber,
    required String city,
  }) async {
    final vehicleRef = _vehiclesCollection(uid).doc();
    final normalizedNumber = vehicleNumber.trim().toUpperCase();
    final normalizedCity = city.trim();
    const maxAttempts = 5;
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      final qrId = _generateQrId();
      final qrRef = _qrCollection.doc(qrId);
      try {
        await _firestore.runTransaction((transaction) async {
          final qrSnapshot = await transaction.get(qrRef);
          if (qrSnapshot.exists) {
            throw const _QrCollisionException();
          }
          final now = FieldValue.serverTimestamp();
          transaction.set(qrRef, {
            'qrId': qrId,
            'vehicleId': vehicleRef.id,
            'ownerUid': uid,
            'isActive': true,
            'createdAt': now,
          });
          transaction.set(vehicleRef, {
            'vehicleId': vehicleRef.id,
            'ownerUid': uid,
            'vehicleNumber': normalizedNumber,
            'city': normalizedCity,
            'createdAt': now,
            'updatedAt': now,
            'status': 'active',
            'qrId': qrId,
            'qrActive': true,
            'lastScannedAt': null,
          });
        });
        return;
      } on _QrCollisionException {
        continue;
      }
    }
    throw Exception('Unable to generate a unique QR ID. Please try again.');
  }

  Future<void> toggleQrActive({
    required String uid,
    required String vehicleId,
    required String qrId,
    required bool isActive,
  }) async {
    final batch = _firestore.batch();
    final vehicleRef = _vehiclesCollection(uid).doc(vehicleId);
    final qrRef = _qrCollection.doc(qrId);
    batch.update(vehicleRef, {
      'qrActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.update(qrRef, {
      'isActive': isActive,
    });
    await batch.commit();
  }

  Future<void> updateVehicleStatus({
    required String uid,
    required String vehicleId,
    required String qrId,
    required bool isActiveStatus,
  }) async {
    final status = isActiveStatus ? 'active' : 'disabled';
    final batch = _firestore.batch();
    final vehicleRef = _vehiclesCollection(uid).doc(vehicleId);
    final qrRef = _qrCollection.doc(qrId);
    batch.update(vehicleRef, {
      'status': status,
      'qrActive': isActiveStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.update(qrRef, {
      'isActive': isActiveStatus,
    });
    await batch.commit();
  }

  String _generateQrId({int length = 18}) {
    const alphabet = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
    final random = Random.secure();
    final buffer = StringBuffer();
    for (var i = 0; i < length; i++) {
      buffer.write(alphabet[random.nextInt(alphabet.length)]);
    }
    return buffer.toString();
  }
}

class _QrCollisionException implements Exception {
  const _QrCollisionException();
}
