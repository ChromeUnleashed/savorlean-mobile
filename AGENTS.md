# AGENTS.md — Agent Rules & Project Conventions (Flutter / Mobile)

## SavorLean Mobile — Diet Meal Plan App

This file defines the behavioral rules, coding conventions, and workflow constraints that the AI agent
must follow throughout the entire development of this project. These rules apply to every phase and
every file touched.

> **Note:** This is the Flutter-adapted version of the web project's AGENTS.md. The web project lives
> at `savorlean-web`. The backend (Supabase) is shared — do not modify the database schema without
> explicit user confirmation.

---

## 1. Branding

- The brand name is **SavorLean**. Use this name consistently everywhere: app title, screens,
  navigation labels, loading messages, error copy, and any placeholder or dummy text.
- Never use generic placeholder names like "MyApp," "DietApp," or "MealPlan" anywhere in the codebase.

---

## 2. Code Comments (Required)

Every file written by the agent must contain clear, plain-English comments throughout. The goal is
that the client — who may not have coding experience — can open any file and understand what each
section is doing at a high level.

**Rules for comments:**

- At the top of every file, write a short block comment (2–4 lines) explaining what this file is for
  and how it fits into the project.
- Before every function, write a comment explaining: what the function does, what inputs it takes,
  and what it returns.
- Before any block of logic that is not immediately obvious (conditional logic, data transformations,
  API calls, etc.), write an inline comment explaining what it does and why.
- Use plain, simple English. Avoid jargon. Write as if explaining to someone who has never seen code
  before.
- Comments must be kept up to date — if code is changed, the comment describing it must also be updated.

**Example of the expected comment style (Dart):**

```dart
/// MealCard widget
/// Displays a single meal as a card in the menu grid.
/// Shows the meal image, name, category, price, and a wishlist heart button.
/// Used on the Menu screen and the Home screen's Featured Meals section.
class MealCard extends StatelessWidget {
  /// Adds the selected meal to the shopping cart.
  /// If the meal is already in the cart, increases quantity by 1 instead.
  void _handleAddToCart(BuildContext context, Meal meal) {
    // Get the current cart from the provider
    final cart = ref.read(cartProvider.notifier);

    // Check if this meal already exists in the cart
    if (cart.contains(meal.id)) {
      // Meal is already in cart — just increase the quantity
      cart.incrementQuantity(meal.id);
    } else {
      // Meal is new to the cart — add it with quantity of 1
      cart.addItem(meal);
    }
  }
}
```

---

## 3. Git & GitHub Rules

- **Never push to the repository without explicit user confirmation.** Before every `git push`, stop
  and ask: _"I'm ready to push the following commits to GitHub. Shall I proceed?"_ Wait for a clear
  "yes" before pushing.
- Write descriptive commit messages. Format: `type(scope): short description` — e.g.,
  `feat(menu): add category filter chips`, `fix(cart): correct quantity update logic`.
- Commit at logical checkpoints — not after every single file change, and not in one giant commit at
  the end of a phase.
- Never commit `dart_defines.json` or any file containing real API keys, secrets, or credentials.
- `.gitignore` must always include: `dart_defines.json`, `*.jks`, `*.keystore`, `key.properties`,
  `.dart_tool/`, `build/`.

---

## 4. Environment & Secrets Rules

- All sensitive values (Supabase URL, Supabase anon key) must live in `dart_defines.json` only
  (gitignored). Never hardcode them in source code — not even temporarily "for testing."
- Pass credentials at run/build time via `--dart-define-from-file=dart_defines.json`.
- Read in Dart code via `const String.fromEnvironment('SUPABASE_URL')`.
- Maintain a `dart_defines.example.json` at all times with all required key names but no real values,
  so a new developer knows what to fill in.
- When a new environment variable is needed, add it to `dart_defines.example.json` immediately and
  tell the user exactly what value to place in their `dart_defines.json`.

---

