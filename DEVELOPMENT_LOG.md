# SavorLean Mobile — Development Log

> One entry per major step. Each entry covers: what was done, why it was done that way, and any issues encountered.

---

## 2026-05-19 — Phase 4-1: Account Home Screen

**What was done:**
- Created `lib/models/user_profile.dart` — typed model for the `profiles` table (`id`, `full_name`, `phone_number`).
- Created `lib/services/profile_service.dart` — `fetchProfile()` (maybeSingle, returns null gracefully) and `upsertProfile()` for Phase 4-4.
- Created `lib/providers/profile_provider.dart` — async `@riverpod` provider that watches `currentUserProvider` and re-fetches on auth state change.
- Fully implemented `account_home_screen.dart`: avatar circle with brand color + initial letter, display name (cascades: profiles table → auth metadata → email), email, phone (conditional), styled nav tiles with CTA-colored icons, sign-out button.
- Fixed `checkout_screen.dart` to use `ref.read(userProfileProvider.future)` for profile prefill instead of calling Supabase directly (architecture compliance).
- Added "Continue as guest" link (CTA color) and always-visible back button to both `login_screen.dart` and `register_screen.dart`.

**Why done this way:**
- `ProfileService` + `userProfileProvider` are shared with Phase 4-4 (Edit Profile) — creating them now avoids duplication later.
- Display name cascade ensures something sensible always shows even for users with no profiles row yet.
- `asData?.value` used instead of `valueOrNull` — the latter is not available in this version of Riverpod.
- Back button uses `canPop() ? pop() : go('/')` so it works both when pushed from account screen and when the router redirects directly to `/login`.

**Issues encountered:**
- `AsyncValue<dynamic>` doesn't expose `valueOrNull` — used `asData?.value` as the equivalent.
- Ternary operator precedence caused a `non_bool_condition` error in the display name fallback chain — refactored to explicit `if/else` blocks.
- `checkout_screen.dart` was calling Supabase directly in `_prefillFromProfile` — replaced with provider call; kept `supabase_flutter` import since order placement still needs it.

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

## 2026-05-18 — Phase 2-1: Home Screen

**What was done:**
- Created `lib/models/carousel_slide.dart` and `lib/models/testimonial.dart`.
- Created `lib/services/settings_service.dart` querying `carousel_slides`, `reviews`, and `site_content`.
- Created `lib/providers/home_provider.dart` with `homeDataProvider` fetching all data concurrently.
- Created `lib/screens/home/home_screen.dart` — hero carousel with auto-advance timer (4s), animated pill dots, announcement bar, and testimonials section.
- "Featured Meals" and "Our Plans" sections are deliberate placeholders — `MealCard` and `PlanCard` widgets don't exist yet (Phase 2-2/2-4).

**Schema corrections discovered during testing:**
- `carousel_slides` uses `headline`/`sub_headline`/`cta_link` not `title`/`subtitle`/`link`. Fixed in model.
- `carousel_slides` has `sort_order` and `is_active` columns — query now filters active and orders by sort_order.
- No `testimonials` table exists — the table is named `reviews` and is scoped to meal reviews (not marketing testimonials). Table is currently empty so the section hides itself.
- `reviews` uses `body` not `content` for the review text. Fixed in model.

**Why done this way:**
- Errors from carousel/testimonial queries were initially swallowed by try-catch blocks (from another agent), making the screen appear to load but with no content. Removed try-catch from data queries so failures surface in the UI error state with a retry button.
- `_CarouselSection` is a `StatefulWidget` to hold the `PageController` and `Timer`. Auto-advance skips if only one slide. Timer is cancelled in `dispose()`.

**Issues / blockers:**
- None after schema corrections.

**User confirmed. 2-1 marked complete.**

## 2026-05-18 — Phase 2-2: Menu Screen

