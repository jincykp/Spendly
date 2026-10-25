import '../../../expenses/domain/entities/expense.dart';
import '../../../budgets/domain/entities/budget.dart';
import '../entities/dashboard_summary.dart';

class GetDashboardSummary {
  DashboardSummary call({
    required List<Expense> expenses,
    required List<Budget> budgets,
    DateTime? now,
  }) {
    final currentDate = now ?? DateTime.now();

    final monthlyExpenses = expenses.where((expense) {
      return expense.date.year == currentDate.year &&
          expense.date.month == currentDate.month;
    }).toList();

    final monthlyBudgetEntries =
        budgets.where((budget) => budget.isMonthly);

    final monthlyBudget = monthlyBudgetEntries.isEmpty
        ? 0.0
        : monthlyBudgetEntries.first.limit;

    double totalExpenses = 0;
    final categoryTotals = <String, double>{};
    final dailyTotals = <int, double>{};

    for (final expense in monthlyExpenses) {
      totalExpenses += expense.amount;

      categoryTotals.update(
        expense.category,
        (amount) => amount + expense.amount,
        ifAbsent: () => expense.amount,
      );

      dailyTotals.update(
        expense.date.day,
        (amount) => amount + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }

    // Most recent transactions first.
    final sortedExpenses = [...expenses]
      ..sort((a, b) => b.date.compareTo(a.date));

    return DashboardSummary(
      monthlyBudget: monthlyBudget,
      totalExpenses: totalExpenses,
      dailyTotals: dailyTotals,
      categoryTotals: categoryTotals,
      recentTransactions: sortedExpenses.take(5).toList(),
    );
  }
}