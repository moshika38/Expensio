import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../providers/auth_provider.dart';

class OnboardingItem {
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;

  const OnboardingItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _pages = const [
    OnboardingItem(
      title: 'Effortless Expense Tracking',
      description: 'Log and monitor your daily personal expenses with luxury fintech speed and minimalism.',
      icon: Icons.account_balance_wallet_rounded,
      accentColor: AppColors.emeraldPrimary,
    ),
    OnboardingItem(
      title: 'Smart Spending Analytics',
      description: 'Visualize monthly totals, category breakdowns, and take control of your financial habits.',
      icon: Icons.donut_large_rounded,
      accentColor: AppColors.champagneGold,
    ),
    OnboardingItem(
      title: 'Real-Time Cloud Sync',
      description: 'Keep your financial data securely backed up and synchronized with your Google account.',
      icon: Icons.cloud_done_rounded,
      accentColor: AppColors.categoryTransport,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _finishOnboarding() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.completeOnboarding();
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Skip Action
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.emeraldPrimary.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          size: 18,
                          color: AppColors.emeraldPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Expensio',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  if (_currentPage < _pages.length - 1)
                    TextButton(
                      onPressed: _finishOnboarding,
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Page View Slider
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            color: page.accentColor.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: page.accentColor.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            page.icon,
                            size: 60,
                            color: page.accentColor,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          page.title,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          page.description,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Page Indicator Dots & Action Button
            Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.emeraldPrimary
                              : (isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  AppButton(
                    text: _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                    onPressed: () {
                      if (_currentPage < _pages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _finishOnboarding();
                      }
                    },
                    icon: _currentPage == _pages.length - 1
                        ? Icons.arrow_forward_rounded
                        : Icons.chevron_right_rounded,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
