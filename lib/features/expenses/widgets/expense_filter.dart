import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_utils.dart';
import '../../../app/theme/app_colors.dart';
import '../../../providers/expense_provider.dart';

class ExpenseFilterBar extends StatelessWidget {
  const ExpenseFilterBar({super.key});

  void _showFilterBottomSheet(BuildContext context) {
    final provider = context.read<ExpenseProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    String? tempCategory = provider.selectedCategoryFilter;
    DateTime? tempDate = provider.selectedDateFilter;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                16,
                24,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)
                            .withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter Expenses',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setStateModal(() {
                            tempCategory = null;
                            tempDate = null;
                          });
                        },
                        child: const Text('Reset', style: TextStyle(color: AppColors.error)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('All Categories'),
                        selected: tempCategory == null,
                        selectedColor: AppColors.emeraldPrimary,
                        onSelected: (selected) {
                          if (selected) {
                            setStateModal(() => tempCategory = null);
                          }
                        },
                      ),
                      ...AppConstants.categories.map((cat) {
                        final isSelected = tempCategory?.toLowerCase() == cat.name.toLowerCase();
                        return ChoiceChip(
                          label: Text(cat.name),
                          selected: isSelected,
                          selectedColor: cat.color.withValues(alpha: 0.3),
                          avatar: Icon(cat.icon, size: 16, color: cat.color),
                          onSelected: (selected) {
                            setStateModal(() {
                              tempCategory = selected ? cat.name : null;
                            });
                          },
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Specific Date',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: tempDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) {
                              setStateModal(() => tempDate = picked);
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurface : AppColors.lightCardBorder,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_month_rounded,
                                  size: 18,
                                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  tempDate != null ? AppDateUtils.formatDate(tempDate!) : 'Select Date',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (tempDate != null) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => setStateModal(() => tempDate = null),
                          icon: const Icon(Icons.close_rounded, color: AppColors.error),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        provider.setCategoryFilter(tempCategory);
                        provider.setDateFilter(tempDate);
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emeraldPrimary,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final hasActiveFilters = provider.selectedCategoryFilter != null ||
        provider.selectedDateFilter != null ||
        provider.searchQuery.isNotEmpty;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                  ),
                ),
                child: TextField(
                  onChanged: (val) => provider.setSearchQuery(val),
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search expenses...',
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      size: 20,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            InkWell(
              onTap: () => _showFilterBottomSheet(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: hasActiveFilters ? AppColors.emeraldPrimary : (isDark ? AppColors.darkCard : AppColors.lightSurface),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: hasActiveFilters
                        ? AppColors.emeraldPrimary
                        : (isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
                  ),
                ),
                child: Icon(
                  Icons.filter_list_rounded,
                  color: hasActiveFilters
                      ? Colors.black
                      : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                ),
              ),
            ),
          ],
        ),
        if (hasActiveFilters) ...[
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                if (provider.selectedCategoryFilter != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Chip(
                      label: Text('Category: ${provider.selectedCategoryFilter}'),
                      onDeleted: () => provider.setCategoryFilter(null),
                      deleteIcon: const Icon(Icons.close, size: 14),
                      backgroundColor: AppColors.emeraldPrimary.withValues(alpha: 0.15),
                      side: BorderSide.none,
                    ),
                  ),
                if (provider.selectedDateFilter != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Chip(
                      label: Text('Date: ${AppDateUtils.formatDate(provider.selectedDateFilter!)}'),
                      onDeleted: () => provider.setDateFilter(null),
                      deleteIcon: const Icon(Icons.close, size: 14),
                      backgroundColor: AppColors.emeraldPrimary.withValues(alpha: 0.15),
                      side: BorderSide.none,
                    ),
                  ),
                TextButton.icon(
                  onPressed: () => provider.clearFilters(),
                  icon: const Icon(Icons.clear_all, size: 16, color: AppColors.error),
                  label: const Text('Clear All', style: TextStyle(fontSize: 12, color: AppColors.error)),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
