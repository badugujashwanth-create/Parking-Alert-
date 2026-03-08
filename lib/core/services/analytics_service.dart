import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  AnalyticsService({FirebaseAnalytics? analytics})
      : _analytics = analytics ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;

  Future<void> logVehicleAdded() => _logEvent('vehicle_added');
  Future<void> logQrViewed() => _logEvent('qr_viewed');
  Future<void> logScanStarted() => _logEvent('scan_started');
  Future<void> logAlertSent({required String reason}) =>
      _logEvent('alert_sent', parameters: {'reason': reason});
  Future<void> logAlertReceived() => _logEvent('alert_received');
  Future<void> logAlertResolved({String? reason}) =>
      _logEvent('alert_resolved', parameters: reason == null ? null : {'reason': reason});
  Future<void> logRateLimited() => _logEvent('rate_limited');
  Future<void> logQuietHoursSuppressed() => _logEvent('quiet_hours_suppressed');
  Future<void> logSmsFallbackSent() => _logEvent('sms_fallback_sent');

  Future<void> _logEvent(String name, {Map<String, Object>? parameters}) {
    return _analytics.logEvent(name: name, parameters: parameters);
  }
}
