import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../providers/expense_provider.dart';
import '../widgets/expense_card.dart';
import '../widgets/month_selector.dart';
import '../widgets/expense_filter.dart';
import '../../../core/utils/currency_utils.dart';

class ExpenseListScreen extends StatelessWidget {
  const ExpenseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses History'),
        actions: [
          IconButton(
            onPressed: () => context.push('/add-expense'),
            icon: const Icon(Icons.add_rounded, color: AppColors.emeraldPrimary),
            tooltip: 'Add Expense',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Month Selector Bar
              const MonthSelectorBar(),
              const SizedBox(height: 12),
              // Quick Month Summary Stats Pill Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.emeraldPrimary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.emeraldPrimary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${provider.filteredExpenses.length} Transactions',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'Total: ',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          ),
                        ),
                        Text(
                          CurrencyUtils.formatAmount(provider.currentMonthTotal, symbol: provider.selectedCurrency),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.emeraldPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const ExpenseFilterBar(),
              const SizedBox(height: 16),
              Expanded(
                child: provider.isLoading && provider.expenses.isEmpty
                    ? const LoadingView(message: 'Loading expenses...')
                    : provider.errorMessage != null && provider.expenses.isEmpty
                        ? ErrorView(
                            message: provider.errorMessage!,
                            onRetry: () => provider.loadExpenses(),
                          )
                        : provider.filteredExpenses.isEmpty
                            ? RefreshIndicator(
                                onRefresh: () => provider.loadExpenses(),
                                color: AppColors.emeraldPrimary,
                                child: ListView(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  children: [
                                    const SizedBox(height: 40),
                                    EmptyView(
                                      title: 'No Matching Expenses',
                                      description: 'Try adjusting your search or category filter.',
                                      action: OutlinedButton.icon(
                                        onPressed: () => provider.clearFilters(),
                                        icon: const Icon(Icons.refresh_rounded),
                                        label: const Text('Clear Filters'),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: () => provider.loadExpenses(),
                                color: AppColors.emeraldPrimary,
                                child: ListView.builder(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  itemCount: provider.filteredExpenses.length,
                                  itemBuilder: (context, index) {
                                    final expense = provider.filteredExpenses[index];
                                    return ExpenseCard(
                                      key: ValueKey(expense.id.isNotEmpty ? expense.id : 'expense_$index'),
                                      expense: expense,
                                    );
                                  },
                                ),
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