**What was done:**
- Created `lib/models/category.dart` and `lib/models/meal.dart` mapped exactly to the Supabase schema.
- Created `lib/services/meal_service.dart` with `fetchCategories`, `fetchMeals` (with optional category filter), `fetchFeaturedMeals`, and `fetchMealBySlug`.
- Created `lib/providers/meal_provider.dart` with `mealServiceProvider`, `categoriesProvider`, `selectedCategoryIdProvider` (notifier), `mealsProvider`, and `featuredMealsProvider`. Ran build_runner to generate `meal_provider.g.dart`.
- Created `lib/widgets/meal_card/meal_card.dart` — image, category label, name, price (Rs. X), wishlist heart (non-functional until Phase 4-3).
- Implemented `lib/screens/menu/menu_screen.dart` — search bar, animated category chips (olive when selected), 2-column SliverGrid, pull-to-refresh, empty/error states.
- Updated home screen to replace "Featured Meals Placeholder" with a real horizontal scroll of featured meals using `featuredMealsProvider`.
- Fixed default widget test (was referencing removed `MyApp` class).

**Schema notes:**
- `meals.images` is a `text[]` array — use `images[0]` as the card image via a `imageUrl` getter.
- `meals.id` is `text`, not `uuid`.
- Category join: `.select('*, categories!meals_category_id_fkey(id, name, slug)')` gives nested `categories` object with the meal's category name.
- `categories` has `sort_order` and `is_active` — query filters active and orders by sort_order.

**Why done this way:**
- Category chip selection uses a `SelectedCategoryId` Riverpod notifier so changing the category automatically re-fetches meals via `mealsProvider` watching it.
- Search is handled client-side (local state) — no re-fetch needed, fast UX.
- `_Chip` uses `AnimatedContainer` instead of Flutter's `FilterChip`/`ChoiceChip` to match the brand's square (2px radius) style with olive active color.

**Issues / blockers:**
- None. Zero analyzer issues, dart format clean.

**User confirmed. 2-2 marked complete.**

## 2026-05-18 — Phase 2-3: Meal Detail Screen

