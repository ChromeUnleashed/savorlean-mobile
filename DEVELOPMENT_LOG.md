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

<!-- New entries go below this line, newest at the bottom -->
