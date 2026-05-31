import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../data/repositories/auth_repository.dart';
import '../../shared/widgets/app_button.dart';
import '../../state/auth_provider.dart';
import '../dashboard/dashboard_screen.dart';
import '_auth_layout.dart';
import 'profile_setup_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _submitting = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _showForgotPassword() async {
    final controller = TextEditingController(text: _email.text);
    String? emailToReset;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(2)),
        ),
        title: Text('Reset password', style: AppText.title(size: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your email and we\'ll send a reset link.',
              style: AppText.body(color: AppColors.inkMuted, size: 13.5),
            ),
            const SizedBox(height: 16),
            // Plain TextFormField — no inherited theme issues
            TextField(
              controller: controller,
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
              style: AppText.body(color: AppColors.ink, size: 15),
              cursorColor: AppColors.maroon,
              decoration: InputDecoration(
                hintText: 'your@email.com',
                hintStyle: AppText.body(color: AppColors.inkFaint, size: 15),
                filled: true,
                fillColor: AppColors.surfaceMuted,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(2)),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(2)),
                  borderSide: BorderSide(color: AppColors.maroon, width: 1.5),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel',
                style: AppText.button(color: AppColors.inkMuted, size: 13)),
          ),
          TextButton(
            onPressed: () {
              emailToReset = controller.text.trim();
              Navigator.of(ctx).pop();
            },
            child: Text('Send link',
                style: AppText.button(color: AppColors.maroon, size: 13)),
          ),
        ],
      ),
    );

    controller.dispose();

    if (emailToReset != null && emailToReset!.isNotEmpty && mounted) {
      final ok = await context.read<AuthProvider>().sendPasswordReset(emailToReset!);
      if (mounted) {
        _snack(ok
            ? 'Reset link sent — check your email'
            : 'Could not send link — check the email address');
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final auth = context.read<AuthProvider>();
    final res = await auth.logIn(email: _email.text, password: _password.text);
    if (!mounted) return;
    setState(() => _submitting = false);

    switch (res.outcome) {
      case AuthOutcome.success:
        final next = auth.needsProfileSetup
            ? const ProfileSetupScreen(fromSignup: true)
            : const DashboardScreen();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => next),
          (_) => false,
        );
        break;
      case AuthOutcome.unknownEmail:
        _snack('No account found for that email');
        break;
      case AuthOutcome.invalidCredentials:
        _snack(res.message ?? 'Incorrect email or password');
        break;
      case AuthOutcome.networkError:
        _snack(res.message ?? 'Network error — check your connection');
        break;
      default:
        _snack(res.message ?? 'Something went wrong');
    }
  }

  void _snack(String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Login',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DarkFormField(
              controller: _email,
              hint: 'Email',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: Validators.email,
            ),
            const SizedBox(height: 14),
            DarkFormField(
              controller: _password,
              hint: 'Password',
              obscure: _obscure,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              validator: Validators.password,
              suffix: IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  size: 18,
                  color: AppColors.inkMuted,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: _showForgotPassword,
                child: Text(
                  'Forgot password?',
                  style: AppText.body(color: AppColors.onMaroonMuted, size: 13)
                      .copyWith(decoration: TextDecoration.underline),
                ),
              ),
            ),
            const SizedBox(height: 26),
            AppButton(
              label: _submitting ? 'Signing in' : 'Log In',
              kind: AppButtonKind.onDark,
              onPressed: _submitting ? null : _submit,
              loading: _submitting,
            ),
          ],
        ),
      ),
      footer: Column(
        children: [
          Text(
            "Don't have an account?",
            style: AppText.body(color: AppColors.onMaroonMuted, size: 13),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SignupScreen()),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.onMaroon,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(2)),
                side: BorderSide(color: AppColors.onMaroonMuted, width: 1),
              ),
            ),
            child: Text(
              'SIGN UP',
              style: AppText.button(color: AppColors.onMaroon, size: 13)
                  .copyWith(letterSpacing: 1.8),
            ),
          ),
        ],
      ),
    );
  }
}