**What was done:**
- Added `mealBySlugProvider(String slug)` (family provider) to `meal_provider.dart` and regenerated.
- Switched meal card taps from `context.go()` to `context.push()` in menu and home screens so the back button on the detail screen correctly returns to the previous tab.
- Implemented full `MealDetailScreen`: expandable `SliverAppBar` with hero image, circular back/heart overlay buttons, category label + Bestseller/Featured badges, meal name, price, description, 4-box nutrition grid, ingredients, tag chips, quantity selector (+/-), and Add to Cart button showing the live total.
- Added `AppColors.ctaLight` (#B5766D) and `AppButtonVariant.ctaLight` for the Add to Cart button style.
- Fixed a bug in `AppButton._buildChild` where `AppTextStyles.button` hardcoded `AppColors.textPrimary`, overriding `foregroundColor`. Fixed by passing `spinnerColor` into `copyWith(color:)` so text color matches the variant.

**Why done this way:**
- `context.push()` vs `context.go()`: `push` preserves the shell route in the navigator stack, enabling `Navigator.of(context).pop()` to return to the menu. `go` would have replaced the stack.
- Add to Cart and wishlist heart are present in the UI but no-op — they'll be wired to `cart_provider` (Phase 3-1) and `wishlist_provider` (Phase 4-3) respectively.
- `mealBySlugProvider` is a Riverpod family provider — takes `slug` as a parameter and calls `fetchMealBySlug`. Each unique slug gets its own cached future.

**Issues / blockers:**
- None. Zero analyzer issues.

**User confirmed. 2-3 marked complete.**

## 2026-05-19 — Phase 2-4: Plans Screens

**What was done:**
- Created `lib/models/subscription_plan.dart` — `SubscriptionPlan`, `PlanPricing`, and `PlanMealSlot` models. `startingPrice` getter returns the minimum price across all pricing rows. `availableDurations` and `availableMealsPerDay` computed lists drive the selection chips in the correct logical order. `pricingFor(duration, mealsPerDay)` looks up the selected price combination.
- Created `lib/services/plan_service.dart` — `fetchPlans()` with `plan_pricing` join, `fetchFeaturedPlans()` filtered by `is_featured`, and `fetchPlanBySlug()` with full detail join (`plan_pricing` + `plan_meal_slots` + nested meal names).
- Created `lib/providers/plan_provider.dart` — `plansProvider`, `featuredPlansProvider`, and `planBySlugProvider(slug)` family provider. Ran build_runner to generate `plan_provider.g.dart`.
- Created `lib/widgets/plan_card/plan_card.dart` — container with olive left border (4px), olive type badge, plan name, 2-line description, "From Rs. X" price, and trailing arrow.
- Implemented `lib/screens/plans/plans_screen.dart` — `ConsumerWidget` with `ListView.separated`, pull-to-refresh, empty and error states. AppBar title uses RichText (Inter bold + Cormorant serif).
- Implemented `lib/screens/plan_detail/plan_detail_screen.dart` — `ConsumerStatefulWidget` with `_selectedDuration` and `_selectedMealsPerDay` state. `_initSelection()` lazily defaults to the cheapest pricing option on first data load. Duration and meals-per-day `_SelectChip` widgets (animated, olive when selected). Live price display in a cream container. Schedule section renders a `_ScheduleView` (grouped by day mon→sun, slot breakfast→lunch→dinner) or a plain text message for `scheduleMode == 'message'`. Add to Cart button is disabled until both options are selected.
- Updated home screen `_OurPlansSection` to watch `featuredPlansProvider` and display a vertical list of PlanCards with a "View All Plans" link — replaces the earlier placeholder.

**Why done this way:**
- `availableDurations` filters `_durationOrder` (a const list in logical week order) rather than using the DB order — ensures chips always appear 1 Week → 2 Weeks → 1 Month regardless of insertion order.
- `_initSelection()` checks `_selectedDuration != null` before setting state so it only runs once on the first data frame, not on every hot-reload or provider refresh.
- Schedule view groups slots using `_dayOrder`/`_slotOrder` const lists so the layout is deterministic even if DB rows are unordered.

**Issues / blockers:**
- None. Zero analyzer issues, dart format clean.

**User confirmed. 2-4 marked complete.**

## 2026-05-19 — Phase 3-1: Cart

**What was done:**
- Created `lib/models/cart_item.dart` — immutable `CartItem` with `mealId`/`planId` (only one set), `unitPricePkr`, `quantity`, optional `planDurationLabel`/`planMealsPerDay`. `lineTotalPkr` computed, `subtitle` derived string, `copyWith` for quantity updates.
- Created `lib/providers/cart_provider.dart` — `Cart` Riverpod notifier: `addMeal` (deduplicates by mealId, increments if already in cart), `addPlan` (cartId keyed on `planId_duration_mealsPerDay`), `increment`, `decrement` (removes at 0), `remove`, `clear`. Derived providers: `cartItemCountProvider` (total quantity across all items), `cartSubtotalProvider`.
- Created `lib/widgets/cart_item_tile/cart_item_tile.dart` — image (64×64, cached, falls back to icon for plans), name + price row, subtitle row, +/− quantity controls, "Remove" text link.
- Implemented `lib/screens/cart/cart_screen.dart` — empty state (icon + message + "Browse Menu" secondary button), items list, promo code field (stub, Apply button disabled until Phase 3-2), cream summary box (subtotal, delivery: Free, total), "Proceed to Checkout" primary button (`context.push('/checkout')` — router redirect handles auth guard).
- Updated `lib/widgets/bottom_nav_bar/bottom_nav_bar.dart` — converted to `ConsumerWidget`, watches `cartItemCountProvider`, wraps Cart icon in Flutter `Badge` (CTA red, hidden when count is 0).
- Wired Add to Cart in `MealDetailScreen` — calls `cartProvider.notifier.addMeal(meal, _quantity)`, shows floating snackbar with "Open Cart" action (`context.go('/cart')`).
- Wired Add to Cart in `PlanDetailScreen` — calls `cartProvider.notifier.addPlan(plan, selectedPricing)`, same snackbar pattern.

**Why done this way:**
- Cart deduplication by ID (meal) or composite key (plan+duration+meals) means tapping "Add to Cart" twice on the same meal just increments quantity rather than creating a duplicate line item.
- `cartItemCount` is a separate derived provider (not a getter on the notifier) so the bottom nav bar only rebuilds when the count changes, not on every cart mutation.
- Plan image is `null` in CartItem — the `subscription_plans` table has no `image_url` column. The tile falls back to a `restaurant_menu` icon in this case.
- Promo code field is included in the cart UI but the Apply button is disabled (`onPressed: null`) — it renders the full layout so Phase 3-2 only needs to add the validation logic without restructuring the screen.

**Issues / blockers:**
- None. Zero analyzer issues, dart format clean.

**User confirmed. 3-1 marked complete.**

## 2026-05-19 — Phase 3-2: Promo Code Validation

**What was done:**
- Created `lib/models/promo_code.dart` — `PromoCode` with `discountFor(int subtotalPkr)` computing fixed or percentage discounts (capped by `maxDiscountPkr`), and a `displayLabel` getter for UI display.
- Created `lib/services/promo_service.dart` — `validate(String code)` fetches from `promo_codes` table, validates `is_active`, date range, and usage limit, throws typed `PromoException` with user-facing messages.
- Extended `cart_provider.dart` — added `AppliedPromo` notifier (`PromoCode?` state, `apply`/`clear`), `promoServiceProvider`, `cartDiscountProvider`, and `cartTotalProvider`.
- Updated `cart_screen.dart` — promo field now active: shows `TextField` + Apply button when no promo applied, switches to `_AppliedPromoChip` (olive background, code + displayLabel, Remove button) when applied. Inline error shown below field on failure.

**Issues encountered:**
- `PostgrestException code: 42501` — `permission denied for table promo_codes`. Root cause: Supabase requires both a table-level GRANT and an RLS policy. RLS policy alone is not sufficient. Fixed by running `GRANT SELECT ON public.promo_codes TO anon, authenticated` in the SQL Editor.
- `discount_value` column is PostgreSQL `numeric` type — PostgREST returns it as a String, not `num`. Fixed with `double.parse(json['discount_value'].toString())` in `PromoCode.fromJson`.

**User confirmed. 3-2 marked complete.**

---

## 2026-05-19 — Phase 3-3: Checkout & Order Placement

**What was done:**
- Created `lib/models/placed_order.dart` — lightweight model (id, totalPkr, paymentMethod, itemCount) passed via go_router `extra` to the confirmation screen.
- Created `lib/services/order_service.dart` — `placeOrder()` inserts into `orders` then `order_items`, includes `plan_config` JSONB for plan items. After both inserts succeed, invokes the `send-order-confirmation` Edge Function (fire-and-forget, email failure never blocks order confirmation).
- Implemented `lib/screens/checkout/checkout_screen.dart` — delivery details form (5 required fields), optional schedule section (date picker + `DropdownMenu` time window), optional meal instructions, `RadioGroup<String>` payment method (COD / Bank Transfer), order summary box, Place Order button. Profile pre-fill attempts `profiles` table on init (silent failure).
- Implemented `lib/screens/order_confirmation/order_confirmation_screen.dart` — order summary box, bank transfer instructions box (shown only for bank_transfer, fetches `site_settings` for bank name, account title, account number, IBAN, WhatsApp number), Continue Shopping + View Order History buttons.
- Updated `router.dart` — confirmation route reads `state.extra as PlacedOrder?`, renders `_NoOrderScreen` fallback if navigated to directly.
- Deployed Supabase Edge Function `send-order-confirmation` — fetches order + items using service role key, looks up meal/plan names by ID, sends branded HTML email via Resend API matching the website's olive header design.

**Issues encountered:**
- Flutter 3.41 deprecated `DropdownButtonFormField(value:)` → replaced with `DropdownMenu(initialSelection:, expandedInsets: EdgeInsets.zero)`.
- Flutter 3.41 deprecated `RadioListTile(groupValue:, onChanged:)` → replaced with `RadioGroup<String>` wrapping `RadioListTile` widgets.
- Snackbar with action doesn't auto-dismiss via `duration` in Flutter 3.41 — fixed by capturing `ScaffoldFeatureController` from `showSnackBar` and calling `Future.delayed(Duration(seconds: 3), entry.close)`.
- Edge Function initially queried meals by `slug` but `order_items.meal_id` stores `meal.id` (not slug) — fixed by querying `in('id', mealIds)`.

**Design decisions:**
- All CTA buttons updated to `#B5766D` (lighter rose) by changing `AppColors.cta`.
- Snackbar theme updated to olive green (`AppColors.olive` background, `AppColors.oliveSoft` action text).
- Bank transfer details (bank name, account title, account number, IBAN, WhatsApp) read from `site_settings` table — never hardcoded per AGENTS.md rule 13.

**User confirmed. 3-3 marked complete. Phase 3 fully signed off.**

---

<!-- New entries go below this line, newest at the bottom -->
