
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:spendly/core/theme/app_colors.dart';
import 'package:spendly/features/budgets/domain/entities/budget.dart';
import 'package:spendly/features/budgets/presentation/providers/budget_provider.dart';
import 'package:spendly/features/budgets/presentation/screens/edit_dialogue.dart';
import 'package:spendly/features/expenses/presentation/providers/expense_providers.dart';
import 'package:spendly/features/expenses/presentation/widgets/bottom_nav.dart';

class BudgetsScreen extends ConsumerStatefulWidget {
  const BudgetsScreen({super.key});

  @override
  ConsumerState<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends ConsumerState<BudgetsScreen> {
  static const Map<String, IconData> _categoryIcons = {
    'Food': Icons.restaurant_rounded,
    'Transport': Icons.directions_car_rounded,
    'Entertainment': Icons.movie_rounded,
    'Bills': Icons.receipt_long_rounded,
    'Shopping': Icons.shopping_bag_rounded,
    'Health': Icons.health_and_safety_rounded,
    'Education': Icons.school_rounded,
    'Other': Icons.category_rounded,
  };

  String formatAmount(double amount) => amount.toStringAsFixed(0);

  double spentForCategory(List<dynamic> expenses, String category) {
    return expenses
        .where((expense) => expense.category == category)
        .fold<double>(
          0,
          (total, expense) => total + expense.amount,
        );
  }

  Future<void> editBudget({
    required String title,
    required double currentLimit,
    required String category,
    required bool isMonthly,
  }) async {
    final notifier = ref.read(budgetsProvider.notifier);
    
    final newLimit = await showDialog<double>(
      context: context,
      builder: (_) => EditBudgetDialog(
        title: title,
        currentLimit: currentLimit,
        unallocatedAmount: notifier.unallocatedAmount,
        isMonthly: isMonthly,
      ),
    );

    if (!mounted || newLimit == null) return;

    try {
      await notifier.updateBudget(
        category: category,
        limit: newLimit,
        isMonthly: isMonthly,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Budget saved successfully'),
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('BUDGET SAVE ERROR: $error');
      debugPrint('STACK TRACE: $stackTrace');

      if (!mounted) return;

      final message = error is StateError
          ? error.toString().replaceFirst('Bad state: ', '')
          : 'Unable to save the budget. Please try again.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    final budgets = ref.watch(budgetsProvider);
    final expenses = ref.watch(expensesProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textColor =
        isDark ? AppColors.darkText : AppColors.lightText;
    final secondary = isDark
        ? AppColors.darkSecondaryText
        : AppColors.lightSecondaryText;
    final surface =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final background =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final primary =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    final monthlyBudgets =
        budgets.where((budget) => budget.isMonthly).toList();

    final hasMonthlyBudget = monthlyBudgets.isNotEmpty;
    final monthlyBudget =
        hasMonthlyBudget ? monthlyBudgets.first.limit : 0.0;

    final now = DateTime.now();

    final monthlyExpenses = expenses.where((expense) {
      return expense.date.year == now.year &&
          expense.date.month == now.month;
    }).toList();

    final monthlySpent = monthlyExpenses.fold<double>(
      0,
      (total, expense) => total + expense.amount,
    );

    final remainingBudget = monthlyBudget - monthlySpent;

    final monthlyProgress =
        hasMonthlyBudget && monthlyBudget > 0
            ? (monthlySpent / monthlyBudget).clamp(0.0, 1.0)
            : 0.0;

    final categoryBudgets =
        budgets.where((budget) => !budget.isMonthly).toList();

    final allocatedTotal = categoryBudgets.fold<double>(
      0,
      (total, budget) => total + budget.limit,
    );

    final unallocatedAmount = monthlyBudget - allocatedTotal;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        title: Text(
          'Budgets',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: hasMonthlyBudget
                ? 'Edit monthly budget'
                : 'Add monthly budget',
            icon: Icon(
              hasMonthlyBudget
                  ? Icons.edit_outlined
                  : Icons.add_circle_outline,
              color: primary,
            ),
            onPressed: () {
              editBudget(
                title: 'Monthly Budget',
                currentLimit: monthlyBudget,
                category: 'Monthly Budget',
                isMonthly: true,
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16.r),
        children: [
          // Monthly budget card
          Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Monthly Budget',
                  style: TextStyle(
                    color: AppColors.budgetCardSecondaryText,
                  ),
                ),
                SizedBox(height: 10.h),

                if (hasMonthlyBudget)
                  Text(
                    '₹${formatAmount(monthlyBudget)}',
                    style: TextStyle(
                      color: AppColors.budgetCardText,
                      fontSize: 30.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                else ...[
                  Text(
                    'Plan your monthly spending',
                    style: TextStyle(
                      color: AppColors.budgetCardText,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Add your monthly budget to track your expenses '
                    'and manage category limits.',
                    style: TextStyle(
                      color: AppColors.budgetCardSecondaryText,
                      fontSize: 13.sp,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.lightSurface,
                        foregroundColor: AppColors.lightPrimary,
                      ),
                      onPressed: () {
                        editBudget(
                          title: 'Monthly Budget',
                          currentLimit: 0,
                          category: 'Monthly Budget',
                          isMonthly: true,
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Monthly Budget'),
                    ),
                  ),
                ],

                if (hasMonthlyBudget) ...[
                  SizedBox(height: 20.h),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Spent',
                        style: TextStyle(
                          color: AppColors.budgetCardSecondaryText,
                        ),
                      ),
                      Text(
                        '₹${formatAmount(monthlySpent)}',
                        style: const TextStyle(
                          color: AppColors.budgetCardText,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8.h),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: LinearProgressIndicator(
                      value: monthlyProgress,
                      minHeight: 8.h,
                      backgroundColor:
                          AppColors.budgetCardProgressBackground,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(
                        AppColors.budgetCardText,
                      ),
                    ),
                  ),

                  SizedBox(height: 12.h),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(monthlyProgress * 100).toStringAsFixed(1)}% used',
                        style: const TextStyle(
                          color: AppColors.budgetCardSecondaryText,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Remaining',
                            style: TextStyle(
                              color: AppColors.budgetCardSecondaryText,
                            ),
                          ),
                          Text(
                            '₹${formatAmount(remainingBudget)}',
                            style: TextStyle(
                              color: remainingBudget < 0
                                  ? AppColors.budgetRemainingWarning
                                  : AppColors.budgetCardText,
                              fontWeight: FontWeight.bold,
                              fontSize: 18.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Show allocation details only after setting monthly budget.
          if (hasMonthlyBudget) ...[
            SizedBox(height: 12.h),

            Container(
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    color: primary,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available to allocate',
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '₹${formatAmount(allocatedTotal)} allocated',
                          style: TextStyle(
                            color: secondary,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₹${formatAmount(unallocatedAmount)}',
                    style: TextStyle(
                      color: unallocatedAmount < 0
                          ? AppColors.budgetOverBudget
                          : primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Category Budgets',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            if (categoryBudgets.isEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Text(
                  'No category budgets available.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: secondary),
                ),
              )
            else
              ...categoryBudgets.map((Budget budget) {
                final name = budget.category;
                final limit = budget.limit;
                final spent =
                    spentForCategory(monthlyExpenses, name);
                final icon =
                    _categoryIcons[name] ?? Icons.category_rounded;

                // A zero category limit means it has not been set yet.
                final isCategoryBudgetSet = limit > 0;

                final progress = isCategoryBudgetSet
                    ? (spent / limit).clamp(0.0, 1.0)
                    : 0.0;

                final percentage = isCategoryBudgetSet
                    ? (spent / limit) * 100
                    : 0.0;

                final isOverBudget =
                    isCategoryBudgetSet && spent > limit;

                final progressColor = isOverBudget
                    ? AppColors.budgetOverBudget
                    : percentage >= 90
                        ? AppColors.budgetWarning
                        : primary;

                return Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(icon, color: primary),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              name,
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (isCategoryBudgetSet)
                            Text(
                              '₹${formatAmount(spent)} / '
                              '₹${formatAmount(limit)}',
                              style: TextStyle(
                                color: secondary,
                                fontSize: 12.sp,
                              ),
                            )
                          else
                            Text(
                              'Not set',
                              style: TextStyle(
                                color: secondary,
                                fontSize: 12.sp,
                              ),
                            ),
                          IconButton(
                            tooltip: isCategoryBudgetSet
                                ? 'Edit $name budget'
                                : 'Set $name budget',
                            visualDensity: VisualDensity.compact,
                            icon: Icon(
                              isCategoryBudgetSet
                                  ? Icons.edit_outlined
                                  : Icons.add_circle_outline,
                              color: primary,
                              size: 19.r,
                            ),
                            onPressed: () {
                              editBudget(
                                title: '$name Budget',
                                currentLimit: limit,
                                category: name,
                                isMonthly: false,
                              );
                            },
                          ),
                        ],
                      ),

                      if (isCategoryBudgetSet) ...[
                        SizedBox(height: 12.h),
                        LinearProgressIndicator(
                          value: progress,
                          minHeight: 7.h,
                          borderRadius: BorderRadius.circular(8.r),
                          backgroundColor:
                              secondary.withValues(alpha: 0.15),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(
                            progressColor,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${percentage.toStringAsFixed(1)}% used',
                              style: TextStyle(
                                color: progressColor,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              isOverBudget
                                  ? '₹${formatAmount(spent - limit)} over budget'
                                  : '₹${formatAmount(limit - spent)} left',
                              style: TextStyle(
                                color: isOverBudget
                                    ? AppColors.budgetOverBudget
                                    : secondary,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              }),
          ] else ...[
            // Before a monthly budget exists, hide all category limits.
            SizedBox(height: 24.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 36.r,
                    color: secondary,
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'Category Budgets',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Add your monthly budget first. '
                    'You can then set individual category limits.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: secondary,
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      bottomNavigationBar: const SpendlyBottomNavigation(
        currentIndex: 2,
      ),
    );
  }
}

