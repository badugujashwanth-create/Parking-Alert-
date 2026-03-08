import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../features/auth/models/user_profile.dart';

class UserService {
  UserService({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _usersCollection => _firestore.collection('users');

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) => _usersCollection.doc(uid);

  Future<void> createOrUpdateProfile(User user) async {
    final doc = _userDoc(user.uid);
    final snapshot = await doc.get();
    final now = FieldValue.serverTimestamp();
    if (!snapshot.exists) {
      await doc.set({
        'uid': user.uid,
        'phoneNumber': user.phoneNumber ?? '',
        'createdAt': now,
        'lastLoginAt': now,
        'displayName': '',
        'city': '',
        'isQuietHoursEnabled': false,
        'quietHoursStart': '22:00',
        'quietHoursEnd': '07:00',
      });
    } else {
      await doc.update({
        'lastLoginAt': now,
      });
    }
  }

  Stream<UserProfile> watchProfile(String uid) {
    return _userDoc(uid).snapshots().map(UserProfile.fromDocument);
  }

  Future<void> updateSettings({
    required String uid,
    bool? isQuietHoursEnabled,
    String? quietHoursStart,
    String? quietHoursEnd,
  }) async {
    final payload = <String, dynamic>{};
    if (isQuietHoursEnabled != null) {
      payload['isQuietHoursEnabled'] = isQuietHoursEnabled;
    }
    if (quietHoursStart != null) {
      payload['quietHoursStart'] = quietHoursStart;
    }
    if (quietHoursEnd != null) {
      payload['quietHoursEnd'] = quietHoursEnd;
    }
    if (payload.isEmpty) {
      return;
    }
    await _userDoc(uid).set(payload, SetOptions(merge: true));
  }
}
