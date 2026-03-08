import 'package:cloud_firestore/cloud_firestore.dart';

import '../../features/alerts/models/alert_item.dart';

class AlertService {
  AlertService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _blocksCollection(String uid) {
    return _firestore.collection('users').doc(uid).collection('blocks');
  }

  CollectionReference<Map<String, dynamic>> _alertsCollection(String uid) {
    return _firestore.collection('users').doc(uid).collection('alerts');
  }

  Stream<List<AlertItem>> watchAlerts(String uid, {String? status}) {
    Query<Map<String, dynamic>> query = _alertsCollection(uid).orderBy('createdAt', descending: true);
    if (status != null && status.isNotEmpty && status != 'all') {
      query = query.where('status', isEqualTo: status);
    }
    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map(AlertItem.fromDocument)
          .where((alert) => !alert.isDeleted)
          .toList();
    });
  }

  Stream<int> watchNewCount(String uid) {
    return _alertsCollection(uid)
        .where('status', isEqualTo: 'new')
        .snapshots()
        .map((snapshot) => snapshot.docs.where((doc) {
              final data = doc.data();
              return !(data['isDeleted'] ?? false);
            }).length);
  }

  Stream<AlertItem?> watchAlert(String uid, String alertId) {
    return _alertsCollection(uid).doc(alertId).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return AlertItem.fromDocument(snapshot);
    });
  }

  Future<void> resolveAlert({
    required String uid,
    required String alertId,
    String? ownerNote,
  }) async {
    final doc = _alertsCollection(uid).doc(alertId);
    await doc.update({
      'status': 'resolved',
      'resolvedAt': FieldValue.serverTimestamp(),
      'ownerNote': ownerNote ?? '',
    });
  }

  Future<void> updateOwnerNote({
    required String uid,
    required String alertId,
    required String ownerNote,
  }) async {
    final doc = _alertsCollection(uid).doc(alertId);
    await doc.update({
      'ownerNote': ownerNote,
    });
  }

  Future<void> deleteAlert({
    required String uid,
    required String alertId,
  }) async {
    final doc = _alertsCollection(uid).doc(alertId);
    await doc.update({
      'isDeleted': true,
      'deletedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> blockScanner({
    required String uid,
    required String type,
    required String value,
  }) async {
    final doc = _blocksCollection(uid).doc();
    await doc.set({
      'blockId': doc.id,
      'type': type,
      'value': value,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
