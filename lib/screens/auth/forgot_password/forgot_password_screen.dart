// lib/screens/auth/forgot_password/forgot_password_screen.dart
// Password reset screen — user enters their email and Supabase sends a reset link.
// The link uses the savorlean:// deep link scheme to open the app on the
// password update screen (handled by Supabase automatically via PKCE flow).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/common/app_button.dart';

/// Forgot password screen — sends a Supabase password reset email.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _loading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /// Calls Supabase to send a password reset email.
  /// The redirectTo URL must be registered in the Supabase dashboard
  /// under Authentication → URL Configuration → Redirect URLs.
  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        _emailController.text.trim(),
        // The app will receive this deep link and Supabase handles the token.
        redirectTo: 'savorlean://reset-callback/',
      );
      if (mounted) setState(() => _emailSent = true);
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not send reset email. Please try again.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Reset Password')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          child: _emailSent ? _buildSuccessState() : _buildForm(),
        ),
      ),
    );
  }

  /// Shown after the reset email has been sent successfully.
  Widget _buildSuccessState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(
          Icons.mark_email_read_outlined,
          size: 64,
          color: AppColors.success,
        ),
        const SizedBox(height: 24),
        Text(
          'Check your email',
          textAlign: TextAlign.center,
          style: AppTextStyles.headingBold,
        ),
        const SizedBox(height: 12),
        Text(
          'We sent a password reset link to ${_emailController.text.trim()}. '
          'Tap the link in the email to set a new password.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMuted,
        ),
        const SizedBox(height: 32),
        AppButton(
          label: 'Resend Email',
          variant: AppButtonVariant.secondary,
          onPressed: () => setState(() => _emailSent = false),
          fullWidth: true,
        ),
      ],
    );
  }

  /// The initial email entry form.
  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Enter the email address associated with your account and we\'ll '
            'send you a link to reset your password.',
            style: AppTextStyles.bodyMuted,
          ),
          const SizedBox(height: 32),

          // Email field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _sendResetEmail(),
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'you@example.com',
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email is required';
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) {
                return 'Enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),

          // Send reset link button
          AppButton(
            label: 'Send Reset Link',
            onPressed: _sendResetEmail,
            isLoading: _loading,
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}
