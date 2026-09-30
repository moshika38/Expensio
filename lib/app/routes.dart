import 'package:go_router/go_router.dart';
import '../data/models/expense_model.dart';
import '../providers/auth_provider.dart';
import '../features/onboarding/screens/onboarding_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/expenses/screens/expense_list_screen.dart';
import '../features/expenses/screens/add_expense_screen.dart';
import '../features/expenses/screens/edit_expense_screen.dart';
import '../features/settings/screens/settings_screen.dart';

class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String home = '/';
  static const String expenses = '/expenses';
  static const String addExpense = '/add-expense';
  static const String editExpense = '/edit-expense';
  static const String settings = '/settings';

  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: home,
      refreshListenable: authProvider,
      redirect: (context, state) {
        if (authProvider.isInitializing) {
          return null;
        }

        final isOnboarding = state.matchedLocation == onboarding;
        final isLoggingIn = state.matchedLocation == login;

        // 1. If first time launch and onboarding not completed -> redirect to onboarding
        if (!authProvider.isOnboardingCompleted && !isOnboarding) {
          return onboarding;
        }

        // 2. If onboarding completed but not authenticated -> redirect to login
        if (authProvider.isOnboardingCompleted && !authProvider.isAuthenticated && !isLoggingIn) {
          return login;
        }

        // 3. If authenticated and trying to access login/onboarding -> redirect to home
        if (authProvider.isAuthenticated && (isLoggingIn || isOnboarding)) {
          return home;
        }

        return null;
      },
      routes: [
        GoRoute(
          path: onboarding,
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: home,
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: expenses,
          builder: (context, state) => const ExpenseListScreen(),
        ),
        GoRoute(
          path: addExpense,
          builder: (context, state) => const AddExpenseScreen(),
        ),
        GoRoute(
          path: editExpense,
          builder: (context, state) {
            final expense = state.extra as ExpenseModel;
            return EditExpenseScreen(expense: expense);
          },
        ),
        GoRoute(
          path: settings,
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    );
  }
}
