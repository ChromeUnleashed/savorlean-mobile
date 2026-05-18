// lib/screens/auth/login/login_screen.dart
// Email/password login and Google OAuth sign-in screen.
// On success, go_router's auth redirect automatically navigates the user
// back to the page they came from (or home if no redirect_to param is set).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/common/app_button.dart';

/// Login screen — email/password + Google OAuth.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Shows a brief error message at the bottom of the screen.
  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Signs in with email and password.
  /// On success the router's _AuthChangeNotifier fires and redirects automatically.
  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      // Navigation is handled automatically by the auth-aware router.
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Sign in failed. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Opens Google OAuth in a browser tab and redirects back to the app.
  /// Requires the savorlean:// URL scheme to be configured in AndroidManifest.xml
  /// and the Supabase dashboard redirect URL list.
  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'savorlean://login-callback/',
      );
      // The deep link back into the app completes the flow.
      // The router will redirect once Supabase confirms the session.
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Google Sign-In failed. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        // Only show back button if there is a screen to go back to.
        automaticallyImplyLeading: context.canPop(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Brand heading
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Welcome to ',
                        style: AppTextStyles.headingBold,
                      ),
                      TextSpan(
                        text: 'SavorLean',
                        style: AppTextStyles.headingSerif,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to your account',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMuted,
                ),
                const SizedBox(height: 40),

                // Email field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'you@example.com',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Email is required';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password field with show/hide toggle
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _signIn(),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.textMuted,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    return null;
                  },
                ),
                const SizedBox(height: 8),

                // Forgot password link — right-aligned under the password field
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.cta,
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: () => context.push('/forgot-password'),
                    child: Text(
                      'Forgot password?',
                      style: AppTextStyles.inter(
                        fontSize: 13,
                        color: AppColors.cta,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Primary sign-in button
                AppButton(
                  label: 'Sign In',
                  onPressed: _signIn,
                  isLoading: _loading,
                  fullWidth: true,
                ),
                const SizedBox(height: 24),

                // "or" divider
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('or', style: AppTextStyles.bodyMuted),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24),

                // Google OAuth button
                AppButton(
                  label: 'Continue with Google',
                  onPressed: _loading ? null : _signInWithGoogle,
                  variant: AppButtonVariant.secondary,
                  fullWidth: true,
                ),
                const SizedBox(height: 40),

                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: AppTextStyles.bodyMuted,
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.cta,
                      ),
                      onPressed: () => context.push('/register'),
                      child: Text(
                        'Sign up',
                        style: AppTextStyles.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.cta,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
