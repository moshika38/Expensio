# Expensio – Expense Tracker Application

Expensio is a modern, high-end, luxury fintech Flutter application designed for seamless daily personal finance tracking. Built with clean software architecture, Google Authentication, real-time Firebase Firestore cloud persistence per user, and state management via `Provider`, Expensio delivers a production-grade experience with an intuitive user interface, rich visual hierarchy, and robust data handling.

---

## 🌟 Key Features

### 1. Google Authentication
- **Google Sign-In Only**: Fast, secure authentication using Google account credentials via Firebase Auth.
- **Session Persistence**: Returning authenticated users are seamlessly restored directly to their dashboard.
- **Graceful Error & Cancellation Handling**: Clear user feedback during sign-in attempts, network disruptions, or prompt cancellations.

### 2. Onboarding Flow
- **First Launch Experience**: Polished 3-page onboarding carousel introducing core app benefits:
  1. *Effortless Expense Tracking*
  2. *Smart Spending Analytics*
  3. *Real-Time Cloud Sync*
- **Local Persistence**: Stores completion status via `SharedPreferences` so returning users bypass onboarding directly to Login or Home.

### 3. Google Profile Information & Compact Panel
- Automatic retrieval of Google profile metadata (Display Name, Email Address, and Google Profile Photo URL).
- **Header Avatar & Compact Profile Sheet**: Tapping the top-right avatar on the Dashboard opens an elegant modal sheet displaying profile details and a prominent **Sign Out** button.

### 4. User-Scoped Firestore Storage
- Expenses are isolated per authenticated user in Firebase Firestore under:
  ```text
  users/{uid}/expenses/{expenseId}
  ```
- Ensures complete privacy and security — users can only view and manage their own financial data.

### 5. Expense Management (CRUD)
- **Add Expense**: Record new expenses with title, amount, category, date picker, and optional notes.
- **Edit Expense**: Pre-filled update screen allowing instant modification of existing transaction records.
- **Delete Expense**: Swipe or tap to delete with safety confirmation modal.
- **Expense Details**: Comprehensive modal sheet displaying formatted currency, category badges, full notes, and metadata.

### 6. Sensible Predefined Categories
- Food, Transport, Shopping, Bills, Entertainment, Health, Education, Other.
- Distinct luxury color badges and custom icons for visual categorization.

### 7. Smart Dashboard Overview
- **Monthly Summary Card**: Displays current month's total spending, transaction count, and overall total in an obsidian/emerald luxury gradient container.
- **Category Spending Chart**: Interactive visual breakdown showing spending distribution by category.
- **Recent Transactions**: Quick access list of recent 5 transactions with direct navigation to full history.

### 8. Search & Multi-Filter Capabilities
- Real-time search by title, category name, or note.
- Filter expenses by specific category or date range.
- Filter status chips with quick reset options.

### 9. Customization & Preferences
- **Theme Mode**: Switch dynamically between Dark Mode (Default Luxury), Light Mode, and System Default.
- **Currency Selector**: Select default currency symbol (`$`, `€`, `£`, `₹`, `¥`, `A$`).

---

## 🏗️ Project Architecture & Folder Structure

The project strictly follows the requested architectural layout:

```
lib/
├── main.dart                      # Application entry point with Firebase initialization
│
├── app/
│   ├── app.dart                   # ExpensioApp root with MultiProvider (Auth & Expense) & MaterialApp.router
│   ├── routes.dart                # Centralized declarative navigation using go_router & Auth redirect guard
│   └── theme/
│       ├── app_theme.dart         # Material 3 Light & Dark theme data definitions
│       ├── app_colors.dart        # Luxury fintech color palette (Obsidian, Emerald Accent)
│       └── app_text_styles.dart   # Typography scale hierarchy
│
├── core/
│   ├── constants/
│   │   ├── app_constants.dart     # Categories, currency defaults, and global strings
│   │   └── app_assets.dart        # Asset path constants
│   │
│   ├── utils/
│   │   ├── validators.dart        # Form input validators (title, amount, category, date)
│   │   ├── date_utils.dart        # Date formatting, relative dates, and month checkers
│   │   └── currency_utils.dart    # Currency symbol & decimal formatting utilities
│   │
│   └── widgets/
│       ├── app_button.dart        # Styled primary, secondary, and outline buttons
│       ├── app_text_field.dart    # Custom text form input field
│       ├── loading_view.dart      # Loading spinner & shimmer view
│       ├── empty_view.dart        # Custom empty state display
│       └── error_view.dart        # Error state view with retry action
│
├── data/
│   ├── models/
│   │   └── expense_model.dart     # Expense data model with Firestore serialization
│   │
│   ├── services/
│   │   ├── auth_service.dart      # Firebase Auth & Google Sign-In wrapper
│   │   ├── firebase_service.dart  # Firestore user-scoped collection manager
│   │   └── expense_service.dart   # Firestore CRUD operations & real-time streams
│   │
│   └── repositories/
│       ├── auth_repository.dart   # Auth repository handling session & user state
│       └── expense_repository.dart# Repository pattern with offline fallback cache
│
├── features/
│   ├── onboarding/
│   │   └── screens/
│   │       └── onboarding_screen.dart # 3-page luxury onboarding slider
│   │
│   ├── auth/
│   │   └── screens/
│   │       └── login_screen.dart  # Minimal luxury Login screen with Google button
│   │
│   ├── home/
│   │   ├── screens/
│   │   │   └── home_screen.dart   # Dashboard screen with bottom navigation & top header
│   │   └── widgets/
│   │       ├── monthly_summary.dart  # Luxury monthly summary card
│   │       ├── expense_chart.dart   # Visual category spending breakdown
│   │       ├── recent_expenses.dart # Recent transaction list widget
│   │       └── profile_bottom_sheet.dart # Compact profile popup with Google account info
│   │
│   ├── expenses/
│   │   ├── screens/
│   │   │   ├── expense_list_screen.dart # Expense history list with search & filter
│   │   │   ├── add_expense_screen.dart  # Add expense container screen
│   │   │   └── edit_expense_screen.dart # Edit expense container screen
│   │   │
│   │   └── widgets/
│   │       ├── expense_card.dart  # Interactive expense card tile & details sheet
│   │       ├── expense_form.dart  # Reusable form with full validation
│   │       ├── category_selector.dart# Category grid picker widget
│   │       └── expense_filter.dart# Filter bottom sheet and active filter chips
│   │
│   └── settings/
│       └── screens/
│           └── settings_screen.dart# Theme switcher, currency selector & app info
│
└── providers/
    ├── auth_provider.dart         # State manager for Google Auth, user profile, and onboarding state
    └── expense_provider.dart      # Central state manager for user-scoped expenses & UI preferences
```

