import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/routing/app_routes.dart';
import '../controllers/auth_controller.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key, required this.phoneNumber});

  final String phoneNumber;

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _verify(AuthController controller) async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final otp = _otpController.text.trim();
    try {
      await controller.verifyOtp(otp);
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (_) => false);
    } on AuthFlowException catch (exception) {
      _showMessage(exception.message);
    } catch (_) {
      _showMessage('Unable to verify OTP. Please try again.');
    }
  }

  Future<void> _resend(AuthController controller) async {
    try {
      await controller.sendOtp(widget.phoneNumber);
      _showMessage(AppStrings.otpResentMessage);
    } on AuthFlowException catch (exception) {
      _showMessage(exception.message);
    } catch (_) {
      _showMessage('Unable to resend OTP. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AuthController>();
    final isVerifying = controller.isVerifyingOtp;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.otpTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppStrings.otpSubtitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              widget.phoneNumber,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                textInputAction: TextInputAction.done,
                maxLength: 6,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: AppStrings.otpFieldLabel,
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (value) {
                  if (value == null || value.trim().length != 6) {
                    return 'Enter the 6-digit code';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isVerifying ? null : () => _verify(controller),
              child: isVerifying
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(AppStrings.verifyOtp),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: controller.canRequestOtp ? () => _resend(controller) : null,
              child: const Text(AppStrings.resendOtp),
            ),
            if (controller.isCooldownActive)
              Text(
                AppStrings.otpCooldownMessage.replaceFirst('{seconds}', '${controller.cooldownRemaining}'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}
