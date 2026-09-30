import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../providers/expense_provider.dart';
import '../../expenses/widgets/expense_card.dart';

class RecentExpensesWidget extends StatelessWidget {
  final VoidCallback? onViewAllPressed;

  const RecentExpensesWidget({super.key, this.onViewAllPressed});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final recentList = provider.recentExpenses;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            if (recentList.isNotEmpty)
              TextButton(
                onPressed: onViewAllPressed ?? () => context.go('/expenses'),
                child: const Row(
                  children: [
                    Text('See All', style: TextStyle(color: AppColors.emeraldPrimary, fontWeight: FontWeight.bold)),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.emeraldPrimary),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (recentList.isEmpty)
          EmptyView(
            title: 'No Recent Expenses',
            description: 'Start tracking your spending by adding your first expense.',
            action: ElevatedButton.icon(
              onPressed: () => context.push('/add-expense'),
              icon: const Icon(Icons.add_rounded, color: Colors.black),
              label: const Text('Add Expense', style: TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emeraldPrimary,
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentList.length,
            itemBuilder: (context, index) {
              return ExpenseCard(expense: recentList[index]);
            },
          ),
      ],
    );
  }
}
