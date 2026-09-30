import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../providers/expense_provider.dart';
import '../widgets/expense_form.dart';

class AddExpenseScreen extends StatelessWidget {
  const AddExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Expense'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: ExpenseForm(
            submitButtonText: 'Add Expense',
            onSubmit: ({
              required String title,
              required double amount,
              required String category,
              required DateTime date,
              String? note,
            }) async {
              final provider = context.read<ExpenseProvider>();
              final success = await provider.addExpense(
                title: title,
                amount: amount,
                category: category,
                date: date,
                note: note,
              );

              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Expense added successfully!'),
                      backgroundColor: AppColors.emeraldPrimary,
                    ),
                  );
                  context.pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(provider.errorMessage ?? 'Failed to save expense'),
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