---

## 🛠️ Tech Stack & Requirements

- **Framework**: Flutter (SDK `^3.12.2` / Flutter 3.x)
- **Language**: Dart 3.x
- **State Management**: `provider (^6.1.5)`
- **Routing**: `go_router (^17.5.0)`
- **Authentication**: `firebase_auth (^6.7.0)`, `google_sign_in (^7.2.0)`
- **Database**: `cloud_firestore (^6.10.0)`, `firebase_core (^4.15.0)`
- **Local Storage**: `shared_preferences (^2.5.5)`
- **Utilities**: `intl (^0.20.3)`

---

## 🚀 How to Run the Application

### 1. Prerequisites
Ensure you have Flutter SDK installed and configured on your machine:
```bash
flutter doctor
```

### 2. Install Dependencies
Navigate to the root directory and get pub packages:
```bash
flutter pub get
```

### 3. Run Static Analysis & Tests
Verify code quality and run unit tests:
```bash
flutter analyze
flutter test
```

### 4. Launch the App
Run on a connected emulator or physical device:
```bash
flutter run
```

---

## 🔥 Firebase Setup Instructions

1. **Firebase Configuration**:
   The project includes `lib/firebase_options.dart` and `android/app/google-services.json` configured for Firebase project `expensio-d9892`.

2. **Google Sign-In Configuration**:
   Google Sign-In is enabled in Firebase Authentication console. SHA-1 fingerprint is linked in Google Cloud Console.

3. **Firestore Security & Structure**:
   Documents are saved under `users/{uid}/expenses/{expenseId}`.
   Document fields:
   - `title` (`String`)
   - `amount` (`double`)
   - `category` (`String`)
   - `date` (`Timestamp`)
   - `note` (`String`)
   - `createdAt` (`Timestamp`)

---

## 📦 Build Instructions (APK / Bundle)

To build a release APK for Android:
```bash
flutter build apk --release
```
The output APK file will be located at: `build/app/outputs/flutter-apk/app-release.apk`.

---

## 🤖 AI Tools Usage & Assistance Explanation

AI tools (Antigravity AI Assistant by Google DeepMind team) were utilized during the development of Expensio:

1. **Architectural Planning**:
   - Structured the application into clean modular layers (`app`, `core`, `data`, `features`, `providers`) following the precise required folder structure.
   - Configured `go_router` with authentication redirect guards (`AuthProvider.isAuthenticated`, `isOnboardingCompleted`) and `ChangeNotifierProxyProvider` for user-scoped expense state synchronization.

2. **UI/UX Design Systems**:
   - Designed the luxury fintech visual aesthetic using dark charcoal backgrounds, emerald accents, champagne gold highlights, subtle borders, and consistent typography across Onboarding, Login, Dashboard, and Profile bottom sheet.

3. **Firebase & Data Flow Integration**:
   - Integrated Google Sign-In with Firebase Auth and scoped Firestore expenses per user UID (`users/{uid}/expenses`).
   - Implemented real-time Firestore stream handling in `ExpenseService` and built fallback resilience in `ExpenseRepository`.

4. **Code Quality & Refactoring**:
   - Ran static analysis (`flutter analyze`), automatically resolved lint warnings, and ensured zero static analysis errors across all Dart files.

---

## 📄 License
This project is created for internship practical task requirements. All rights reserved.