## 5. Project Architecture (Critical)

Strict separation between data, business logic, and UI:

```
lib/
  models/       ← Data model classes (Meal, Order, etc.) — plain Dart, no Flutter imports
  services/     ← All Supabase queries live here. Screens/widgets never call Supabase directly.
  providers/    ← Riverpod providers — bridge between services and UI
  screens/      ← Full-screen widgets (one file per screen)
  widgets/      ← Reusable UI components (MealCard, AppButton, etc.)
  theme/        ← Colors, text styles, ThemeData — no business logic
  router/       ← go_router configuration
```

- Screens and widgets must only interact with Riverpod providers — never call service functions directly.
- All Supabase queries live exclusively in `lib/services/`. If a screen needs data, it goes through
  a provider that calls a service.
- Models are plain Dart classes with no Flutter imports.

---

## 6. Dart & Code Quality

- All code must be Dart. No code generation shortcuts that obscure logic.
- Define explicit types for all data models. No use of `dynamic` unless unavoidable with type narrowing.
- No unused imports, variables, or functions. Run `dart fix` before committing.
- Prefer `final` over `var` for local variables. Use `const` constructors wherever possible.
- All async functions must have proper error handling (`try/catch`).
- Use `riverpod_annotation` + `@riverpod` code generation for providers (keeps providers consistent).

---

## 7. Widget & File Conventions

- One widget per file. File name matches the widget name in snake_case (e.g., `meal_card.dart`).
- Keep widgets small and composable. If a widget exceeds ~150 lines, consider splitting it.
- All screen-level widgets go in `lib/screens/[feature]/[feature]_screen.dart`.
- Shared UI widgets (buttons, inputs, cards, etc.) go in `lib/widgets/common/`.
- Feature-specific widgets go in `lib/widgets/[feature]/`.
- Use `StatelessWidget` by default. Use `ConsumerWidget` (Riverpod) when the widget needs provider
  access. Only use `StatefulWidget` when local ephemeral state is needed that doesn't belong in a provider.

---

## 8. Styling Rules

- All colors must come from `lib/theme/app_colors.dart` — never use raw hex values inline.
- All text styles must come from `lib/theme/app_text_styles.dart`.
- Never hardcode font sizes, colors, or spacing as magic numbers in widget code.
- Use the design system defined in `mobile_plan.md §3` consistently — do not introduce ad-hoc values.
- All UI must be tested on both small screens (360px wide) and large screens (420px wide).

---

## 9. Asking Before Acting

The agent must pause and ask the user before taking any of the following actions:

1. Pushing code to GitHub.
2. Making any change to the Supabase database schema.
3. Deleting any file or directory.
4. Installing or removing any Flutter package (`pubspec.yaml` changes).
5. Changing the navigation/routing structure.
6. Changing any model class in `lib/models/` (affects all layers above it).

For all other routine implementation tasks, the agent may proceed without asking.

---

## 10. Task Verification & Completion (Critical)

**The two-step confirmation process — follow this exactly, every time:**

**Step 1 — Verification gate (before touching `todo.md`):**

After completing and testing a miniphase, stop and say something like:

> _"[Miniphase name] is complete. I tested it and found no issues — [brief evidence]. Go ahead and
> check it out yourself on a device or emulator. Let me know if you find any issues or need tweaks.
> Once you're happy, give me the signal and I'll mark it complete in `todo.md`."_

Then wait. Do not touch `todo.md`, do not update logs, do not commit.

**Step 2 — Commit gate (after `todo.md` is updated):**

Once the user confirms, update `todo.md` and `DEVELOPMENT_LOG.md`, then stop and ask:

> _"I've marked the task complete and updated the logs. Should I go ahead and commit the changes?"_

Then wait. Do not commit or push until the user says yes.

**What counts as user confirmation:**
Any clear positive signal — "yes", "go ahead", "mark it", "looks good", "ship it".

