import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class AppCategory {
  final String name;
  final IconData icon;
  final Color color;

  const AppCategory({
    required this.name,
    required this.icon,
    required this.color,
  });
}

class AppConstants {
  static const String appName = 'Expensio';
  static const String defaultCurrency = '\$';

  static const List<String> availableCurrencies = ['\$', '€', '£', '₹', '¥', 'A\$'];

  static const List<AppCategory> categories = [
    AppCategory(
      name: 'Food',
      icon: Icons.restaurant_rounded,
      color: AppColors.categoryFood,
    ),
    AppCategory(
      name: 'Transport',
      icon: Icons.directions_car_rounded,
      color: AppColors.categoryTransport,
    ),
    AppCategory(
      name: 'Shopping',
      icon: Icons.shopping_bag_rounded,
      color: AppColors.categoryShopping,
    ),
    AppCategory(
      name: 'Bills',
      icon: Icons.receipt_long_rounded,
      color: AppColors.categoryBills,
    ),
    AppCategory(
      name: 'Entertainment',
      icon: Icons.movie_rounded,
      color: AppColors.categoryEntertainment,
    ),
    AppCategory(
      name: 'Health',
      icon: Icons.medical_services_rounded,
      color: AppColors.categoryHealth,
    ),
    AppCategory(
      name: 'Education',
      icon: Icons.school_rounded,
      color: AppColors.categoryEducation,
    ),
    AppCategory(
      name: 'Other',
      icon: Icons.more_horiz_rounded,
      color: AppColors.categoryOther,
    ),
  ];

  static AppCategory getCategoryByName(String name) {
    return categories.firstWhere(
      (cat) => cat.name.toLowerCase() == name.toLowerCase(),
      orElse: () => const AppCategory(
        name: 'Other',
        icon: Icons.more_horiz_rounded,
        color: AppColors.categoryOther,
      ),
    );
  }
}
