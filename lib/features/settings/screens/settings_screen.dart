import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../providers/expense_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            // Appearance Section
            _buildSectionHeader(context, 'Appearance'),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                ),
              ),
              child: Column(
                children: [
                  _buildThemeOption(
                    context,
                    title: 'Dark Theme (Default Luxury)',
                    subtitle: 'Deep charcoal and obsidian aesthetic',
                    mode: ThemeMode.dark,
                    currentMode: provider.themeMode,
                    onSelect: provider.setThemeMode,
                  ),
                  const Divider(height: 1),
                  _buildThemeOption(
                    context,
                    title: 'Light Theme',
                    subtitle: 'Clean white and bright neutral visual mode',
                    mode: ThemeMode.light,
                    currentMode: provider.themeMode,
                    onSelect: provider.setThemeMode,
                  ),
                  const Divider(height: 1),
                  _buildThemeOption(
                    context,
                    title: 'System Default',
                    subtitle: 'Match system device appearance',
                    mode: ThemeMode.system,
                    currentMode: provider.themeMode,
                    onSelect: provider.setThemeMode,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Currency Preferences Section
            _buildSectionHeader(context, 'Currency Preference'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Default Currency',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  DropdownButton<String>(
                    value: provider.selectedCurrency,
                    dropdownColor: isDark ? AppColors.darkCard : AppColors.lightSurface,
                    underline: const SizedBox(),
                    items: AppConstants.availableCurrencies.map((symbol) {
                      return DropdownMenuItem<String>(
                        value: symbol,
                        child: Text(
                          '$symbol Currency',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    }).toList(),
                    onChanged: (newSymbol) {
                      if (newSymbol != null) {
                        provider.setCurrency(newSymbol);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Data & Firebase Status Section
            _buildSectionHeader(context, 'Data & Cloud Sync'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                ),
              ),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.emeraldPrimary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.cloud_done_rounded,
                        color: AppColors.emeraldPrimary,
                        size: 20,
                      ),
                    ),
                    title: const Text('Firebase Firestore Sync'),
                    subtitle: const Text('Real-time database active & syncing'),
                    trailing: const Icon(Icons.check_circle, color: AppColors.emeraldPrimary, size: 20),
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.refresh_rounded,
                        color: AppColors.info,
                        size: 20,
                      ),
                    ),
                    title: const Text('Reload Expenses Data'),
                    subtitle: const Text('Force refresh from cloud database'),
                    onTap: () async {
                      await provider.loadExpenses();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Expenses data refreshed successfully!'),
                            backgroundColor: AppColors.emeraldPrimary,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // About Application Section
            _buildSectionHeader(context, 'About Application'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.emeraldPrimary.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: AppColors.emeraldPrimary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppConstants.appName,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Version 1.0.0+1 • Premium Fintech',
                            style: TextStyle(fontSize: 12, color: AppColors.darkTextMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(),
                  const SizedBox(height: 10),
                  Text(
                    'Built with Flutter & Firebase Firestore. Designed with a luxury fintech visual hierarchy, clean architecture, and real-time state management.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required ThemeMode mode,
    required ThemeMode currentMode,
    required ValueChanged<ThemeMode> onSelect,
  }) {
    final isSelected = mode == currentMode;
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded, color: AppColors.emeraldPrimary)
          : const Icon(Icons.radio_button_unchecked_rounded, color: AppColors.darkTextMuted),
      onTap: () => onSelect(mode),
    );
  }
}
