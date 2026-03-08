import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/services/user_service.dart';
import '../models/user_profile.dart';

class UserController extends ChangeNotifier {
  UserController({required UserService userService}) : _userService = userService;

  final UserService _userService;

  StreamSubscription<UserProfile>? _subscription;
  UserProfile? _profile;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;
  String? _trackedUid;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _error;

  Future<void> loadProfile(String uid) async {
    if (_trackedUid == uid && _subscription != null) {
      return;
    }

    _subscription?.cancel();
    _trackedUid = uid;
    _isLoading = true;
    _error = null;
    notifyListeners();

    _subscription = _userService.watchProfile(uid).listen(
      (profile) {
        _profile = profile;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> updateSettings({
    required String uid,
    bool? isQuietHoursEnabled,
    String? quietHoursStart,
    String? quietHoursEnd,
  }) async {
    if (uid.isEmpty) return;
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      await _userService.updateSettings(
        uid: uid,
        isQuietHoursEnabled: isQuietHoursEnabled,
        quietHoursStart: quietHoursStart,
        quietHoursEnd: quietHoursEnd,
      );
    } catch (error) {
      _error = error.toString();
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
