import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();
  final FirebaseAuth auth = FirebaseAuth.instance;

  User? get currentUser => auth.currentUser;
  Future<void> signOut() => auth.signOut();
}

class FirestoreService {
  FirestoreService._();

  static final FirestoreService instance = FirestoreService._();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
}

class MessagingService {
  MessagingService._();

  static final MessagingService instance = MessagingService._();
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future<void> requestPermissions() => messaging.requestPermission();
}
