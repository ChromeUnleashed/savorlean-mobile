# SavorLean Mobile — Development Log

> One entry per major step. Each entry covers: what was done, why it was done that way, and any issues encountered.

---

## 2026-05-18 — Session 1: Project Onboarding & Tracking Setup

**What was done:**
- Read `AGENTS.md`, `RULES.md`, and `tasks/mobile_plan.md` in full.
- Assessed current project state: bare Flutter scaffold (default counter app), no packages installed, `main.dart` is the Flutter demo template.
- Created `todo.md` with the full 6-phase task breakdown derived from `mobile_plan.md §7`.
- Created `DEVELOPMENT_LOG.md` (this file).

**Why done this way:**
- `RULES.md` requires `todo.md` and `DEVELOPMENT_LOG.md` to be in place before any implementation begins.
- The full phase breakdown was written upfront so the user can see the entire scope and approve the plan before a single line of app code is written.

**Current state:**
- Project is a clean Flutter scaffold at `savorlean_mobile` (SDK `^3.11.5`).
- No SavorLean packages are installed yet — `pubspec.yaml` contains only `cupertino_icons` and `flutter_lints`.
- `main.dart` is the default counter demo — will be fully replaced in Phase 1-1.
- `dart_defines.json` does not yet exist — user will need to create it with Supabase credentials before Phase 1-1 can run.

**Issues / blockers:**
- None yet. Awaiting user approval to begin Phase 1.

---

---

## 2026-05-18 — Phase 1-1: Scaffold & Environment

**What was done:**
- Updated `pubspec.yaml`: added 9 runtime packages (`supabase_flutter`, `flutter_riverpod`, `riverpod_annotation`, `go_router`, `google_fonts`, `cached_network_image`, `flutter_svg`, `fluttertoast`, `google_sign_in`) and 3 dev packages (`build_runner`, `riverpod_generator`, `mocktail`). Ran `flutter pub get` — 134 dependencies resolved with no errors.
- Updated `.gitignore`: added `*.jks`, `*.keystore`, `key.properties` (were missing; `dart_defines.json` was already present).
- Created `dart_defines.example.json`: documents the two required env var keys (`SUPABASE_URL`, `SUPABASE_ANON_KEY`) without real values, so a new developer knows what to fill in.
- Rewrote `lib/main.dart`: replaced Flutter demo counter with Supabase initialization + Riverpod `ProviderScope`. Credentials read via `String.fromEnvironment` (injected at run/build time via `--dart-define-from-file=dart_defines.json`). Placeholder home widget says "SavorLean" — will be replaced by go_router in 1-3.

**Why done this way:**
- `flutter_svg` chosen over `lucide_icons` package — more stable, widely used, avoids a dependency on a smaller package that may have version instability.
- Supabase init is async so `main()` is now `Future<void>` with `WidgetsFlutterBinding.ensureInitialized()` called first — this is required whenever any async platform code runs before `runApp`.
- `ProviderScope` wraps the entire app at root level so Riverpod providers are accessible from any widget in the tree.

**Issues / blockers:**
- User must create `dart_defines.json` with real Supabase credentials before the app can connect to the backend and run. Template is at `dart_defines.example.json`.
- 30 packages noted as having newer incompatible major versions available — not an issue; our version constraints are correct for this build.

**User confirmed. 1-1 marked complete. Committed as `feat(setup): Phase 1-1 scaffold and environment`.**

---

## 2026-05-18 — Phase 1-2: Theme & Design System

