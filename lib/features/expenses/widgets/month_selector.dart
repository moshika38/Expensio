import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../providers/expense_provider.dart';

class MonthSelectorBar extends StatelessWidget {
  const MonthSelectorBar({super.key});

  Future<void> _pickMonth(BuildContext context, ExpenseProvider provider) async {
    final DateTime initialDate = provider.selectedMonth;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDatePickerMode: DatePickerMode.year,
      helpText: 'SELECT EXPENSE MONTH',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).brightness == Brightness.dark
                ? const ColorScheme.dark(
                    primary: AppColors.emeraldPrimary,
                    onPrimary: Colors.black,
                    surface: AppColors.darkCard,
                    onSurface: Colors.white,
                  )
                : const ColorScheme.light(
                    primary: AppColors.emeraldPrimary,
                    onPrimary: Colors.black,
                    surface: Colors.white,
                    onSurface: Colors.black,
                  ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      provider.setSelectedMonth(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final String monthString = DateFormat('MMMM yyyy').format(provider.selectedMonth);
    final isAllTime = provider.isAllTimeFilter;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Month Selector Navigation Controls
          Row(
            children: [
              // Previous Month Arrow Button
              IconButton(
                onPressed: isAllTime ? null : () => provider.previousMonth(),
                icon: const Icon(Icons.chevron_left_rounded, size: 24),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                disabledColor: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                tooltip: 'Previous Month',
              ),
              const SizedBox(width: 4),

              // Month Display & Picker Button
              InkWell(
                onTap: () => _pickMonth(context, provider),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_month_rounded,
                        size: 18,
                        color: isAllTime
                            ? (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)
                            : AppColors.emeraldPrimary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isAllTime ? 'All Time Overview' : monthString,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isAllTime
                              ? (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)
                              : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_drop_down_rounded,
                        size: 20,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 4),
              // Next Month Arrow Button
              IconButton(
                onPressed: isAllTime ? null : () => provider.nextMonth(),
                icon: const Icon(Icons.chevron_right_rounded, size: 24),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                disabledColor: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                tooltip: 'Next Month',
              ),
            ],
          ),

          // "All Time" Toggle Chip
          FilterChip(
            selected: isAllTime,
            onSelected: (_) => provider.toggleAllTime(),
            label: const Text('All Time'),
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isAllTime
                  ? Colors.black
                  : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
            ),
            selectedColor: AppColors.emeraldPrimary,
            backgroundColor: isDark
                ? AppColors.emeraldPrimary.withValues(alpha: 0.1)
                : AppColors.lightCardBorder,
            checkmarkColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isAllTime
                    ? AppColors.emeraldPrimary
                    : (isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
          ),
        ],
      ),
    );
  }
}
