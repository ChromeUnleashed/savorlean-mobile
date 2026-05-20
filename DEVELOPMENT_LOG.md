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

---

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

---

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

---

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

---

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

---

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

---

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

---

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

## 2026-05-19 — Phase 4-2: Order History & Detail

**What was done:**
- Created `lib/models/order_item.dart` — typed model for a line item; extracts name from nested `meals` or `subscription_plans` join result.
- Created `lib/models/order.dart` — full order model with all shipping fields, price columns, status, and a `List<OrderItem>`; defaults to empty items list for list-view fetches.
- Added `fetchOrders(userId)` and `fetchOrderById(orderId)` to `OrderService`; the detail query uses PostgREST nested select to join `order_items → meals(name)` and `order_items → subscription_plans(name)`.
- Created `lib/providers/order_provider.dart` — `userOrdersProvider` (simple list) and `orderDetailProvider(orderId)` (Riverpod family, one instance per order ID).
- Implemented `order_history_screen.dart`: card-style tiles with short order ID, formatted date, status badge (colored pill), and total; empty state; error + retry.
- Implemented `order_detail_screen.dart`: status banner with icon + color, items table (Item / QTY / Price columns), price breakdown (subtotal, discount, delivery, total, payment method), delivery details with icons, optional meal instructions section.

**Why done this way:**
- Two separate fetch methods (lightweight for list, full join for detail) avoids loading item data that the list view doesn't need.
- `orderDetailProvider` is a Riverpod family so each order ID gets its own cached provider instance, making back-navigation instant.
- Status colors and labels defined inline (not in theme) — they're display-only and not reused elsewhere.
- Used `withValues(alpha:)` instead of deprecated `withOpacity()`.

**Issues encountered:**
- `AppColors.divider` doesn't exist — corrected to `AppColors.border`.
- Dart 3 disallows duplicate `_` wildcard names in the same scope (`(_, __)`); fixed by using single `_` for both ignored parameters.
- Unnecessary cast warning on `row as Map<String, dynamic>` — Supabase `.single()` already returns the correct type; removed cast.

---

## 2026-05-19 — Phase 4-3: Wishlist

**What was done:**
- Created `WishlistService` — `fetchWishlistIds` (returns `Set<String>`), `addToWishlist`, `removeFromWishlist` against the `wishlists` table.
- Created `Wishlist` AsyncNotifier (`wishlist_provider.dart`) — loads IDs on build, `toggle()` does optimistic update then syncs to DB; reverts and rethrows on error.
- Created `WishlistButton` widget — self-contained `ConsumerWidget` taking a `mealId`; redirects to `/login` if not signed in, otherwise calls `toggle()` and shows a snackbar on error.
- Updated `MealCard` to embed `WishlistButton` directly; removed the now-unused `isWishlisted`/`onWishlistTap` props.
- Wired the heart button in `MealDetailScreen` SliverAppBar actions — fills/unfills based on wishlist state, same auth + error handling.
- Implemented `WishlistScreen` — watches both `wishlistProvider` and `mealsProvider`, filters to intersection, grid layout matching menu, empty state with "Browse Menu" link.

**Why done this way:**
- `WishlistButton` is self-contained so no screen needs to pass wishlist state down — just drop `WishlistButton(mealId: meal.id)` anywhere.
- Optimistic update + revert pattern keeps the UI snappy while guaranteeing eventual consistency with the DB.
- `rethrow` after revert lets the button surface the actual error to the user instead of silently failing.

**Issues encountered:**
- Table is named `wishlists` (plural) — initial implementation used `wishlist` (singular). Diagnosed by surfacing the Supabase error in a snackbar; fixed by updating all three queries in `WishlistService`.

---

## 2026-05-19 — Phase 4-4: Edit Profile