**What was done:**
- Created `lib/theme/app_colors.dart` — 13 named color constants mirroring the web app's CSS custom properties exactly.
- Created `lib/theme/app_text_styles.dart` — Inter (body/UI) and Cormorant Garamond (italic serif headings) via `google_fonts`. Provides both a flexible builder API and pre-named styles (headingBold, headingSerif, body, bodyMuted, label, price, button, sectionTitle).
- Created `lib/theme/app_theme.dart` — full Material 3 ThemeData covering colorScheme, textTheme, elevatedButtonTheme, outlinedButtonTheme, appBarTheme, inputDecorationTheme, chipTheme, dividerTheme, and snackBarTheme. All values derived from AppColors and AppTextStyles.
- Created `lib/widgets/common/app_button.dart` — three variants (primary/secondary/olive), loading state with spinner, optional full-width mode. Uses a `switch` expression for clean variant routing.
- Created `lib/widgets/common/loading_indicator.dart` — AppLoadingIndicator (CTA-red spinner) and AppSkeletonBox (pulsing opacity animation for skeleton layouts).
- Updated `lib/main.dart` to wire `AppTheme.light` into MaterialApp.

**Why done this way:**
- AppColors and AppTextStyles are pure static classes (no instantiation) — easy to reference from anywhere without a provider or context.
- google_fonts loads Inter and Cormorant Garamond at runtime — no manual font asset management needed.
- AppSkeletonBox uses opacity animation rather than a shimmer gradient — simpler, no extra package, and looks clean against the off-white surface color.
- `withValues(alpha:)` used instead of deprecated `withOpacity()` for disabled button states.

**Issues / blockers:**
- None. `dart analyze` passes with zero issues.

**Awaiting user confirmation to mark 1-2 complete in todo.md.**

---

## 2026-05-18 — Phase 1-3: Navigation Shell

**What was done:**
- Created 16 stub screens covering all routes (home, menu, meal detail, plans, plan detail, cart, checkout, order confirmation, login, register, forgot password, account home, order history, order detail, wishlist, edit profile).
- Created `lib/router/router.dart` — full go_router setup with ShellRoute (bottom nav tabs) and top-level routes (no nav bar). Auth redirect guard implemented via global `redirect` function + `_AuthChangeNotifier` (listens to Supabase auth stream, notifies go_router to re-evaluate on state change). Protected routes: `/account/*` and `/checkout`.
- Created `lib/widgets/bottom_nav_bar/bottom_nav_bar.dart` — NavigationBar with olive active indicator and brand colors. Active tab derived from `state.matchedLocation` in ShellRoute builder.
- Updated `lib/main.dart` — switched from `MaterialApp` to `MaterialApp.router` with `routerConfig: appRouter`.

**Why done this way:**
- The auth redirect guard lives in the global `redirect` function rather than per-route — simpler to maintain and avoids duplication.
- `_AuthChangeNotifier` wraps the Supabase auth stream as a `ChangeNotifier`, which is the standard go_router pattern for auth-aware routing without Riverpod coupling at the router level.
- Active tab index is derived in the ShellRoute builder from `state.matchedLocation` rather than tracking state separately — no extra provider needed.

**Issues / blockers:**
- None. Zero analyzer issues. User confirmed navigation works on emulator.

**User confirmed. 1-3 marked complete.**

## 2026-05-18 — Phase 1-4: Auth Screens & Flow

**What was done:**
- Created `lib/providers/auth_provider.dart` with Riverpod streams for auth state and current user.
- Built `LoginScreen` (email/password and Google Sign-In) and `RegisterScreen` (name, email, password) using the UI design system.
- Built `ForgotPasswordScreen` to trigger Supabase password reset emails.
- Updated `AndroidManifest.xml` to include an intent-filter for the `savorlean://` deep link scheme.
- Implemented the sign-out action in `AccountHomeScreen`.

**Why done this way:**
- Using `riverpod` providers for the current user allows all screens to automatically react to auth state changes, rather than passing the user object manually.
- The `go_router` setup handles redirecting logic automatically based on the `_AuthChangeNotifier` configured in Phase 1-3, so auth screens just call Supabase without explicit navigation boilerplate.
- The deep link scheme is registered in AndroidManifest.xml since Android is the primary platform, handling callbacks from the Supabase reset password email flow.

**Issues / blockers:**
- iOS deep link scheme (`savorlean://`) has not been added to `Info.plist` yet, which is expected since iOS Associated Domains is scheduled for Phase 5-3, but something to note if testing on iOS.

**User confirmed. 1-4 marked complete.**

<!-- New entries go below this line, newest at the bottom -->
