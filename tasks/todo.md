# SavorLean Mobile — Todo

> Managed by the agent. Do NOT mark any item `[x]` without explicit user confirmation.
> Phase transitions require full sign-off checklist review and user approval.

---

## Phase 1 — Project Setup & Foundation
**Goal:** Runnable app shell connected to Supabase, with auth working end-to-end.

### 1-1 — Scaffold & Environment ✅
- [x] Add all packages to `pubspec.yaml` (supabase_flutter, riverpod, go_router, google_fonts, cached_network_image, flutter_svg, google_sign_in, fluttertoast, riverpod_annotation, build_runner, riverpod_generator, mocktail)
- [x] Create `dart_defines.example.json` with required key names (no real values)
- [x] Confirm `dart_defines.json` is in `.gitignore`; confirm `.gitignore` covers `*.jks`, `*.keystore`, `key.properties`, `.dart_tool/`, `build/`
- [x] Initialise Supabase in `main.dart` (`Supabase.initialize` using `--dart-define` values)
- [x] Update `pubspec.yaml` description and app metadata to reflect SavorLean

### 1-2 — Theme & Design System ✅
- [x] `lib/theme/app_colors.dart` — all color constants from design system
- [x] `lib/theme/app_text_styles.dart` — Inter + Cormorant Garamond text styles
- [x] `lib/theme/app_theme.dart` — `ThemeData` wiring (colorScheme, textTheme, buttonTheme)
- [x] `lib/widgets/common/app_button.dart` — primary + secondary variants
- [x] `lib/widgets/common/loading_indicator.dart` — branded spinner / skeleton base

### 1-3 — Navigation Shell ✅
- [x] `lib/router/router.dart` — all routes declared with go_router (screens as stubs)
- [x] `ShellRoute` for bottom nav bar
- [x] `lib/widgets/bottom_nav_bar/bottom_nav_bar.dart` — Home, Menu, Cart (badge), Account tabs
- [x] Auth redirect guard on `/account/*` and `/checkout`

### 1-4 — Auth Screens & Flow
- [x] `lib/providers/auth_provider.dart` — stream of current user, auto-refresh session
- [x] `lib/screens/auth/login/login_screen.dart` — email + password + Google Sign-In button
- [x] `lib/screens/auth/register/register_screen.dart` — name, email, password
- [x] `lib/screens/auth/forgot_password/forgot_password_screen.dart` — email input → Supabase reset email
- [ ] Password reset deep link handling — configure URL scheme (`savorlean://`)
- [x] Sign-out action (clears session, redirects to home)

**Phase 1 Sign-Off Checklist:**
- [x] App launches and shows home stub without crashing
- [x] Can register with email/password → session persists after hot restart
- [x] Can sign in with Google
- [x] Unauthenticated user navigating to `/account` is redirected to `/login`
- [x] After login, redirect resolves correctly back to original path
- [ ] Password reset email arrives and deep link opens the app

---

## Phase 2 — Home & Menu
**Goal:** Real content from DB displayed on home and menu screens, meal detail working.

### 2-1 — Home Screen ✅
- [x] `lib/models/carousel_slide.dart`
- [x] `lib/models/testimonial.dart`
- [x] `lib/services/settings_service.dart` — `site_content`, `carousel_slides`, `reviews` queries
- [x] `lib/screens/home/home_screen.dart` — carousel (auto-advance + dots), announcement bar, testimonials (hidden when empty); featured meals + plans are placeholders until 2-2/2-4

### 2-2 — Menu Screen ✅
- [x] `lib/models/meal.dart`
- [x] `lib/models/category.dart`
- [x] `lib/services/meal_service.dart` — fetch all meals, fetch by category
- [x] `lib/providers/meal_provider.dart`
- [x] `lib/widgets/meal_card/meal_card.dart` — image, name, category chip, price, wishlist heart
- [x] `lib/screens/menu/menu_screen.dart` — category filter chips, GridView, search bar, pull-to-refresh
- [x] Home screen updated with real Featured Meals horizontal scroll (is_featured=true meals)

