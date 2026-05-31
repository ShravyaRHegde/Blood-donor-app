import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../shared/widgets/app_button.dart';
import '../../state/auth_provider.dart';
import '_auth_layout.dart';
import '../../core/theme/app_text_styles.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _submitting = false;
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final ok = await context.read<AuthProvider>().sendPasswordReset(_email.text.trim());
    if (!mounted) return;
    setState(() {
      _submitting = false;
      _sent = ok;
    });
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not send link — check the email address')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Reset\nPassword',
      showBack: true,
      child: _sent
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.mark_email_read_outlined,
                    size: 48, color: AppColors.onMaroon),
                const SizedBox(height: 16),
                Text(
                  'Check your email for a reset link.',
                  style: AppText.body(color: AppColors.onMaroonMuted),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: 'Back to Login',
                  kind: AppButtonKind.onDark,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            )
          : Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DarkFormField(
                    controller: _email,
                    hint: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 26),
                  AppButton(
                    label: _submitting ? 'Sending...' : 'Send Reset Link',
                    kind: AppButtonKind.onDark,
                    onPressed: _submitting ? null : _submit,
                    loading: _submitting,
                  ),
                ],
              ),
            ),
      footer: const SizedBox.shrink(),
    );
  }
}