**What was done:**
- Created `lib/models/address.dart` — typed model for the `addresses` table with fields: `id`, `userId`, `fullName`, `phone`, `streetAddress`, `area`, `city`, `isDefault`, `createdAt`. `Address.fromMap` deserialises the PostgREST response.
- Created `lib/services/address_service.dart` — two methods: `fetchDefaultAddress(userId)` returns the user's default address row or `null` (silent failure); `saveDefaultAddress(...)` deletes any existing default row first, then inserts a fresh one with `is_default = true`. Delete-then-insert is required because the `addresses` table has a unique partial index on `(user_id) WHERE is_default = true`, which rejects a plain upsert.
- Created `lib/providers/address_provider.dart` — `defaultAddressProvider` watches `currentUserProvider` and calls `fetchDefaultAddress` on auth change; returns `null` for signed-out users. Ran build_runner to generate the `.g.dart` file.
- Implemented `lib/screens/account/edit_profile/edit_profile_screen.dart` — `ConsumerStatefulWidget` with five `TextEditingController`s (name, phone, street address, area, city). Pre-fill logic runs once on first data-available frame via a `_prefilled` guard flag (avoids overwriting user edits on hot-reload). All fields validated before the save is attempted. On success: calls `ref.invalidate(defaultAddressProvider)` to refresh the cache, shows a snackbar, then pops or navigates to `/account`.

**Why done this way:**
- The implementation diverged from the original plan (`mobile_plan.md §4-4` specified `profiles` table + name/phone only). The `profiles` table dependency was removed during Phase 4-1 refactoring when it became clear the checkout pre-fill needed full address fields (street, area, city). Extending Edit Profile to save the same `addresses` table row means checkout and profile share one source of truth with no duplication.
- Delete-before-insert instead of upsert: Supabase's `upsert` on a table with a partial unique index can throw `23505 unique violation` in some Postgres versions. Explicit delete + insert is more predictable and avoids a silent constraint race.
- `ref.invalidate(defaultAddressProvider)` is used rather than `ref.refresh` — the screen is about to pop, so there is no point awaiting the re-fetch; the caller (AccountHomeScreen or CheckoutScreen) will trigger a fresh fetch when it rebuilds.

**Issues encountered:**
- None. Zero analyzer issues, `dart format` clean.

**User confirmed. 4-4 marked complete. Phase 4 committed as `feat(account): Phase 4-4 — edit profile with default address saving`.**

---

## 2026-05-20 — Phase 5-1: UX Polish

**What was done:**
- **Skeleton loaders:** Added three composite skeleton widgets to `lib/widgets/common/loading_indicator.dart`:
  - `AppMealCardSkeleton` — matches the MealCard `AspectRatio(4/3)` image + text-block layout. Placed in a `SliverGrid` so the loading state fills the same grid positions as real cards.
  - `AppPlanCardSkeleton` — matches the PlanCard full-width container with left olive border, badge, and trailing arrow.
  - `AppOrderTileSkeleton` — matches the OrderHistory tile with ID, date, status pill, and total.
  Applied to: MenuScreen (grid), PlansScreen (list), OrderHistoryScreen (list). All three screens now show skeletons instead of a bare spinner while the Riverpod `AsyncValue` is in the loading state.
- **Haptic feedback:** `HapticFeedback.lightImpact()` added in two places:
  - `WishlistButton._handleTap()` — fires immediately before the async toggle so the physical response is synchronous with the tap.
  - `MealDetailScreen` add-to-cart handler — same pattern.
- **Page transitions:** Added a `_slide()` helper to `lib/router/router.dart` that wraps any screen in a `CustomTransitionPage` combining a `FadeTransition` (easeOut) with a 4 % upward `SlideTransition` (Offset `(0, 0.04) → zero`). Duration: 220 ms forward, 180 ms reverse. Every non-tab route (meal detail, plan detail, checkout, auth screens, all account sub-screens) was converted from `builder:` to `pageBuilder:` using `_slide()`. The four shell tabs keep Flutter's default instant tab switch.

**Why done this way:**
- Composite skeleton widgets are defined once in `loading_indicator.dart` and dropped into any screen — no per-screen shimmer logic needed.
- Haptic feedback is called before `await` so the physical response is not delayed by the async DB round-trip.
- The 4 % upward slide (rather than a full horizontal push) avoids the jarring feel of a full-screen slide on mobile, while still conveying depth and directionality. The asymmetric durations (220 ms in / 180 ms out) make back navigation feel snappier than forward navigation.

**Issues encountered:**
- None. Zero analyzer issues, `dart format` clean.

**User confirmed. 5-1 marked complete. Committed as `feat(polish): Phase 5-1 — skeleton loaders, transitions, haptic feedback`.**

