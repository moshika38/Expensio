import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/expense_model.dart';
import '../../../app/theme/app_colors.dart';
import '../../../providers/expense_provider.dart';
import '../widgets/expense_form.dart';

class EditExpenseScreen extends StatelessWidget {
  final ExpenseModel expense;

  const EditExpenseScreen({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Expense'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: ExpenseForm(
            initialExpense: expense,
            submitButtonText: 'Update Expense',
            onSubmit: ({
              required String title,
              required double amount,
              required String category,
              required DateTime date,
              String? note,
            }) async {
              final provider = context.read<ExpenseProvider>();
              final updated = expense.copyWith(
                title: title,
                amount: amount,
                category: category,
                date: date,
                note: note,
              );

              final success = await provider.updateExpense(updated);

              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Expense updated successfully!'),
                      backgroundColor: AppColors.emeraldPrimary,
                    ),
                  );
                  context.pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(provider.errorMessage ?? 'Failed to update expense'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
          ),
        ),
      ),
    );
  }
}
