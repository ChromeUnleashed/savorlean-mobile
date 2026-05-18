import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/cart_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class BottomNavBar extends ConsumerWidget {
  const BottomNavBar({super.key, required this.currentIndex});

  final int currentIndex;

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
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartItemCountProvider);

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) => _onTap(context, index),
      backgroundColor: AppColors.bg,
      indicatorColor: AppColors.oliveSoft,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final isSelected = states.contains(WidgetState.selected);
        return AppTextStyles.inter(
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected ? AppColors.olive : AppColors.textMuted,
        );
      }),
      destinations: [
        const NavigationDestination(
          icon: Icon(Icons.home_outlined, color: AppColors.textMuted),
          selectedIcon: Icon(Icons.home, color: AppColors.olive),
          label: 'Home',
        ),
        const NavigationDestination(
          icon: Icon(
            Icons.restaurant_menu_outlined,
            color: AppColors.textMuted,
          ),
          selectedIcon: Icon(Icons.restaurant_menu, color: AppColors.olive),
          label: 'Menu',
        ),
        NavigationDestination(
          icon: Badge(
            isLabelVisible: cartCount > 0,
            backgroundColor: AppColors.cta,
            label: Text(
              '$cartCount',
              style: const TextStyle(fontSize: 10, color: Colors.white),
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: AppColors.textMuted,
            ),
          ),
          selectedIcon: Badge(
            isLabelVisible: cartCount > 0,
            backgroundColor: AppColors.cta,
            label: Text(
              '$cartCount',
              style: const TextStyle(fontSize: 10, color: Colors.white),
            ),
            child: const Icon(Icons.shopping_bag, color: AppColors.olive),
          ),
          label: 'Cart',
        ),
        const NavigationDestination(
          icon: Icon(Icons.person_outline, color: AppColors.textMuted),
          selectedIcon: Icon(Icons.person, color: AppColors.olive),
          label: 'Account',
        ),
      ],
    );
  }
}
