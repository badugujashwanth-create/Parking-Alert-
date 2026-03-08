import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/routing/app_routes.dart';
import '../controllers/auth_controller.dart';
import '../../../core/utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _phoneController.text = '+91 ';
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String _normalizePhone(String raw) {
    final trimmed = raw.trim();
    final digits = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
    if (trimmed.startsWith('+')) {
      return '+$digits';
    }
    return '+91$digits';
  }

  Future<void> _sendOtp(AuthController controller) async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final phone = _normalizePhone(_phoneController.text);
    FocusScope.of(context).unfocus();

    try {
      await controller.sendOtp(phone);
      if (!mounted) return;
      Navigator.of(context).pushNamed(AppRoutes.otp, arguments: phone);
    } on AuthFlowException catch (exception) {
      _showMessage(exception.message);
    } catch (error) {
      _showMessage('Unable to send OTP. Please try again.');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AuthController>();
    final isSending = controller.isSendingOtp;
    final cooldown = controller.cooldownRemaining;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.loginTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              AppStrings.loginSubtitle,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: AppStrings.loginPhoneHint,
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: Validators.validatePhone,
              ),
            ),
            const SizedBox(height: 16),
            if (controller.isCooldownActive)
              Text(
                AppStrings.otpCooldownMessage.replaceFirst('{seconds}', '$cooldown'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSending || controller.isCooldownActive
                    ? null
                    : () => _sendOtp(controller),
                child: isSending
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(AppStrings.loginSendOtp),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
