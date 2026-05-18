# SavorLean Mobile — Flutter App Plan

> **Hand-off document.** This file was written in the `savorlean-web` session after Phase 4 (web app) was
> complete. Drop this file into the `savorlean-mobile` Flutter project root and read it in full before
> taking any action. It is the single source of truth for the mobile app build.

---

## 1. What We Are Building

A Flutter mobile app for SavorLean — a fresh diet meal-plan delivery service based in Pakistan.
The app is the mobile companion to the existing Next.js web app at `https://savorlean.netlify.app`.

**The backend is already built and live.** The app connects to the same Supabase project as the web app.
No new database tables, no new RLS policies, no new edge functions needed for the core build.

### Target platforms
- Android (primary — Play Store)
- iOS (secondary — App Store, if user requests it)

### What the app covers (feature parity with web storefront)
| Feature | Web | Mobile |
|---|---|---|
| Browse meals (grid + category filters) | ✅ | ✅ |
| Meal detail | ✅ | ✅ |
| Browse subscription plans | ✅ | ✅ |
| Plan detail | ✅ | ✅ |
| Cart (meals + plans) | ✅ | ✅ |
| Promo code at checkout | ✅ | ✅ |
| COD checkout | ✅ | ✅ |
| Order confirmation email | ✅ | (sent by backend — no mobile work needed) |
| Auth — email/password | ✅ | ✅ |
| Auth — Google Sign-In | ✅ | ✅ |
| Password reset | ✅ | ✅ |
| Account — order history | ✅ | ✅ |
| Account — order detail | ✅ | ✅ |
| Account — wishlist | ✅ | ✅ |
| Account — profile edit | ✅ | ✅ |
| Push notifications (order status) | ❌ | Phase 6 |
| Admin panel | ❌ | never (web-only) |

---

## 2. Backend Reference

The Flutter app is a **read/write client** of the existing Supabase project. No changes to the backend
are expected. Reference the web app's `lib/` folder for query patterns.

### Supabase credentials
Store in a `dart_defines.json` file at the Flutter project root (gitignored). Retrieve the values
from the Supabase dashboard → Project Settings → API.

```json
{
  "SUPABASE_URL": "https://<project-ref>.supabase.co",
  "SUPABASE_ANON_KEY": "<anon-public-key>"
}
```

Add `dart_defines.json` to `.gitignore`. Pass into the app at run/build time:
```
flutter run --dart-define-from-file=dart_defines.json
flutter build appbundle --release --dart-define-from-file=dart_defines.json
```

Read in Dart code via:
```dart
const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
```

### Key tables (already exist — do not recreate)
| Table | Used for |
|---|---|
| `meals` | meal listings |
| `categories` | meal category filter chips |
| `subscription_plans` | plan listings |
| `subscription_plan_meals` | meals included in a plan |
| `orders` | checkout + order history |
| `order_items` | line items per order |
| `promo_codes` | discount validation at checkout |
| `wishlists` | saved meals per user |
| `site_settings` | WhatsApp number, address, contact email |
| `site_content` | marketing copy (hero text, announcement bar) |
| `carousel_slides` | home screen hero carousel |
| `testimonials` | home screen testimonials |

### RLS note
All user-scoped tables (orders, wishlists) are protected by Row Level Security.
The Supabase Flutter SDK automatically attaches the user's JWT — no manual auth headers needed.

---

## 3. Design System

Carry forward the exact same visual identity as the web app.

### Colors
```dart
// lib/theme/app_colors.dart
static const Color olive       = Color(0xFF6E7B44);
static const Color oliveHover  = Color(0xFF566030);
static const Color oliveSoft   = Color(0xFFEEF1E0);
static const Color cta         = Color(0xFF9B4E38);   // all filled buttons
static const Color ctaHover    = Color(0xFF7D3C2A);
static const Color bg          = Color(0xFFFFFFFF);
static const Color surface     = Color(0xFFF0EDE8);   // card image background
static const Color cream       = Color(0xFFF0E8DC);   // cart totals zone
static const Color textPrimary = Color(0xFF1A1A18);
static const Color textMuted   = Color(0xFF6B6B6B);
static const Color border      = Color(0xFFE0DDD8);
static const Color success     = Color(0xFF2D7A3A);
static const Color error       = Color(0xFFC13B2A);
```

