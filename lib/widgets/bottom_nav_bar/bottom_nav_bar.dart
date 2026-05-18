// lib/widgets/bottom_nav_bar/bottom_nav_bar.dart
// The persistent bottom navigation bar shown on all main tabs.
// Highlights the active tab based on the current route, and will show
// a badge on the Cart icon once the cart provider is wired in Phase 3-1.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Bottom navigation bar with four tabs: Home, Menu, Cart, Account.
/// Used as the persistent shell widget across all main routes.
class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key, required this.currentIndex});

  /// The index of the currently active tab (0=Home, 1=Menu, 2=Cart, 3=Account).
  final int currentIndex;

  /// Navigates to the route for the tapped tab index.
  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
      case 1:
        context.go('/menu');
      case 2:
        context.go('/cart');
      case 3:
        context.go('/account');
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) => _onTap(context, index),

      // Use the brand surface color as the nav bar background.
      backgroundColor: AppColors.bg,
      indicatorColor: AppColors.oliveSoft,

      // Style the labels using the design system.
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final isSelected = states.contains(WidgetState.selected);
        return AppTextStyles.inter(
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected ? AppColors.olive : AppColors.textMuted,
        );
      }),

      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.home_outlined, color: AppColors.textMuted),
          selectedIcon: const Icon(Icons.home, color: AppColors.olive),
          label: 'Home',
        ),
        NavigationDestination(
          icon: const Icon(
            Icons.restaurant_menu_outlined,
            color: AppColors.textMuted,
          ),
          selectedIcon: const Icon(
            Icons.restaurant_menu,
            color: AppColors.olive,
          ),
          label: 'Menu',
        ),
        // Cart tab — badge will be wired in Phase 3-1.
        NavigationDestination(
          icon: const Icon(
            Icons.shopping_bag_outlined,
            color: AppColors.textMuted,
          ),
          selectedIcon: const Icon(Icons.shopping_bag, color: AppColors.olive),
          label: 'Cart',
        ),
        NavigationDestination(
          icon: const Icon(Icons.person_outline, color: AppColors.textMuted),
          selectedIcon: const Icon(Icons.person, color: AppColors.olive),
          label: 'Account',
        ),
      ],
    );
  }
}
