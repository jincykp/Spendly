import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:spendly/core/theme/app_colors.dart';
import 'package:spendly/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:spendly/features/expenses/domain/entities/expense.dart';
import 'package:spendly/features/expenses/presentation/widgets/bottom_nav.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(dashboardSummaryProvider);

    final latestTransactions = summary.recentTransactions;
    final monthlyBudget = summary.monthlyBudget;
    final monthlyExpenses = summary.totalExpenses;
    final remainingBudget = summary.remainingBudget;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textColor =
        isDark ? AppColors.darkText : AppColors.lightText;

    final secondaryText = isDark
        ? AppColors.darkSecondaryText
        : AppColors.lightSecondaryText;

    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;

    final backgroundColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;

    final primary =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _greeting(),
              style: TextStyle(
                fontSize: 13,
                color: secondaryText,
              ),
            ),
            Text(
              'Your Dashboard',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notifications coming soon'),
                ),
              );
            },
            icon: Icon(
              Icons.notifications_none_rounded,
              color: textColor,
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBudgetCard(
                monthlyBudget: monthlyBudget,
                monthlyExpenses: monthlyExpenses,
                remainingBudget: remainingBudget,
                isDark: isDark,
              ),
              SizedBox(height: 20.h),

              _sectionTitle('Spending Overview', secondaryText),
              SizedBox(height: 12.h),

              Row(
                children: [
                  Expanded(
                    child: _summaryCard(
                      title: 'Total Spent',
                      amount: monthlyExpenses,
                      icon: Icons.trending_up_rounded,
                      iconColor: AppColors.expenseSpentIcon,
                      surfaceColor: surfaceColor,
                      textColor: textColor,
                      secondaryText: secondaryText,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _summaryCard(
                      title: 'Remaining',
                      amount: remainingBudget,
                      icon: Icons.account_balance_wallet_rounded,
                      iconColor: remainingBudget < 0
                          ? AppColors.budgetOverBudget
                          : AppColors.budgetRemainingPositive,
                      surfaceColor: surfaceColor,
                      textColor: textColor,
                      secondaryText: secondaryText,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              _sectionTitle('Spending Trends', secondaryText),
              SizedBox(height: 12.h),

              _buildTrendChart(
                surfaceColor: surfaceColor,
                secondaryText: secondaryText,
                primary: primary,
                dailyTotals: summary.dailyTotals,
              ),
              SizedBox(height: 24.h),

              _sectionTitle('Category Breakdown', secondaryText),
              SizedBox(height: 12.h),

              _buildCategoryBreakdown(
                surfaceColor: surfaceColor,
                textColor: textColor,
                categoryTotals: summary.categoryTotals,
                monthlyExpenses: monthlyExpenses,
              ),
              SizedBox(height: 24.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _sectionTitle(
                    'Recent Transactions',
                    secondaryText,
                  ),
                  TextButton(
                    onPressed: () => context.go('/transactions'),
                    child: const Text('See all'),
                  ),
                ],
              ),
              SizedBox(height: 8.h),

              if (latestTransactions.isEmpty)
                Padding(
                  padding: EdgeInsets.all(24.r),
                  child: Center(
                    child: Text(
                      'No transactions yet. Add your first expense!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: secondaryText),
                    ),
                  ),
                )
              else
                ...latestTransactions.map(
                  (expense) => _transactionTile(
                    expense: expense,
                    surfaceColor: surfaceColor,
                    textColor: textColor,
                    secondaryText: secondaryText,
                    primary: primary,
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push<void>('/add-expense');
        },
        backgroundColor: primary,
        foregroundColor: isDark
            ? AppColors.lightText
            : AppColors.budgetCardText,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Expense'),
      ),
      bottomNavigationBar:
          const SpendlyBottomNavigation(currentIndex: 0),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) return 'Good morning!';
    if (hour < 17) return 'Good afternoon!';
    return 'Good evening!';
  }

  Widget _buildBudgetCard({
    required double monthlyBudget,
    required double monthlyExpenses,
    required double remainingBudget,
    required bool isDark,
  }) {
    final primary =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    final spentPercentage = monthlyBudget > 0
        ? (monthlyExpenses / monthlyBudget).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(22.r),
      decoration: BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Monthly Budget',
                style: TextStyle(
                  color: AppColors.budgetCardSecondaryText,
                  fontSize: 14,
                ),
              ),
              const Icon(
                Icons.calendar_month_rounded,
                color: AppColors.budgetCardText,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            _formatCurrency(monthlyBudget),
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: AppColors.budgetCardText,
            ),
          ),
          SizedBox(height: 20.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: LinearProgressIndicator(
              value: spentPercentage,
              minHeight: 9.h,
              backgroundColor:
                  AppColors.budgetCardProgressBackground,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.budgetCardText,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                monthlyBudget > 0
                    ? '${(monthlyExpenses / monthlyBudget * 100).round()}% used'
                    : 'No budget set',
                style: const TextStyle(
                  color: AppColors.budgetCardText,
                  fontSize: 13,
                ),
              ),
              Flexible(
                child: Text(
                  '${_formatCurrency(remainingBudget)} left',
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    color: AppColors.budgetCardText,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (remainingBudget < 0) ...[
            SizedBox(height: 8.h),
            const Text(
              'You have exceeded your monthly budget.',
              style: TextStyle(
                color: AppColors.budgetCardText,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _summaryCard({
    required String title,
    required double amount,
    required IconData icon,
    required Color iconColor,
    required Color surfaceColor,
    required Color textColor,
    required Color secondaryText,
  }) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24.r),
          SizedBox(height: 14.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: secondaryText,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            _formatCurrency(amount),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

 Widget _buildTrendChart({
  required Color surfaceColor,
  required Color secondaryText,
  required Color primary,
  required Map<int, double> dailyTotals,
}) {
  final now = DateTime.now();
  final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
  final today = now.day;

  // One point per day so the line always draws
  final spots = <FlSpot>[
    for (var day = 1; day <= today; day++)
      FlSpot(day.toDouble(), dailyTotals[day] ?? 0),
  ];

  final hasData = dailyTotals.values.any((amount) => amount > 0);

  final maxSpending = dailyTotals.values.fold<double>(
    0,
    (maximum, amount) => amount > maximum ? amount : maximum,
  );

  final maxY = maxSpending == 0
      ? 1000.0
      : (maxSpending * 1.2 / 1000).ceil() * 1000.0;

  return Container(
    height: 240.h,
    padding: EdgeInsets.fromLTRB(12.w, 20.h, 20.w, 12.h),
    decoration: BoxDecoration(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(18.r),
    ),
    child: !hasData
        ? Center(
            child: Text(
              'No spending data for this month yet.',
              style: TextStyle(color: secondaryText),
              textAlign: TextAlign.center,
            ),
          )
        : LineChart(
            LineChartData(
              minX: 1,
              maxX: daysInMonth.toDouble(),
              minY: 0,
              maxY: maxY,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: secondaryText.withValues(alpha: 0.15),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 42.w,
                    interval: maxY / 4,
                    getTitlesWidget: (value, meta) => Text(
                      value == 0
                          ? '₹0'
                          : value >= 1000
                              ? '₹${(value / 1000).toStringAsFixed(value % 1000 == 0 ? 0 : 1)}k'
                              : '₹${value.round()}',
                      style: TextStyle(fontSize: 10, color: secondaryText),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final day = value.toInt();

                      if (day < 1 ||
                          day > daysInMonth ||
                          (day != 1 && day % 5 != 0)) {
                        return const SizedBox.shrink();
                      }

                      return Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: Text(
                          '$day',
                          style: TextStyle(fontSize: 10, color: secondaryText),
                        ),
                      );
                    },
                  ),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  preventCurveOverShooting: true,
                  barWidth: 3,
                  color: primary,
                  dotData: FlDotData(
                    show: true,
                    checkToShowDot: (spot, barData) => spot.y > 0,
                    getDotPainter: (spot, percent, bar, index) =>
                        FlDotCirclePainter(
                      radius: 3.5,
                      color: primary,
                      strokeWidth: 0,
                    ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: primary.withValues(alpha: 0.12),
                  ),
                ),
              ],
            ),
          ),
  );
}Color _labelColorFor(Color background) {
  return ThemeData.estimateBrightnessForColor(background) == Brightness.dark
      ? Colors.white
      : Colors.black87;
}
  Widget _buildCategoryBreakdown({
    required Color surfaceColor,
    required Color textColor,
    required Map<String, double> categoryTotals,
    required double monthlyExpenses,
  }) {
    final categories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    const categoryColors = <String, Color>{
      'Food': AppColors.categoryFood,
      'Transport': AppColors.categoryTransport,
      'Entertainment': AppColors.categoryEntertainment,
      'Bills': AppColors.categoryBills,
      'Shopping': AppColors.categoryShopping,
      'Health': AppColors.categoryHealth,
      'Education': AppColors.categoryEducation,
      'Other': AppColors.categoryOther,
    };

    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: categories.isEmpty || monthlyExpenses <= 0
          ? Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: const Center(
                child: Text(
                  'No spending data for this month yet.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : Column(
              children: [
                SizedBox(
                  height: 190.h,
                 child: PieChart(
  PieChartData(
    sectionsSpace: 3,
    centerSpaceRadius: 36.r, // was 42.r
    sections: categories.map((entry) {
  final color = categoryColors[entry.key] ?? AppColors.lightPrimary;
  final percentage = entry.value / monthlyExpenses * 100;

  // Slices below 8% are too narrow for text inside
  final isSmall = percentage < 8;
  final label = percentage < 1 ? '<1%' : '${percentage.round()}%';

  return PieChartSectionData(
    value: entry.value,
    color: color,
    radius: 40.r,
    // Big slice: label inside. Small slice: no inside label.
    title: isSmall ? '' : label,
    titleStyle: TextStyle(
      color: _labelColorFor(color),
      fontSize: 12.sp,
      fontWeight: FontWeight.bold,
    ),
    titlePositionPercentageOffset: 0.55,
    // Small slice: label sits outside the ring
    badgeWidget: isSmall
        ? Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
            ),
          )
        : null,
    badgePositionPercentageOffset: 1.4, // above 1 = outside the slice
  );
}).toList(),
  ),
),
                ),
                SizedBox(height: 12.h),
                ...categories.map((entry) {
                  final color = categoryColors[entry.key] ??
                      AppColors.lightPrimary;

                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 7.h),
                    child: Row(
                      children: [
                        Container(
                          width: 10.w,
                          height: 10.h,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            entry.key,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Text(
                          _formatCurrency(entry.value),
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
    );
  }

  Widget _transactionTile({
    required Expense expense,
    required Color surfaceColor,
    required Color textColor,
    required Color secondaryText,
    required Color primary,
  }) {
    final categoryColor = _getCategoryColor(
      expense.category,
      primary,
    );
    final categoryIcon = _getCategoryIcon(expense.category);

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Container(
            width: 46.w,
            height: 46.h,
            decoration: BoxDecoration(
              color: categoryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              categoryIcon,
              color: categoryColor,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.title,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  '${expense.category} • ${DateFormat('dd MMM').format(expense.date)}',
                  style: TextStyle(
                    color: secondaryText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '-${_formatCurrency(expense.amount)}',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, Color color) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    ).format(amount);
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.shopping_basket_rounded;
      case 'transport':
        return Icons.directions_car_rounded;
      case 'entertainment':
        return Icons.movie_rounded;
      case 'bills':
        return Icons.bolt_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'health':
        return Icons.medical_services_rounded;
      case 'education':
        return Icons.school_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  Color _getCategoryColor(String category, Color primary) {
    switch (category.toLowerCase()) {
      case 'food':
        return AppColors.budgetWarning;
      case 'transport':
        return AppColors.darkPrimary;
      case 'entertainment':
        return AppColors.budgetOverBudget;
      case 'bills':
        return AppColors.lightPrimary;
      default:
        return primary;
    }
  }
}