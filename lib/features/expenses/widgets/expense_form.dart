import 'package:flutter/material.dart';
import '../../../data/models/expense_model.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/date_utils.dart';
import '../../../app/theme/app_colors.dart';
import 'category_selector.dart';

class ExpenseForm extends StatefulWidget {
  final ExpenseModel? initialExpense;
  final Future<void> Function({
    required String title,
    required double amount,
    required String category,
    required DateTime date,
    String? note,
  }) onSubmit;
  final String submitButtonText;

  const ExpenseForm({
    super.key,
    this.initialExpense,
    required this.onSubmit,
    this.submitButtonText = 'Save Expense',
  });

  @override
  State<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _noteController;

  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  String? _categoryError;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialExpense?.title ?? '');
    _amountController = TextEditingController(
      text: widget.initialExpense != null ? widget.initialExpense!.amount.toStringAsFixed(2) : '',
    );
    _noteController = TextEditingController(text: widget.initialExpense?.note ?? '');
    _selectedCategory = widget.initialExpense?.category;
    _selectedDate = widget.initialExpense?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.emeraldPrimary,
                  onPrimary: Colors.black,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _handleSubmit() async {
    setState(() {
      _categoryError = Validators.validateCategory(_selectedCategory);
    });

    if (!_formKey.currentState!.validate() || _categoryError != null) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final amount = double.parse(_amountController.text.trim());

    await widget.onSubmit(
      title: _titleController.text.trim(),
      amount: amount,
      category: _selectedCategory!,
      date: _selectedDate,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
    );

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Amount Field with currency symbol
          AppTextField(
            label: 'Amount',
            hint: '0.00',
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefixIcon: Icons.attach_money_rounded,
            validator: Validators.validateAmount,
          ),
          const SizedBox(height: 20),

          // Title Field
          AppTextField(
            label: 'Title',
            hint: 'e.g. Grocery Shopping, Lunch, Gas',
            controller: _titleController,
            prefixIcon: Icons.edit_note_rounded,
            validator: Validators.validateTitle,
          ),
          const SizedBox(height: 20),

          // Category Selector
          CategorySelector(
            selectedCategory: _selectedCategory,
            onCategorySelected: (category) {
              setState(() {
                _selectedCategory = category;
                _categoryError = null;
              });
            },
            errorText: _categoryError,
          ),
          const SizedBox(height: 20),

          // Date Picker
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Date',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 20,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        AppDateUtils.formatDate(_selectedDate),
                        style: TextStyle(
                          fontSize: 15,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_drop_down_rounded,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Note Field (Optional)
          AppTextField(
            label: 'Note (Optional)',
            hint: 'Add extra details or comments...',
            controller: _noteController,
            maxLines: 3,
            prefixIcon: Icons.notes_rounded,
          ),
          const SizedBox(height: 32),

          // Submit Button
          AppButton(
            text: widget.submitButtonText,
            onPressed: _handleSubmit,
            isLoading: _isSubmitting,
            icon: widget.initialExpense == null ? Icons.add_rounded : Icons.check_rounded,
          ),
        ],
      ),
    );
  }
}
