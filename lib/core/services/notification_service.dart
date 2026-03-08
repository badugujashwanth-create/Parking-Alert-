import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  NotificationService({
    FirebaseMessaging? messaging,
    FirebaseFirestore? firestore,
  })  : _messaging = messaging ?? FirebaseMessaging.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseMessaging _messaging;
  final FirebaseFirestore _firestore;
  StreamSubscription<String?>? _tokenSub;

  CollectionReference<Map<String, dynamic>> _tokenCollection(String uid) {
    return _firestore.collection('users').doc(uid).collection('tokens');
  }

  String _platform() {
    if (kIsWeb) return 'web';
    var label = 'unknown';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        label = 'android';
        break;
      case TargetPlatform.iOS:
        label = 'ios';
        break;
      case TargetPlatform.macOS:
        label = 'macos';
        break;
      case TargetPlatform.fuchsia:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        label = 'desktop';
        break;
    }
    return label;
  }

  Future<void> registerToken(String uid) async {
    final settings = await _messaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      return;
    }

    await _storeToken(uid);

    _tokenSub = _messaging.onTokenRefresh.listen((token) async {
      await _storeToken(uid, token: token);
    });
  }

  Future<void> _storeToken(String uid, {String? token}) async {
    final resolvedToken = token ?? await _messaging.getToken();
    if (resolvedToken == null) return;
    final doc = _tokenCollection(uid).doc(resolvedToken);
    await doc.set({
      'token': resolvedToken,
      'platform': _platform(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  void dispose() {
    _tokenSub?.cancel();
  }
}
