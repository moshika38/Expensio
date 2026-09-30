import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/expense_provider.dart';
import 'theme/app_theme.dart';
import 'routes.dart';

class ExpensioApp extends StatelessWidget {
  const ExpensioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ExpenseProvider>(
          create: (_) => ExpenseProvider(),
          update: (_, authProvider, expenseProvider) {
            final provider = expenseProvider ?? ExpenseProvider();
            provider.setUserUid(authProvider.user?.uid);
            return provider;
          },
        ),
      ],
      child: Consumer2<AuthProvider, ExpenseProvider>(
        builder: (context, authProvider, expenseProvider, child) {
          final router = AppRoutes.createRouter(authProvider);

          return MaterialApp.router(
            title: 'Expensio – Expense Tracker',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: expenseProvider.themeMode,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
