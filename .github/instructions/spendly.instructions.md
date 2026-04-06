---
description: "Use when writing, editing, or reviewing any Flutter/Dart code for Spendly. Covers app pages, features, navigation, database structure, state management with Riverpod, clean architecture folder structure, widget conventions, code style, and git commit rules."
applyTo: "lib/**/*.dart"
---

# Spendly – Copilot Instructions

## Project Overview

Spendly is a personal budget tracker mobile app with authentication, transaction management, and financial visualization. It is a portfolio-level project built with Flutter and Riverpod.

---

## Pages & Features

### 1. Splash Screen
- Display app logo and name with a loading indicator.
- Check user session on startup.
- Redirect to `LoginScreen` if not authenticated; redirect to `DashboardScreen` if authenticated.

### 2. Login Page (`LoginScreen`)
- Fields: email, password.
- "Remember me" checkbox.
- "Forgot password" link → `ForgotPasswordScreen`.
- "Register" link → `RegisterScreen`.
- Validate inputs before submitting.
- On success, redirect to `DashboardScreen`.

### 3. Register Page (`RegisterScreen`)
- Fields: full name, email, password, confirm password.
- "Login" link → `LoginScreen`.
- Validate all fields and confirm password match.
- Save user to database.
- On success, redirect to `LoginScreen`.

### 4. Forgot Password Page (`ForgotPasswordScreen`) *(optional if Firebase)*
- Field: email.
- "Send reset link" button triggers password reset logic.
- Back to login link.

### 5. Dashboard (`DashboardScreen`)
- Display: total balance, total income, total expenses.
- Monthly financial summary section.
- Recent transactions preview list.
- Buttons: Add Income, Add Expense, View History, View Charts.
- Real-time data updates via Riverpod providers.

### 6. Add Transaction Page (`AddTransactionScreen`)
- Transaction type selector: **Income** or **Expense**.
- Fields: amount, category (dropdown), date (date picker), notes.
- Save and Cancel buttons.
- Income categories: `Allowance`, `Salary`, `Gift`, `Side Hustle`.
- Expense categories: `Food`, `Transport`, `School`, `Bills`, `Entertainment`, `Others`.
- On save, persist to database and trigger dashboard refresh.

### 7. Transaction History Page (`TransactionHistoryScreen`)
- List all transactions sorted by latest first.
- Each item shows: date, category, amount, type (income/expense).
- Search bar.
- Filters: by type (income/expense), by category, by date.
- Edit and Delete buttons per item.

### 8. Edit Transaction Page (`EditTransactionScreen`)
- Pre-filled fields: amount, category, date, notes.
- Save Changes, Delete, and Cancel buttons.
- On save, update record in database.
- On delete, remove record and return to history.
- After update, return to `TransactionHistoryScreen`.

### 9. Charts / Reports Page (`ChartsScreen`)
- Expense pie chart broken down by category.
- Monthly income vs expense bar/line chart.
- Display totals: total income, total expense.

### 10. Profile / Settings Page (`ProfileScreen`)
- Display user name and email.
- Change password option.
- Dark mode toggle (persist preference).
- Logout button — clear session and redirect to `LoginScreen`.

---

## Navigation Structure

Use a **bottom navigation bar** with five tabs:

| Index | Label | Screen |
|-------|-------|--------|
| 0 | Home | `DashboardScreen` |
| 1 | Add | `AddTransactionScreen` |
| 2 | History | `TransactionHistoryScreen` |
| 3 | Charts | `ChartsScreen` |
| 4 | Profile | `ProfileScreen` |

---

## Database Structure

### User
| Field | Type |
|-------|------|
| id | String / int (PK) |
| name | String |
| email | String |
| password | String (hashed) |

### Transaction
| Field | Type |
|-------|------|
| id | String / int (PK) |
| user_id | String / int (FK) |
| type | String (`income` \| `expense`) |
| amount | double |
| category | String |
| date | DateTime |
| notes | String? |
| created_at | DateTime |

