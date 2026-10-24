
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:spendly/core/theme/app_colors.dart';
import 'package:spendly/features/expenses/presentation/widgets/bottom_nav.dart';

class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key});

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  double monthlyBudget = 30000;
  final double monthlySpent = 18450;

  final List<Map<String, dynamic>> categoryBudgets = [
    {
      'name': 'Food',
      'limit': 5000.0,
      'spent': 3200.0,
      'icon': Icons.restaurant_rounded,
    },
    {
      'name': 'Transport',
      'limit': 3000.0,
      'spent': 1200.0,
      'icon': Icons.directions_car_rounded,
    },
    {
      'name': 'Entertainment',
      'limit': 2000.0,
      'spent': 649.0,
      'icon': Icons.movie_rounded,
    },
    {
      'name': 'Bills',
      'limit': 4000.0,
      'spent': 1450.0,
      'icon': Icons.receipt_long_rounded,
    },
  ];

  String formatAmount(double amount) {
    return amount.toStringAsFixed(0);
  }

  Future<void> editBudget({
    required String title,
    required double currentLimit,
    required ValueChanged<double> onSave,
  }) async {
    final newLimit = await showDialog<double>(
      context: context,
      builder: (dialogContext) {
        return _EditBudgetDialog(
          title: title,
          currentLimit: currentLimit,
        );
      },
    );

    if (!mounted || newLimit == null) return;

    setState(() {
      onSave(newLimit);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textColor = isDark
        ? AppColors.darkText
        : AppColors.lightText;

    final secondary = isDark
        ? AppColors.darkSecondaryText
        : AppColors.lightSecondaryText;

    final surface = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;

    final background = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;

    final primary = isDark
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;

    final remainingBudget = monthlyBudget - monthlySpent;

    final monthlyProgress =
        (monthlySpent / monthlyBudget).clamp(0.0, 1.0);

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
            tooltip: 'Edit monthly budget',
            icon: Icon(
              Icons.edit_outlined,
              color: primary,
            ),
            onPressed: () {
              editBudget(
                title: 'Monthly Budget',
                currentLimit: monthlyBudget,
                onSave: (value) => monthlyBudget = value,
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16.r),
        children: [
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
                Text(
                  '₹${formatAmount(monthlyBudget)}',
                  style: const TextStyle(
                    color: AppColors.budgetCardText,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.h),
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
                    valueColor: const AlwaysStoppedAnimation<Color>(
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
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
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
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Use the edit icon beside a category.',
                      ),
                    ),
                  );
                },
                icon: Icon(
                  Icons.tune,
                  size: 18.r,
                ),
                label: const Text('Edit'),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ...categoryBudgets.map((item) {
            final name = item['name'] as String;
            final limit = item['limit'] as double;
            final spent = item['spent'] as double;
            final icon = item['icon'] as IconData;

            final progress = limit > 0
                ? (spent / limit).clamp(0.0, 1.0)
                : 0.0;

            final percentage =
                limit > 0 ? (spent / limit) * 100 : 0.0;

            final isOverBudget = spent > limit;

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
                      Icon(
                        icon,
                        color: primary,
                      ),
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
                      Text(
                        '₹${formatAmount(spent)} / '
                        '₹${formatAmount(limit)}',
                        style: TextStyle(
                          color: secondary,
                          fontSize: 12,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Edit $name budget',
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                          Icons.edit_outlined,
                          color: primary,
                          size: 19.r,
                        ),
                        onPressed: () {
                          editBudget(
                            title: '$name Budget',
                            currentLimit: limit,
                            onSave: (value) {
                              item['limit'] = value;
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 7.h,
                    borderRadius: BorderRadius.circular(8.r),
                    backgroundColor: secondary.withValues(
                      alpha: 0.15,
                    ),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progressColor,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${percentage.toStringAsFixed(1)}% used',
                        style: TextStyle(
                          color: progressColor,
                          fontSize: 12,
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
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
      bottomNavigationBar: const SpendlyBottomNavigation(
        currentIndex: 2,
      ),
    );
  }
}

class _EditBudgetDialog extends StatefulWidget {
  const _EditBudgetDialog({
    required this.title,
    required this.currentLimit,
  });

  final String title;
  final double currentLimit;

  @override
  State<_EditBudgetDialog> createState() => _EditBudgetDialogState();
}

class _EditBudgetDialogState extends State<_EditBudgetDialog> {
  late final TextEditingController controller;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    controller = TextEditingController(
      text: widget.currentLimit.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit ${widget.title}'),
      content: Form(
        key: formKey,
        child: TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
          ),
          decoration: InputDecoration(
            labelText: 'Budget amount',
            prefixText: '₹ ',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.r),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 12.h,
            ),
          ),
          validator: (value) {
            final amount = double.tryParse(value?.trim() ?? '');

            if (amount == null || amount <= 0) {
              return 'Enter an amount greater than zero';
            }

            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              Navigator.pop(
                context,
                double.parse(controller.text.trim()),
              );
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
