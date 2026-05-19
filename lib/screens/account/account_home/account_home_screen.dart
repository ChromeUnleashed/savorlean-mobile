// lib/screens/account/account_home/account_home_screen.dart
// The Account tab screen — the central hub for the user's account.
// Signed-in users see their profile header and navigation tiles.
// Signed-out users see login/register call-to-action buttons.
// (The auth guard in the router normally redirects unsigned-in users to /login
// before they can see this screen, but the fallback is kept for safety.)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../providers/address_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/common/app_button.dart';

/// Account home screen — shown as the Account tab in the bottom nav bar.
class AccountHomeScreen extends ConsumerWidget {
  const AccountHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the current user so the screen rebuilds on sign-in/sign-out.
    final user = ref.watch(currentUserProvider);

    // User is not signed in — show the login/register fallback.
    if (user == null) {
      return _buildSignedOut(context);
    }

    // User is signed in — show their profile and navigation tiles.
    final addressAsync = ref.watch(defaultAddressProvider);

    return _buildSignedIn(context, ref, user, addressAsync);
  }

  /// Builds the full account screen for a signed-in user.
  Widget _buildSignedIn(
    BuildContext context,
    WidgetRef ref,
    User user,
    AsyncValue addressAsync,
  ) {
    final address = addressAsync.asData?.value;

    // Cascade: saved address name → Google auth metadata → email fallback.
    final String displayName;
    if (address?.fullName.isNotEmpty == true) {
      displayName = address!.fullName;
    } else if ((user.userMetadata?['full_name'] as String?)?.isNotEmpty == true) {
      displayName = user.userMetadata!['full_name'] as String;
    } else {
      displayName = user.email ?? 'Account';
    }

    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'A';
    final phone = address?.phone;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // ── Profile header ────────────────────────────────────────────
              // Avatar circle showing the user's initial letter.
              Center(
                child: CircleAvatar(
                  radius: 44,
                  backgroundColor: AppColors.cta,
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Display name
              Text(
                displayName,
                textAlign: TextAlign.center,
                style: AppTextStyles.headingBold,
              ),
              const SizedBox(height: 4),

              // Email address
              Text(
                user.email ?? '',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMuted,
              ),

              // Phone number — only shown if it's been saved in the profile.
              if (phone != null && phone.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  phone,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMuted,
                ),
              ],

              const SizedBox(height: 32),
              const Divider(),

              // ── Navigation tiles ──────────────────────────────────────────
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
              const SizedBox(height: 24),

              // ── Sign out ──────────────────────────────────────────────────
              AppButton(
                label: 'Sign Out',
                variant: AppButtonVariant.secondary,
                onPressed: () async {
                  // Sign the user out — the router's _AuthChangeNotifier
                  // detects the sign-out event and redirects to home automatically.
                  await Supabase.instance.client.auth.signOut();
                },
                fullWidth: true,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  /// Fallback screen for users who are not signed in.
  /// The auth guard in the router normally prevents reaching this, but it
  /// serves as a safety net and handles the moment before the redirect fires.
  Widget _buildSignedOut(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              const Icon(
                Icons.lock_outline_rounded,
                size: 64,
                color: AppColors.textMuted,
              ),
              const SizedBox(height: 24),

              // Heading
              Text(
                'Sign in to your account',
                textAlign: TextAlign.center,
                style: AppTextStyles.headingBold,
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                'View your orders, wishlist, and profile.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMuted,
              ),
              const SizedBox(height: 40),

              // Sign in button
              AppButton(
                label: 'Sign In',
                onPressed: () => context.push('/login'),
                fullWidth: true,
              ),
              const SizedBox(height: 12),

              // Register button
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

/// A single navigation row tile used in the account screen.
/// Shows an icon on the left, a label in the middle, and a right-arrow chevron.
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
      leading: Icon(icon, color: AppColors.cta),
      title: Text(label, style: AppTextStyles.body),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
      onTap: onTap,
    );
  }
}
