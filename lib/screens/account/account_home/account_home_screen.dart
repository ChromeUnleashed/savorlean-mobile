// lib/screens/account/account_home/account_home_screen.dart
// Account hub screen — shows user info and navigation tiles.
// Signed-out users see login/register CTAs instead.
// Full implementation in Phase 4-1. For Phase 1-4, sign-out is wired
// so the full auth cycle can be tested end-to-end.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../providers/auth_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/common/app_button.dart';

/// Account home screen.
class AccountHomeScreen extends ConsumerWidget {
  const AccountHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the current user so the screen rebuilds on sign-in/sign-out.
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      // Should not normally be visible — auth guard redirects to /login.
      // Shown as a fallback if the guard hasn't fired yet.
      return _buildSignedOut(context);
    }

    return _buildSignedIn(context, user);
  }

  /// Full account UI — Phase 4-1 placeholder with working sign-out.
  Widget _buildSignedIn(BuildContext context, User user) {
    final displayName =
        user.userMetadata?['full_name'] as String? ?? user.email ?? 'User';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Text('Account', style: AppTextStyles.headingBold),
              const SizedBox(height: 4),
              Text(displayName, style: AppTextStyles.body),
              Text(user.email ?? '', style: AppTextStyles.bodyMuted),
              const SizedBox(height: 32),
              const Divider(),

              // Navigation tiles — full UI in Phase 4-1.
              _NavTile(
                icon: Icons.receipt_long_outlined,
                label: 'My Orders',
                onTap: () => context.push('/account/orders'),
              ),
              _NavTile(
                icon: Icons.favorite_outline,
                label: 'Wishlist',
                onTap: () => context.push('/account/wishlist'),
              ),
              _NavTile(
                icon: Icons.person_outline,
                label: 'Edit Profile',
                onTap: () => context.push('/account/profile'),
              ),
              const Divider(),
              const SizedBox(height: 16),

              // Sign-out button
              AppButton(
                label: 'Sign Out',
                variant: AppButtonVariant.secondary,
                onPressed: () async {
                  await Supabase.instance.client.auth.signOut();
                  // Router auto-redirects to home via _AuthChangeNotifier.
                },
                fullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Fallback state for unauthenticated users — auth guard should prevent this.
  Widget _buildSignedOut(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Sign in to view your account',
                textAlign: TextAlign.center,
                style: AppTextStyles.headingBold,
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Sign In',
                onPressed: () => context.push('/login'),
                fullWidth: true,
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Create Account',
                variant: AppButtonVariant.secondary,
                onPressed: () => context.push('/register'),
                fullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A single navigation tile row used in the account screen.
class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.textPrimary),
      title: Text(label, style: AppTextStyles.body),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
      onTap: onTap,
    );
  }
}