---

## State Management

- **Always use Riverpod** (`flutter_riverpod`) for all state management.
- **Never use `setState`** — convert any `StatefulWidget` to a `ConsumerWidget` or `ConsumerStatefulWidget` instead.
- Define providers in a dedicated `providers/` file per feature.
- Prefer `AsyncNotifierProvider` for async data and `NotifierProvider` for sync state.

```dart
// ✅ Good
final transactionsProvider = AsyncNotifierProvider<TransactionsNotifier, List<Transaction>>(
  TransactionsNotifier.new,
);

// ❌ Bad
class _MyWidgetState extends State<MyWidget> {
  void _onTap() => setState(() { ... });
}
```

## Folder Structure

Follow a feature-first clean architecture layout:

```
lib/
  main.dart
  app.dart                  # Root MaterialApp + ProviderScope
  features/
    auth/
      data/                 # Auth repository, local/remote data sources
      domain/               # User model
      presentation/
        providers/          # authProvider, sessionProvider
        screens/            # SplashScreen, LoginScreen, RegisterScreen, ForgotPasswordScreen
        widgets/
    dashboard/
      presentation/
        providers/          # dashboardSummaryProvider
        screens/            # DashboardScreen
        widgets/            # BalanceCard, RecentTransactionsList
    transactions/
      data/                 # TransactionRepository, DTO
      domain/               # Transaction model
      presentation/
        providers/          # transactionsProvider, filtersProvider
        screens/            # AddTransactionScreen, EditTransactionScreen, TransactionHistoryScreen
        widgets/            # TransactionCard, CategoryDropdown, TypeSelector
    charts/
      presentation/
        providers/          # chartDataProvider
        screens/            # ChartsScreen
        widgets/            # ExpensePieChart, MonthlyBarChart
    profile/
      presentation/
        providers/          # themeProvider, userProvider
        screens/            # ProfileScreen
        widgets/
  shared/
    widgets/                # App-wide reusable widgets (e.g. AppButton, AppTextField)
    theme/                  # Colors, text styles, ThemeData, dark mode
    utils/                  # Helpers and extensions
    constants/              # Category lists, route names
```

- One feature per folder under `lib/features/`.
- Do not place business logic inside widget files.

## Widget Conventions

- Keep widgets small and focused — extract any widget with more than ~50 lines into a separate file.
- Always use `const` constructors where possible.
- Extend `ConsumerWidget` (stateless + Riverpod) or `ConsumerStatefulWidget` (stateful + Riverpod).
- Never use bare `StatefulWidget` for app state — only for local UI-only state (e.g., animation controllers), and only when there is no Riverpod equivalent.
- Name screens with the `Screen` suffix and reusable widgets descriptively (e.g., `TransactionCard`, `CategoryBadge`).

```dart
// ✅ Good
class TransactionCard extends ConsumerWidget {
  const TransactionCard({super.key, required this.transaction});
  final Transaction transaction;

  @override
  Widget build(BuildContext context, WidgetRef ref) { ... }
}
```

## Code Style & Formatting

- Run `dart format .` before every commit.
- Follow the rules in `analysis_options.yaml`; do not suppress lints without a comment explaining why.
- Use `final` for all local variables that are not reassigned.
- Use named parameters for constructors with more than one parameter.
- Avoid deeply nested widget trees — extract intermediate widgets instead.

## Git & Commit Conventions

Use **Conventional Commits** format:

```
<type>(<scope>): <short description>

Types: feat | fix | refactor | style | chore | docs | test
Scope: optional, matches feature name (e.g. transactions, auth)

Examples:
  feat(transactions): add transaction list screen
  fix(dashboard): correct total calculation
  chore: add flutter_riverpod dependency
```

- Keep commits small and focused on one change.
- Branch names: `feature/<name>`, `fix/<name>`, `chore/<name>`.
- Never commit directly to `main` — use PRs.
