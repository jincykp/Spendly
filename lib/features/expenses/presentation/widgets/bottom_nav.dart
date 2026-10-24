
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:spendly/core/theme/app_colors.dart';

class SpendlyBottomNavigation extends StatelessWidget {
  final int currentIndex;

  const SpendlyBottomNavigation({
    super.key,
    required this.currentIndex,
  });

  static const List<String> _routes = [
    '/dashboard',
    '/transactions',
    '/budgets',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final surface =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final secondary = isDark
        ? AppColors.darkSecondaryText
        : AppColors.lightSecondaryText;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        border: Border(
          top: BorderSide(
            color: isDark
                ? AppColors.darkDivider
                : AppColors.lightDivider,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: NavigationBar(
          selectedIndex: currentIndex,
          backgroundColor: surface,
          indicatorColor: primary.withValues(alpha: 0.14),
          elevation: 0,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (index) {
            if (index != currentIndex) {
              context.go(_routes[index]);
            }
          },
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: secondary),
              selectedIcon: Icon(Icons.home_rounded, color: primary),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined, color: secondary),
              selectedIcon:
                  Icon(Icons.receipt_long_rounded, color: primary),
              label: 'History',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined,
                  color: secondary),
              selectedIcon: Icon(
                Icons.account_balance_wallet_rounded,
                color: primary,
              ),
              label: 'Budgets',
            ),
          ],
        ),
      ),
    );
  }
}