---

## 2026-05-20 — Phase 5-2: App Identity

**What was done:**
- Added `flutter_launcher_icons: ^0.14.3` (dev dep) and `flutter_native_splash: ^2.4.3` (runtime dep) to `pubspec.yaml`. Ran `flutter pub get`.
- Placed the SavorLean logo PNG at `assets/icon/icon.png` (1024 × 1024).
- Configured `flutter_launcher_icons` in `pubspec.yaml`: target file `launcher_icon`, adaptive icon with white background + logo foreground for Android 8+, `remove_alpha_ios: true` for App Store compliance.
- Configured `flutter_native_splash` in `pubspec.yaml`: white background, logo centred, enabled for both Android and iOS, Android 12 section uses the adaptive icon format.
- Ran `dart run flutter_launcher_icons` — generated all `mipmap-*` density folders in `android/app/src/main/res/` and all `AppIcon*` asset catalog entries in `ios/Runner/Assets.xcassets/`.
- Ran `dart run flutter_native_splash:create` — generated `launch_background.xml` (Android) and updated `LaunchScreen.storyboard` (iOS) with the branded splash layout.
- Set `android:label="SavorLean"` in `AndroidManifest.xml` and `CFBundleDisplayName` / `CFBundleName` → `"SavorLean"` in `ios/Runner/Info.plist`.
- Updated `lib/main.dart`: imported `flutter_native_splash`, called `FlutterNativeSplash.preserve(widgetsBinding: binding)` before `Supabase.initialize`, and `FlutterNativeSplash.remove()` immediately after — this keeps the native splash visible during the async Supabase init window instead of flashing a blank white frame.
- Also updated `Supabase.initialize` to pass `authOptions: FlutterAuthClientOptions(authFlowType: AuthFlowType.pkce)` — required for the PKCE-based password reset deep link flow built in Phase 5-3.

**Why done this way:**
- `FlutterNativeSplash.preserve` + `remove` around `Supabase.initialize` is the recommended pattern from the `flutter_native_splash` docs for apps that do async work before `runApp`. Without it, Android and iOS both flash a blank screen between the native splash and the first Flutter frame.
- `remove_alpha_ios: true` strips the alpha channel from the iOS icon, which is required by App Store validation — icons with transparency are rejected at upload.
- PKCE (`AuthFlowType.pkce`) was enabled at this point because Phase 5-3 requires it for the password reset deep link to correctly exchange the token on app resume. Without PKCE, Supabase's implicit flow does not deliver the `passwordRecovery` event reliably.

**Issues encountered:**
- Adaptive icon on Android 8+ initially showed a white circle border around the logo (the launcher applied a circular mask to the foreground layer, cutting into the logo). Fixed by replacing `assets/icon/icon.png` with a version that has a **transparent** background — with transparency the circular mask reveals only the logo, not a white ring. Follow-up commit: `fix(identity): replace icon with transparent PNG to remove adaptive circle artefact`.

**User confirmed. 5-2 marked complete. Committed as `feat(identity): Phase 5-2 — app icon, splash screen, and app name` + fix commit.**

---

## 2026-05-20 — Phase 5-3: Deep Links & URL Scheme

**What was done:**
- **Android:** Confirmed and refined the `intent-filter` in `AndroidManifest.xml`. Set explicit `android:host` values — `login-callback` and `reset-callback` — so the filter only matches `savorlean://login-callback` and `savorlean://reset-callback`, not every possible `savorlean://` URL.
- **iOS:** Added `CFBundleURLTypes` to `ios/Runner/Info.plist` registering the `savorlean` URL scheme so iOS will route all `savorlean://` deep links back to the app.
- **`ForgotPasswordScreen`:** `resetPasswordForEmail` call sets `redirectTo: 'savorlean://login-callback'`. Supabase appends the PKCE token to this URL and puts it in the reset email. When the user taps the link, the OS opens the app via the registered scheme.
- **`ResetPasswordScreen`** (`lib/screens/auth/reset_password/reset_password_screen.dart`): New `StatefulWidget` at `/reset-password`. Two password fields (new password, confirm) with show/hide toggles. Validates minimum 8-character length and that both fields match. Calls `auth.updateUser(UserAttributes(password: ...))` on submit. On success: shows a snackbar and navigates to `/` with `context.go('/')`.
- **Router — `_AuthChangeNotifier` extended:** Now tracks `lastEvent` from the Supabase auth stream. When `passwordRecovery` is detected, the global `_redirect()` function sends the user to `/reset-password` regardless of current location. When `userUpdated` fires (password saved successfully), `lastEvent` is set to `null` to stop the recovery redirect from firing again — without this, any subsequent navigation would re-trigger the redirect loop.
- **New route:** `/reset-password` added to `appRouter` using `pageBuilder` with `_slide()`.
- **Manual step (user action required):** `savorlean://login-callback` must be added to Supabase dashboard → Authentication → URL Configuration → Redirect URLs before the deep link flow will work end-to-end.

