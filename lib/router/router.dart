// lib/router/router.dart
// Defines all navigation routes for the SavorLean app using go_router.
//
// Structure:
//   ShellRoute — wraps main tabs with the bottom nav bar
//     /          → HomeScreen
//     /menu      → MenuScreen
//     /cart      → CartScreen
//     /account   → AccountHomeScreen (auth-guarded)
//       /account/orders        → OrderHistoryScreen
//       /account/orders/:id    → OrderDetailScreen
//       /account/wishlist      → WishlistScreen
//       /account/profile       → EditProfileScreen
//
//   Top-level (no bottom nav)
//     /menu/:slug              → MealDetailScreen
//     /plans                   → PlansScreen
//     /plans/:slug             → PlanDetailScreen
//     /checkout                → CheckoutScreen (auth-guarded)
//     /checkout/confirmation   → OrderConfirmationScreen
//     /login                   → LoginScreen
//     /register                → RegisterScreen
//     /forgot-password         → ForgotPasswordScreen

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../screens/account/account_home/account_home_screen.dart';
import '../screens/account/edit_profile/edit_profile_screen.dart';
import '../screens/account/order_detail/order_detail_screen.dart';
import '../screens/account/order_history/order_history_screen.dart';
import '../screens/account/wishlist/wishlist_screen.dart';
import '../screens/auth/forgot_password/forgot_password_screen.dart';
import '../screens/auth/login/login_screen.dart';
import '../screens/auth/register/register_screen.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/checkout/checkout_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/meal_detail/meal_detail_screen.dart';
import '../screens/menu/menu_screen.dart';
import '../screens/order_confirmation/order_confirmation_screen.dart';
import '../screens/plan_detail/plan_detail_screen.dart';
import '../screens/plans/plans_screen.dart';
import '../widgets/bottom_nav_bar/bottom_nav_bar.dart';

// ---------------------------------------------------------------------------
// Auth helpers
// ---------------------------------------------------------------------------

/// Returns true when the user has an active Supabase session.
bool _isSignedIn() => Supabase.instance.client.auth.currentSession != null;

/// A ChangeNotifier that fires whenever Supabase auth state changes.
/// go_router uses this as a refreshListenable to re-run the redirect
/// function automatically on sign-in or sign-out.
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier() {
    // Listen to every auth state change and notify go_router to re-evaluate.
    Supabase.instance.client.auth.onAuthStateChange.listen((_) {
      notifyListeners();
    });
  }
}

final _authNotifier = _AuthChangeNotifier();

// ---------------------------------------------------------------------------
// Global redirect
// ---------------------------------------------------------------------------

/// Called by go_router on every navigation event.
/// Returns a redirect path if the user should be sent elsewhere, or null
/// to allow the navigation to proceed as requested.
String? _redirect(BuildContext context, GoRouterState state) {
  final signedIn = _isSignedIn();
  final loc = state.matchedLocation;

  // Send unsigned-in users away from protected routes to the login screen.
  // The redirect_to query param is read by LoginScreen after a successful login.
  final isProtected = loc.startsWith('/account') || loc.startsWith('/checkout');
  if (isProtected && !signedIn) {
    return Uri(
      path: '/login',
      queryParameters: {'redirect_to': loc},
    ).toString();
  }

  // If the user is already signed in and lands on an auth screen,
  // redirect to the original destination or fall back to home.
  final isAuthScreen =
      loc == '/login' || loc == '/register' || loc == '/forgot-password';
  if (signedIn && isAuthScreen) {
    final redirectTo = state.uri.queryParameters['redirect_to'];
    return (redirectTo != null && redirectTo.isNotEmpty) ? redirectTo : '/';
  }

  // No redirect needed — let the navigation proceed.
  return null;
}

// ---------------------------------------------------------------------------
// App router
// ---------------------------------------------------------------------------

/// The root GoRouter instance. Pass this to MaterialApp.router via routerConfig.
final appRouter = GoRouter(
  initialLocation: '/',
  // Re-evaluate the redirect whenever Supabase auth state changes.
  refreshListenable: _authNotifier,
  redirect: _redirect,
  routes: [
    // ------------------------------------------------------------------
    // Shell route — screens inside here share the bottom nav bar.
    // ------------------------------------------------------------------
    ShellRoute(
      builder: (context, state, child) {
        // Determine the active tab index from the current location.
        final loc = state.matchedLocation;
        final index = loc.startsWith('/menu')
            ? 1
            : loc.startsWith('/cart')
            ? 2
            : loc.startsWith('/account')
            ? 3
            : 0;

        return Scaffold(
          // The child is the currently active tab's screen.
          body: child,
          bottomNavigationBar: BottomNavBar(currentIndex: index),
        );
      },
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
        GoRoute(path: '/menu', builder: (context, state) => const MenuScreen()),
        GoRoute(path: '/cart', builder: (context, state) => const CartScreen()),
        GoRoute(
          path: '/account',
          builder: (context, state) => const AccountHomeScreen(),
          routes: [
            GoRoute(
              path: 'orders',
              builder: (context, state) => const OrderHistoryScreen(),
            ),
            GoRoute(
              path: 'orders/:id',
              builder: (context, state) =>
                  OrderDetailScreen(orderId: state.pathParameters['id']!),
            ),
            GoRoute(
              path: 'wishlist',
              builder: (context, state) => const WishlistScreen(),
            ),
            GoRoute(
              path: 'profile',
              builder: (context, state) => const EditProfileScreen(),
            ),
          ],
        ),
      ],
    ),

    // ------------------------------------------------------------------
    // Full-screen routes — no bottom nav bar.
    // ------------------------------------------------------------------
    GoRoute(
      path: '/menu/:slug',
      builder: (context, state) =>
          MealDetailScreen(slug: state.pathParameters['slug']!),
    ),
    GoRoute(
      path: '/plans',
      builder: (context, state) => const PlansScreen(),
      routes: [
        GoRoute(
          path: ':slug',
          builder: (context, state) =>
              PlanDetailScreen(slug: state.pathParameters['slug']!),
        ),
      ],
    ),
    GoRoute(
      path: '/checkout',
      builder: (context, state) => const CheckoutScreen(),
      routes: [
        GoRoute(
          path: 'confirmation',
          builder: (context, state) => const OrderConfirmationScreen(),
        ),
      ],
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
  ],
);
