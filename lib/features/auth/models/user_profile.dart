import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  const UserProfile({
    required this.uid,
    required this.phoneNumber,
    this.createdAt,
    this.lastLoginAt,
    this.displayName = '',
    this.city = '',
    this.isQuietHoursEnabled = false,
    this.quietHoursStart = '22:00',
    this.quietHoursEnd = '07:00',
  });

  final String uid;
  final String phoneNumber;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;
  final String displayName;
  final String city;
  final bool isQuietHoursEnabled;
  final String quietHoursStart;
  final String quietHoursEnd;

  factory UserProfile.fromDocument(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    final created = (data?['createdAt'] as Timestamp?)?.toDate();
    final lastLogin = (data?['lastLoginAt'] as Timestamp?)?.toDate();
    return UserProfile(
      uid: snapshot.id,
      phoneNumber: data?['phoneNumber'] ?? '',
      createdAt: created,
      lastLoginAt: lastLogin,
      displayName: data?['displayName'] ?? '',
      city: data?['city'] ?? '',
      isQuietHoursEnabled: data?['isQuietHoursEnabled'] ?? false,
      quietHoursStart: data?['quietHoursStart'] ?? '22:00',
      quietHoursEnd: data?['quietHoursEnd'] ?? '07:00',
    );
  }
}
