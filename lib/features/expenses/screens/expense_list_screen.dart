import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../providers/expense_provider.dart';
import '../widgets/expense_card.dart';
import '../widgets/expense_filter.dart';

class ExpenseListScreen extends StatelessWidget {
  const ExpenseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();

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
                                    return ExpenseCard(
                                      expense: provider.filteredExpenses[index],
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