### Typography
- **Serif (headings):** Cormorant Garamond — load via `google_fonts` package.
  Use italic weight only, for the emotional/brand word in section headings.
- **Sans (body/UI):** Inter — load via `google_fonts` package.
  All body text, buttons, labels, prices.

### Heading pattern (must replicate)
Section headings mix italic serif (emotional word) + bold sans (structural words):
```
My Wishlist       → "My" in Inter bold, "Wishlist" in Cormorant Garamond italic
Fresh Daily       → "Fresh" in Cormorant italic, "Daily" in Inter bold
```
Use `RichText` with `TextSpan` children to achieve this in Flutter.

### Buttons
- **Primary (CTA):** filled, `--color-cta` (#9B4E38), white text, uppercase, letter-spacing 1.2
- **Secondary (outline):** bordered `--color-cta`, transparent fill, CTA-colored text
- **Olive (brand):** filled olive, white text — used only in announcement bar / brand moments
- Corner radius: 2px (near-square, not pill-shaped)

### Spacing & layout
- Base grid: 16px horizontal padding on all screens
- Card gap: 12px
- Section vertical padding: 32px top / 40px bottom

---

## 4. Tech Stack

| Concern | Package | Notes |
|---|---|---|
| Backend | `supabase_flutter` | Auth + DB + Storage |
| State management | `riverpod` (`flutter_riverpod` + `riverpod_annotation`) | Recommended — clean, testable |
| Navigation | `go_router` | Declarative routing, deep link support |
| Fonts | `google_fonts` | Inter + Cormorant Garamond |
| Images | `cached_network_image` | Caches Supabase Storage URLs |
| Icons | `lucide_icons` (or `flutter_svg` + download SVGs) | Match web icon set |
| Google Sign-In | `google_sign_in` + Supabase OAuth | Same flow as web |
| Env vars | `--dart-define` at build time | No package needed |
| Toast/snackbar | `fluttertoast` or built-in `ScaffoldMessenger` | Match web toast style |
| Push notifications | `firebase_messaging` | Phase 6 only |
| App icon | `flutter_launcher_icons` | Phase 6 |
| Splash screen | `flutter_native_splash` | Phase 6 |

---

## 5. Project Structure

```
lib/
  main.dart                   # app entry point, Supabase.initialize()
  theme/
    app_colors.dart
    app_text_styles.dart
    app_theme.dart
  router/
    router.dart               # go_router routes
  providers/
    supabase_provider.dart    # global Supabase client provider
    auth_provider.dart        # current user stream
    cart_provider.dart        # cart state (StateNotifier)
    wishlist_provider.dart    # wishlist IDs set
  models/
    meal.dart
    category.dart
    subscription_plan.dart
    order.dart
    order_item.dart
    promo_code.dart
    carousel_slide.dart
    testimonial.dart
  services/
    meal_service.dart         # DB queries for meals
    plan_service.dart         # DB queries for plans
    order_service.dart        # place order, fetch history
    wishlist_service.dart     # toggle, fetch
    promo_service.dart        # validate promo code
    settings_service.dart     # site_settings, site_content
  screens/
    home/
    menu/
    meal_detail/
    plans/
    plan_detail/
    cart/
    checkout/
    order_confirmation/
    auth/
      login/
      register/
      forgot_password/
    account/
      account_home/
      order_history/
      order_detail/
      wishlist/
      edit_profile/
  widgets/
    common/                   # buttons, text styles, loading states
    meal_card/
    plan_card/
    cart_item_tile/
    wishlist_button/
    announcement_bar/
    bottom_nav_bar/
```

---

## 6. Navigation Structure

Use `go_router` with a `ShellRoute` for the bottom nav bar (persists across tabs).

### Bottom nav tabs (visible when signed in)
1. Home (`/`)
2. Menu (`/menu`)
3. Cart (`/cart`) — badge shows item count
4. Account (`/account`)

### Full route map
```
/                         → HomeScreen
/menu                     → MenuScreen
/menu/:slug               → MealDetailScreen
/plans                    → PlansScreen  (reachable from home + menu)
/plans/:slug              → PlanDetailScreen
/cart                     → CartScreen
/checkout                 → CheckoutScreen
/checkout/confirmation    → OrderConfirmationScreen
/login                    → LoginScreen
/register                 → RegisterScreen
/forgot-password          → ForgotPasswordScreen
/account                  → AccountHomeScreen  (auth-guarded)
/account/orders           → OrderHistoryScreen
/account/orders/:id       → OrderDetailScreen
/account/wishlist         → WishlistScreen
/account/profile          → EditProfileScreen
```

### Auth guard
Wrap `/account/*` and `/checkout` with a redirect: if no session → `/login?redirect_to=<path>`.
After login, `go_router` redirect resolves back to the original path.

---

## 7. Phase Plan

### Phase 1 — Project Setup & Foundation
**Goal:** Runnable app shell connected to Supabase, with auth working end-to-end.

#### 1-1 — Scaffold & Environment
- [ ] `flutter create savorlean_mobile --org com.savorlean`
- [ ] Add all packages to `pubspec.yaml` (see §4 above)
- [ ] Create `dart_defines.json` with Supabase credentials; add to `.gitignore`; document `--dart-define-from-file` usage in README
- [ ] Initialise Supabase in `main.dart` (`Supabase.initialize`)
- [ ] Git init, `.gitignore` (include `.env`, `*.jks`, `*.keystore`), push to new GitHub repo

#### 1-2 — Theme & Design System
- [ ] `app_colors.dart` — all color constants
- [ ] `app_text_styles.dart` — Inter + Cormorant Garamond text styles
- [ ] `app_theme.dart` — `ThemeData` wiring (colorScheme, textTheme, buttonTheme)
- [ ] Shared `AppButton` widget (primary + secondary variants)
- [ ] Shared loading state widget (spinner with brand color)

#### 1-3 — Navigation Shell
- [ ] `go_router` setup with all routes declared (screens can be empty stubs)
- [ ] `ShellRoute` for bottom nav bar
- [ ] `BottomNavBar` widget (Home, Menu, Cart with badge, Account)
- [ ] Auth redirect guard on `/account/*` and `/checkout`

#### 1-4 — Auth Screens & Flow
- [ ] `LoginScreen` (email + password, Google Sign-In button)
- [ ] `RegisterScreen` (name, email, password)
- [ ] `ForgotPasswordScreen` (email input → Supabase password reset email)
- [ ] Password reset deep link handling (Supabase sends a link that opens the app — configure URL scheme)
- [ ] `auth_provider.dart` — stream of current user, auto-refresh session
- [ ] Sign-out (clears session, redirects to home)

**Phase 1 sign-off checklist:**
- [ ] App launches, shows home stub
- [ ] Can register with email/password → session persisted after hot restart
- [ ] Can sign in with Google
- [ ] Unauthenticated user navigating to `/account` is redirected to `/login`
- [ ] After login, redirect resolves correctly
- [ ] Password reset email arrives and deep link opens app

---

### Phase 2 — Home & Menu
**Goal:** Real content from DB displayed on home and menu screens, meal detail working.

#### 2-1 — Home Screen
- [ ] `carousel_slides` query → hero carousel (`PageView` with auto-scroll)
- [ ] "Featured Meals" section → horizontal scroll of `MealCard` widgets
- [ ] "Our Plans" section → horizontal scroll of `PlanCard` widgets
- [ ] Testimonials section
- [ ] Announcement bar at top (from `site_content` table)

#### 2-2 — Menu Screen
- [ ] Fetch all categories → horizontal chip filter bar
- [ ] Fetch meals (filtered by selected category if any) → `GridView` of `MealCard`
- [ ] `MealCard` widget: image, name, category chip, price, wishlist heart button
- [ ] Pull-to-refresh
- [ ] Search bar (filter meals client-side by name)

#### 2-3 — Meal Detail Screen
- [ ] Hero image (full-width, with back button overlay)
- [ ] Name, category, price
- [ ] Description
- [ ] Nutrition facts grid (calories, protein, carbs, fat)
- [ ] Ingredients list
- [ ] Tags chips
- [ ] "Add to Cart" button (quantity selector)
- [ ] Wishlist heart button (toggle, optimistic)

#### 2-4 — Plans Screens
- [ ] `PlansScreen` → grid of `PlanCard` widgets
- [ ] `PlanDetailScreen` → plan name, duration, price, included meals list, "Add to Cart" button

**Phase 2 sign-off checklist:**
- [ ] Home loads real carousel, meals, plans, testimonials from DB
- [ ] Menu filters work (category chips)
- [ ] Search filters meal list in real-time
- [ ] Meal detail shows all data correctly
- [ ] Wishlist heart toggles (persists to DB when signed in, prompts login when not)
- [ ] Plan detail shows included meals

---

### Phase 3 — Cart & Checkout
**Goal:** Full end-to-end order placement working.

#### 3-1 — Cart
- [ ] `cart_provider.dart` — in-memory cart (list of cart items with meal/plan + quantity)
  - Cart does NOT need to persist to DB between sessions — match web app behaviour
- [ ] `CartScreen` — list of cart items, quantity +/-, remove, subtotal, promo code field, total
- [ ] Cart badge on bottom nav updates live from provider
- [ ] "Proceed to Checkout" → auth guard (redirect to login if not signed in)

#### 3-2 — Promo Code Validation
- [ ] Query `promo_codes` table — validate code is active + not expired + usage within limit
- [ ] Apply discount to order total
- [ ] Show inline error if code is invalid

#### 3-3 — Checkout & Order Placement
- [ ] `CheckoutScreen` — delivery name, phone, address, COD label, order summary, place order button
- [ ] Pre-fill name/phone from user profile if available
- [ ] `order_service.dart` — insert into `orders` + `order_items` (same schema as web app)
- [ ] On success → clear cart → navigate to `OrderConfirmationScreen`
- [ ] `OrderConfirmationScreen` — order number, summary, "Back to Home" button

**Phase 3 sign-off checklist:**
- [ ] Can add meal + plan to cart
- [ ] Quantities update correctly, remove works
- [ ] Valid promo code applies discount; invalid shows error
- [ ] Can complete checkout with real user → order appears in Supabase `orders` table
- [ ] Order confirmation screen shows after placement
- [ ] Order confirmation email arrives (sent by backend — verify in Resend dashboard)
- [ ] Cart clears after successful order

---

### Phase 4 — Account
**Goal:** Order history, order detail, wishlist, and profile editing all working.

#### 4-1 — Account Home Screen
- [ ] Signed-in: show user name/email, nav tiles (My Orders, Wishlist, Edit Profile, Sign Out)
- [ ] Signed-out: show login/register CTAs

#### 4-2 — Order History & Detail
- [ ] `OrderHistoryScreen` — list of past orders (date, total, status badge)
- [ ] `OrderDetailScreen` — order items, delivery address, status, total breakdown

#### 4-3 — Wishlist Screen
- [ ] Fetch wishlist meals for current user
- [ ] `WishlistScreen` — grid of `MealCard` with X remove button (optimistic removal)
- [ ] Empty state with "Browse Menu" CTA

#### 4-4 — Edit Profile
- [ ] Fetch current user profile (name, phone)
- [ ] Form to update name + phone → upsert to `profiles` table (or `auth.updateUser` for email/name)

**Phase 4 sign-off checklist:**
- [ ] Order history shows all past orders
- [ ] Order detail screen shows correct items and status
- [ ] Wishlist shows saved meals; X removes instantly (optimistic)
- [ ] Profile edit saves correctly

---

### Phase 5 — Polish & Pre-Release
**Goal:** App feels complete and ready for store submission.

#### 5-1 — UX Polish
- [ ] Loading skeletons on all data screens (no blank white flashes)
- [ ] Error states on all data screens ("Could not load — tap to retry")
- [ ] Empty states (no meals in category, empty cart, empty wishlist, no orders)
- [ ] All form fields have correct keyboard types, validation, and error messages
- [ ] Haptic feedback on key interactions (add to cart, wishlist toggle)
- [ ] Smooth page transitions (match go_router transition config)

#### 5-2 — App Identity
- [ ] App icon (1024×1024 PNG) → `flutter_launcher_icons` generates all sizes
- [ ] Splash screen (brand logo on white background) → `flutter_native_splash`
- [ ] App name: "SavorLean" in Android manifest + iOS Info.plist

#### 5-3 — Deep Links & URL Scheme
- [ ] Configure Android `intent-filter` + iOS `Associated Domains` for Supabase auth callbacks
  (password reset, email confirmation — Supabase sends `savorlean://` links)
- [ ] Test: password reset email → tap link → app opens on reset screen

#### 5-4 — Performance
- [ ] `cached_network_image` on all meal/plan images
- [ ] Pagination or "load more" on menu screen if meal count is large (> 50)
- [ ] No unnecessary rebuilds — review Riverpod provider scopes

**Phase 5 sign-off checklist:**
- [ ] App looks polished on a real device (no layout overflow, no jank)
- [ ] App icon and splash screen display correctly
- [ ] Deep links work end-to-end
- [ ] All error/empty states are handled gracefully

---

### Phase 6 — Push Notifications & Store Release
**Goal:** App submitted to Play Store (and App Store if required).

#### 6-1 — Push Notifications (optional, can defer)
- [ ] Set up Firebase project, add `google-services.json`
- [ ] `firebase_messaging` package — request permission on Android/iOS
- [ ] Supabase Edge Function or external trigger to send FCM push on order status change
- [ ] Notification payload: "Your order #1234 is now Out for Delivery"

#### 6-2 — Android Release Build
- [ ] Generate keystore, configure `key.properties` (gitignored)
- [ ] `flutter build appbundle --release --dart-define=...`
- [ ] Test on physical Android device

#### 6-3 — Play Store Submission
- [ ] Create Play Console app listing (title, description, screenshots, privacy policy URL)
- [ ] Upload AAB
- [ ] Internal testing track → closed testing → production

#### 6-4 — iOS Release (if required)
- [ ] Apple Developer account enrollment
- [ ] Xcode signing configuration
- [ ] `flutter build ipa --release --dart-define=...`
- [ ] App Store Connect submission

---

## 8. Effort Estimate

| Phase | Estimated effort |
|---|---|
| Phase 1 — Setup & Auth | 1–2 days |
| Phase 2 — Home & Menu | 2–3 days |
| Phase 3 — Cart & Checkout | 2–3 days |
| Phase 4 — Account | 1–2 days |
| Phase 5 — Polish & Pre-Release | 1–2 days |
| Phase 6 — Store Release | 1 day (Android) + 1–2 days (iOS) |
| **Total** | **~9–14 days of focused dev time** |

This is approximately 60–70% of the effort of the web app (Phases 1–4), because:
- No backend work at all — Supabase project is done
- No admin panel
- Design system is fully defined — just translate to Flutter widgets
- All data shapes and query patterns are known from the web codebase

---

## 9. Instructions for the New Claude Code Session

When you start work in `savorlean-mobile`, read this file first, then:

1. Read `pubspec.yaml` to understand what packages are installed.
2. Read `lib/main.dart` to understand the app entry point.
3. Read `lib/router/router.dart` to understand the navigation structure.
4. Do NOT reference or try to read files from `savorlean-web` — treat this as a standalone project.
   The backend details in this document are the only reference you need.
5. Follow the phase plan above in order. Do not skip ahead.
6. Apply the same workflow discipline as the web project:
   - Plan before implementing each phase
   - Ask before making architectural decisions
   - Update a `todo.md` (create it if not present) after each step
   - Keep a `DEVELOPMENT_LOG.md`
7. The Supabase URL and anon key are stored in `.env` at the project root (gitignored).
   Never hardcode them.

---

*Written: 2026-05-18. Web app version: v1.0.0 at `savorlean-web` commit `f620e7b`.*
