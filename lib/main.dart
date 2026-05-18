// lib/main.dart
// Entry point for the SavorLean mobile app.
// Initialises Supabase (credentials injected via --dart-define-from-file)
// and wraps the entire widget tree in a Riverpod ProviderScope.
//
// Run with: flutter run --dart-define-from-file=dart_defines.json

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'router/router.dart';
import 'theme/app_theme.dart';

// Supabase credentials are injected at build/run time — never hardcoded here.
// Copy dart_defines.example.json → dart_defines.json and fill in real values.
const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

Future<void> main() async {
  // Must be called before any async platform code (Supabase, Firebase, etc.).
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise the Supabase client once. After this call it is accessible
  // anywhere in the app via Supabase.instance.client.
  // PKCE auth flow is required for secure OAuth and deep-link callbacks on mobile.
  await Supabase.initialize(
    url: _supabaseUrl,
    anonKey: _supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  // ProviderScope is the root container required by Riverpod.
  // All providers declared with @riverpod live inside this scope.
  runApp(const ProviderScope(child: SavorLeanApp()));
}

/// Root application widget.
///
/// Theme (Phase 1-2) and router (Phase 1-3) will be wired in
/// as those miniphases are completed. The placeholder home below
/// will be replaced by the go_router shell in Phase 1-3.
class SavorLeanApp extends StatelessWidget {
  const SavorLeanApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp.router hands navigation control to go_router.
    // All routes and auth guards are defined in lib/router/router.dart.
    return MaterialApp.router(
      title: 'SavorLean',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