### 2-3 — Meal Detail Screen ✅
- [x] `lib/screens/meal_detail/meal_detail_screen.dart` — hero image (SliverAppBar), name, category, price, Bestseller/Featured badges, description, nutrition grid, ingredients, tag chips, quantity selector, Add to Cart button (Phase 3-1), wishlist heart (Phase 4-3)
- [x] `mealBySlugProvider` added to `meal_provider.dart`
- [x] `AppColors.ctaLight` (#B5766D) added; `AppButtonVariant.ctaLight` added to AppButton
- [x] Fixed AppButton text color bug (was ignoring foregroundColor due to hardcoded style color)

### 2-4 — Plans Screens ✅
- [x] `lib/models/subscription_plan.dart`
- [x] `lib/services/plan_service.dart` — fetch plans, fetch plan with meals
- [x] `lib/providers/plan_provider.dart`
- [x] `lib/widgets/plan_card/plan_card.dart`
- [x] `lib/screens/plans/plans_screen.dart`
- [x] `lib/screens/plan_detail/plan_detail_screen.dart`

**Phase 2 Sign-Off Checklist:**
- [ ] Home loads real carousel, meals, plans, testimonials from DB
- [ ] Menu category filters work correctly
- [ ] Search filters meal list in real-time
- [ ] Meal detail shows all data fields correctly
- [ ] Wishlist heart toggles (persists to DB when signed in; prompts login when not)
- [ ] Plan detail shows included meals

---

## Phase 3 — Cart & Checkout
**Goal:** Full end-to-end order placement working.

### 3-1 — Cart ✅
- [x] `lib/providers/cart_provider.dart` — in-memory cart (meals + plans, quantity +/-)
- [x] `lib/widgets/cart_item_tile/cart_item_tile.dart`
- [x] `lib/screens/cart/cart_screen.dart` — items list, quantity controls, remove, promo field, total
- [x] Cart badge on bottom nav updates live from provider
- [x] "Proceed to Checkout" auth guard

### 3-2 — Promo Code Validation ✅
- [x] `lib/models/promo_code.dart`
- [x] `lib/services/promo_service.dart` — validate code (active, not expired, within usage limit)
- [x] Apply discount; show inline error if invalid

### 3-3 — Checkout & Order Placement ✅
- [x] `lib/services/order_service.dart` — insert `orders` + `order_items`
- [x] `lib/screens/checkout/checkout_screen.dart` — delivery details, COD label, order summary, meal instructions field, place order button
- [x] Pre-fill name/phone from user profile
- [x] On success → clear cart → navigate to confirmation
- [x] `lib/screens/order_confirmation/order_confirmation_screen.dart` — with bank transfer details from site_settings
- [x] Order confirmation email via Supabase Edge Function + Resend

**Phase 3 Sign-Off Checklist:**
- [x] Can add meal + plan to cart
- [x] Quantities update correctly; remove works
- [x] Valid promo code applies discount; invalid shows error
- [x] Can complete checkout with real user → order appears in Supabase `orders` table
- [x] Order confirmation screen shows correct order details
- [x] Order confirmation email arrives (verified in Resend)
- [x] Cart clears after successful order

---

## Phase 4 — Account
**Goal:** Order history, order detail, wishlist, and profile editing all working.

### 4-1 — Account Home Screen ✅
- [x] `lib/screens/account/account_home/account_home_screen.dart` — signed-in state (name/email, nav tiles); signed-out state (login/register CTAs)
- [x] `lib/models/user_profile.dart` — typed model for profiles table
- [x] `lib/services/profile_service.dart` — fetchProfile + upsertProfile
- [x] `lib/providers/profile_provider.dart` — async Riverpod provider
- [x] Login + register screens: always-visible back button, "Continue as guest" link

### 4-2 — Order History & Detail ✅
- [x] `lib/screens/account/order_history/order_history_screen.dart` — list of past orders (date, total, status badge)
- [x] `lib/screens/account/order_detail/order_detail_screen.dart` — items, address, status, total breakdown
- [x] `lib/models/order.dart` + `lib/models/order_item.dart` — typed models
- [x] `lib/providers/order_provider.dart` — userOrdersProvider + orderDetailProvider(id) family
- [x] `lib/services/order_service.dart` — fetchOrders() + fetchOrderById() with PostgREST join

### 4-3 — Wishlist ✅
- [x] `lib/providers/wishlist_provider.dart` — AsyncNotifier with optimistic toggle
- [x] `lib/services/wishlist_service.dart` — fetchWishlistIds, addToWishlist, removeFromWishlist
- [x] `lib/widgets/wishlist_button/wishlist_button.dart` — self-contained heart button
- [x] `lib/screens/account/wishlist/wishlist_screen.dart` — grid of MealCards, empty state, error+retry
- [x] MealCard updated to embed WishlistButton; MealDetailScreen heart wired up

### 4-4 — Edit Profile ✅
- [x] `lib/screens/account/edit_profile/edit_profile_screen.dart` — name + phone + full address form, saves to `addresses` table (default address row); removed unused profiles table dependency

**Phase 4 Sign-Off Checklist:**
- [ ] Order history shows all past orders
- [ ] Order detail screen shows correct items and status
- [ ] Wishlist shows saved meals; X removes instantly (optimistic)
- [ ] Profile edit saves correctly

---

## Phase 5 — Polish & Pre-Release
**Goal:** App feels complete and ready for store submission.

### 5-1 — UX Polish ✅
- [x] Skeleton loaders on all data screens (AppMealCardSkeleton, AppPlanCardSkeleton, AppOrderTileSkeleton)
- [x] Error states with "tap to retry" on all data screens
- [x] Empty states (no meals, empty cart, empty wishlist, no orders)
- [x] All form fields: correct keyboard types, validation, error messages
- [x] Haptic feedback on add-to-cart and wishlist toggle
- [x] Smooth page transitions via go_router — fade + subtle upward slide (220ms)

### 5-2 — App Identity
- [ ] App icon (1024×1024 PNG) → `flutter_launcher_icons`
- [ ] Splash screen (SavorLean logo on white) → `flutter_native_splash`
- [ ] App name "SavorLean" in Android manifest + iOS Info.plist

### 5-3 — Deep Links & URL Scheme
- [ ] Android `intent-filter` + iOS `Associated Domains` for Supabase auth callbacks
- [ ] Test: password reset email → tap link → app opens on reset screen

### 5-4 — Performance
- [ ] `cached_network_image` on all meal/plan images (verify, not just added as dep)
- [ ] Pagination or "load more" on menu screen if meal count > 50
- [ ] Review Riverpod provider scopes for unnecessary rebuilds

**Phase 5 Sign-Off Checklist:**
- [ ] App looks polished on a real device (no layout overflow, no jank)
- [ ] App icon and splash screen display correctly
- [ ] Deep links work end-to-end
- [ ] All error/empty states are handled gracefully

---

## Phase 6 — Push Notifications & Store Release
**Goal:** App submitted to Play Store (and App Store if required).

### 6-1 — Push Notifications (optional)
- [ ] Firebase project setup, `google-services.json` added
- [ ] `firebase_messaging` package — request permission
- [ ] Supabase Edge Function or external trigger for FCM push on order status change

### 6-2 — Android Release Build
- [ ] Generate keystore, configure `key.properties` (gitignored)
- [ ] `flutter build appbundle --release --dart-define-from-file=dart_defines.json`
- [ ] Test on physical Android device

### 6-3 — Play Store Submission
- [ ] Play Console app listing (title, description, screenshots, privacy policy URL)
- [ ] Upload AAB to internal testing track → closed testing → production

### 6-4 — iOS Release (if required)
- [ ] Apple Developer account enrollment
- [ ] Xcode signing configuration
- [ ] `flutter build ipa --release --dart-define-from-file=dart_defines.json`
- [ ] App Store Connect submission