**What is never allowed:**
- Marking `[x]` in `todo.md` before the user confirms.
- Committing or pushing before the user confirms.
- Combining both gates into a single "I'll mark it done and commit" action.

**Phase transitions:**
Before moving from one phase to the next, the agent must:
1. Present the full acceptance criteria checklist for the completed phase.
2. Confirm with the user that every item passes.
3. Create a clearly labelled git commit marking the phase as complete.
4. Only then begin the next phase.

**The rule is simple: the user decides when something is done, not the agent.**

---

## 11. Supabase Rules (Flutter)

- Use `supabase_flutter` package for all database and auth interactions.
- Initialise the Supabase client once in `main.dart` via `Supabase.initialize(url:, anonKey:)`.
- After init, access the client anywhere via `Supabase.instance.client` — do not pass it around manually.
- Never use the `service_role` key in the Flutter app. The anon key + RLS is the correct pattern.
- RLS (Row Level Security) is already enabled on all tables. Never ask to disable RLS to fix a bug —
  fix the query or the policy instead.
- Do not modify the database schema — it is managed by the web project. If a schema change is needed,
  flag it to the user and it will be done in the `savorlean-web` project.

---

## 12. Subscription Plan Rules

- The word "subscription" refers to a **meal plan package** — it does not mean recurring billing.
- All subscription plan orders are **one-time payments**. Never imply recurring charge or auto-renewal.
- The plan detail screen must display the one-time payment notice clearly and prominently.

---

## 13. Checkout & Order Rules

- The **Meal Instructions** text field must always be present and visible on the checkout screen,
  clearly labelled as optional.
- Its value must be saved to the `meal_instructions` column on the `orders` table.
- The delivery address, bank transfer details, and WhatsApp number must always be read from the
  `site_settings` table — never hardcoded.

---

## 14. Error Handling & UX Polish

- Every data fetch must have a loading state. Use skeleton loaders for content areas — not bare spinners.
- Every data fetch must have an error state with a user-friendly message. Never expose raw Supabase
  error objects or stack traces to the user.
- Form submissions must have client-side validation before the API is called.
- All destructive actions (remove from wishlist, cancel order) must show a confirmation dialog.
- All async user actions must give visible feedback: loading indicator on the button while in progress,
  and a snackbar/toast on success or failure.

---

## 15. Currency & Locale

- All prices are in Pakistani Rupees (PKR).
- Display format: `Rs. 1,200` (comma as thousands separator, no decimal places unless necessary).
- No other currency is referenced anywhere.
- Do not integrate any payment gateway or card-payment UI.
- Pakistani phone number format: `+92 XXX XXXXXXX`.

---

## 16. Code Formatting

- Run `dart format .` on all changed files before every commit.
- Follow standard Dart style guide conventions (enforced by `dart format`).
- Use `dart fix --apply` to resolve any lint warnings before committing.
- The `analysis_options.yaml` at the project root defines lint rules — do not weaken them.

---

## 17. Testing Rules

- Write widget tests for all critical UI flows (login, add to cart, checkout).
- Write unit tests for all service functions that contain business logic (promo validation,
  cart total calculation, order placement).
- Test files live in `test/` mirroring the `lib/` structure: `lib/services/meal_service.dart` →
  `test/services/meal_service_test.dart`.
- Before marking a phase as complete, all tests must pass. Run `flutter test` and show output.
- Use `mocktail` package to mock Supabase client in unit tests.

---

## 18. Asking Before Acting — Complete List

The agent must pause and ask the user before **any** of these actions:

1. Pushing code to GitHub.
2. Making any change to the Supabase database schema.
3. Deleting any file or directory.
4. Installing or removing any Flutter package (`pubspec.yaml` changes).
5. Changing the navigation/routing structure.
6. Changing any model class in `lib/models/`.
7. Marking any task as complete (`[x]`) in `todo.md`.
8. Transitioning to the next project phase.
