import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/routing/app_routes.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/controllers/user_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _disableQR = false;
  String? _appVersion;
  bool _isVersionLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthController>().currentUser?.uid;
      if (uid != null) {
        context.read<UserController>().loadProfile(uid);
      }
    });
    _loadAppVersion();
  }

  TimeOfDay _parseTime(String? value, {TimeOfDay fallback = const TimeOfDay(hour: 0, minute: 0)}) {
    if (value == null || value.isEmpty) {
      return fallback;
    }
    final parts = value.split(':');
    if (parts.length != 2) {
      return fallback;
    }
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? fallback.hour,
      minute: int.tryParse(parts[1]) ?? fallback.minute,
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _updateQuietHours(bool value) async {
    final uid = context.read<AuthController>().currentUser?.uid;
    if (uid == null) return;
    try {
      await context.read<UserController>().updateSettings(
            uid: uid,
            isQuietHoursEnabled: value,
          );
      if (!mounted) return;
      _showMessage(AppStrings.settingsSavedMessage);
    } catch (error) {
      _showMessage(error.toString());
    }
  }

  Future<void> _updateTime({required bool isStart}) async {
    final uid = context.read<AuthController>().currentUser?.uid;
    if (uid == null) return;
    final controller = context.read<UserController>();
    final currentValue = isStart ? controller.profile?.quietHoursStart : controller.profile?.quietHoursEnd;
    final initialTime = _parseTime(currentValue, fallback: const TimeOfDay(hour: 22, minute: 0));
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked == null) return;
    final formatted = _formatTimeOfDay(picked);
    try {
      await controller.updateSettings(
        uid: uid,
        quietHoursStart: isStart ? formatted : null,
        quietHoursEnd: isStart ? null : formatted,
      );
      if (!mounted) return;
      _showMessage(AppStrings.settingsSavedMessage);
    } catch (error) {
      _showMessage(error.toString());
    }
  }

  Future<void> _logout() async {
    try {
      await context.read<AuthController>().logout();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
    } catch (error) {
      _showMessage(error.toString());
    }
  }

  Future<void> _loadAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() {
        _appVersion = '${info.version}+${info.buildNumber}';
        _isVersionLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _appVersion = '--';
        _isVersionLoading = false;
      });
    }
  }

  Future<void> _launchProblemEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: AppStrings.reportProblemEmail,
      queryParameters: {'subject': 'ParkAlert issue'},
    );
    if (!await canLaunchUrl(uri)) {
      _showMessage(AppStrings.reportProblemFailure);
      return;
    }
    await launchUrl(uri);
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userController = context.watch<UserController>();
    final profile = userController.profile;
    final isSaving = userController.isSaving;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (isSaving) const LinearProgressIndicator(),
        SwitchListTile(
          title: const Text(AppStrings.quietHours),
          subtitle: const Text(AppStrings.quietHoursDescription),
          value: profile?.isQuietHoursEnabled ?? false,
          onChanged: (value) => _updateQuietHours(value),
        ),
        ListTile(
          title: const Text(AppStrings.quietHoursStartLabel),
          subtitle: Text(profile?.quietHoursStart ?? '--:--'),
          trailing: const Icon(Icons.access_time),
          onTap: () => _updateTime(isStart: true),
        ),
        ListTile(
          title: const Text(AppStrings.quietHoursEndLabel),
          subtitle: Text(profile?.quietHoursEnd ?? '--:--'),
          trailing: const Icon(Icons.access_time),
          onTap: () => _updateTime(isStart: false),
        ),
        SwitchListTile(
          title: const Text(AppStrings.disableQr),
          subtitle: const Text(AppStrings.disableQrPlaceholder),
          value: _disableQR,
          onChanged: (value) => setState(() => _disableQR = value),
        ),
        const SizedBox(height: 16),
        ListTile(
          title: const Text(AppStrings.appVersionLabel),
          subtitle: Text(
            _isVersionLoading ? 'Loading...' : (_appVersion ?? '--'),
          ),
        ),
        ListTile(
          title: const Text(AppStrings.howItWorksTitle),
          subtitle: const Text(AppStrings.howItWorksSubtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.howItWorks),
        ),
        ListTile(
          leading: const Icon(Icons.email),
          title: const Text(AppStrings.reportProblem),
          subtitle: Text(AppStrings.reportProblemEmail),
          onTap: _launchProblemEmail,
        ),
        const SizedBox(height: 16),
        ListTile(
          onTap: _logout,
          leading: const Icon(Icons.logout),
          title: const Text(AppStrings.settingsLogout),
        ),
      ],
    );
  }
}
