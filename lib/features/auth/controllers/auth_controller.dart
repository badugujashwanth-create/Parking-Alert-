import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/user_service.dart';

class AuthController extends ChangeNotifier {
  AuthController({
    required AuthService authService,
    required UserService userService,
    required NotificationService notificationService,
  })  : _authService = authService,
        _userService = userService,
        _notificationService = notificationService;

  static const _cooldownSeconds = 30;

  final AuthService _authService;
  final UserService _userService;
  final NotificationService _notificationService;

  Timer? _cooldownTimer;
  int _cooldownRemaining = 0;
  bool _isSending = false;
  bool _isVerifying = false;
  String? _verificationId;
  int? _forceResendingToken;

  bool get isSendingOtp => _isSending;
  bool get isVerifyingOtp => _isVerifying;
  int get cooldownRemaining => _cooldownRemaining;
  bool get isCooldownActive => _cooldownRemaining > 0;
  bool get canRequestOtp => !_isSending && _cooldownRemaining == 0;

  Stream<User?> get authState => _authService.authStateChanges();

  User? get currentUser => _authService.currentUser;

  Future<void> sendOtp(String phoneNumber) async {
    if (_isSending) {
      throw const AuthFlowException('Still sending OTP. Please wait a moment.');
    }
    if (_cooldownRemaining > 0) {
      throw AuthFlowException('Please wait $cooldownRemaining seconds before requesting a new OTP.');
    }

    _isSending = true;
    notifyListeners();

    final completer = Completer<void>();
    try {
      await _authService.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        forceResendingToken: _forceResendingToken,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (credential) async {
          await _handleCredential(credential);
          if (!completer.isCompleted) {
            completer.complete();
          }
        },
        verificationFailed: (exception) {
          _completeWithError(exception, completer);
        },
        codeSent: (verificationId, forceResendingToken) {
          _verificationId = verificationId;
          _forceResendingToken = forceResendingToken;
          _startCooldown();
          if (!completer.isCompleted) {
            completer.complete();
          }
        },
        codeAutoRetrievalTimeout: (verificationId) {
          _verificationId = verificationId;
        },
      );
      await completer.future;
    } on AuthFlowException {
      rethrow;
    } catch (_) {
      if (!completer.isCompleted) {
        completer.completeError(const AuthFlowException('Unable to send OTP. Please try again.'));
      }
      throw const AuthFlowException('Unable to send OTP. Please try again.');
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  Future<void> verifyOtp(String smsCode) async {
    if (_verificationId == null) {
      throw AuthFlowException('Verification ID is missing. Request a new code.');
    }

    _isVerifying = true;
    notifyListeners();
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );
      await _handleCredential(credential);
    } on FirebaseAuthException catch (exception) {
      throw AuthFlowException(_errorMessageForCode(exception));
    } catch (_) {
      throw AuthFlowException('Unable to verify OTP. Please try again.');
    } finally {
      _isVerifying = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    _verificationId = null;
    _forceResendingToken = null;
    _stopCooldown();
    notifyListeners();
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    _cooldownRemaining = _cooldownSeconds;
    notifyListeners();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _cooldownRemaining--;
      if (_cooldownRemaining <= 0) {
        _stopCooldown();
      } else {
        notifyListeners();
      }
    });
  }

  void _stopCooldown() {
    _cooldownTimer?.cancel();
    _cooldownTimer = null;
    _cooldownRemaining = 0;
    notifyListeners();
  }

  Future<void> _handleCredential(AuthCredential credential) async {
    final userCredential = await _authService.signInWithCredential(credential);
    final user = userCredential.user;
    if (user == null) {
      throw AuthFlowException('Unable to read authenticated user.');
    }
    await _userService.createOrUpdateProfile(user);
    await _notificationService.registerToken(user.uid);
  }

  void _completeWithError(FirebaseAuthException exception, Completer<void> completer) {
    if (!completer.isCompleted) {
      completer.completeError(AuthFlowException(_errorMessageForCode(exception)));
    }
  }

  String _errorMessageForCode(FirebaseAuthException exception) {
    switch (exception.code) {
      case 'invalid-phone-number':
        return 'The phone number is invalid. Double-check and try again.';
      case 'invalid-verification-code':
        return 'The OTP you entered is invalid.';
      case 'session-expired':
        return 'The OTP has expired. Request a new one.';
      case 'too-many-requests':
        return 'Too many requests. Please wait before trying again.';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Try again later.';
      case 'network-request-failed':
        return 'Network issue. Check your connection.';
      default:
        return exception.message ?? 'Authentication failed. Please try again.';
    }
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _notificationService.dispose();
    super.dispose();
  }
}

class AuthFlowException implements Exception {
  const AuthFlowException(this.message);

  final String message;

  @override
  String toString() => message;
}