**Why done this way:**
- Explicit `android:host` values on the Android intent-filter follow Android security best practices — an overly broad `<data android:scheme="savorlean" />` without a host would match any `savorlean://` URL and could be exploited by other apps registering the same scheme.
- `lastEvent = null` after `userUpdated` is critical: if not cleared, the `passwordRecovery` event stays in memory and the redirect guard keeps sending the user back to `/reset-password` on every future navigation — essentially breaking the app until it is restarted.
- `automaticallyImplyLeading: false` on `ResetPasswordScreen`'s `AppBar` removes the back button — the user must complete or cancel the reset, not navigate back to an ambiguous previous screen mid-recovery.
- PKCE flow (enabled in Phase 5-2) is required: the token in the deep link URL is a PKCE code verifier, not an implicit access token. Without `AuthFlowType.pkce`, Supabase does not correctly exchange the code on app resume and the `passwordRecovery` event is never fired.

**Issues encountered:**
- None during the platform config work. The one remaining blocker is the manual Supabase dashboard step (Redirect URLs) which requires user action — cannot be done in code.

**User confirmed. 5-3 marked complete. Committed as `feat(deep-links): Phase 5-3 — register savorlean:// URL scheme for auth callbacks`.**

---

## 2026-05-20 — Phase 5-4: Performance

**What was done:**
- **`cached_network_image` audit:** Verified that every image-loading widget in the app uses `CachedNetworkImage` — `MealCard`, `CartItemTile`, the home screen carousel, and `MealDetailScreen` hero. No bare `Image.network` calls exist anywhere. No code changes needed for this item.
- **Pagination guard on menu:** Added `.limit(100)` to both branches of `fetchMeals()` in `lib/services/meal_service.dart` (with and without category filter). Full page-by-page pagination was not implemented because the menu screen's search is client-side — paginating would silently restrict search to only the loaded page, which is confusing UX. A 100-item cap is a practical guard for the foreseeable catalog size; if the menu ever exceeds 100 meals, server-side search and cursor-based pagination should be introduced together as a single feature.
- **Riverpod rebuild scope — `WishlistButton`:** Changed `ref.watch(wishlistProvider)` to `ref.watch(wishlistProvider.select(...))` in `lib/widgets/wishlist_button/wishlist_button.dart`. Previously every `WishlistButton` on every visible `MealCard` watched the full `Set<String>`, so toggling one meal caused O(n) rebuilds across all visible cards. With `.select((v) => v.asData?.value.contains(mealId) ?? false)`, each button now only rebuilds when its own meal's wishlist status changes. The intermediate `wishlistIds` variable was removed — `isWishlisted` is now derived directly from the select.
- **`redirectTo` trailing slash fix:** Updated `ForgotPasswordScreen` to use `'savorlean://login-callback/'` (with trailing slash) to match the URL registered in the Supabase dashboard. A mismatch here would cause Supabase to reject the redirect and break the password reset flow.

**Why done this way:**
- `.limit(100)` on `fetchMeals` rather than a "load more" button: the two features (pagination + search) have conflicting requirements. Solving them together properly requires server-side search, which is out of scope for this phase. The limit acts as a safety cap without changing the user experience.
- `wishlistProvider.select()` is the idiomatic Riverpod pattern for watching a computed slice of a larger state object. It avoids the need for per-meal providers while still preventing unnecessary rebuilds.

**Issues encountered:**
- None. Zero analyzer issues, `dart format` clean.

**User confirmed. 5-4 marked complete.**
