import '../../../expenses/domain/entities/expense.dart';

class DashboardSummary {
  final double monthlyBudget;
  final double totalExpenses;
  final Map<int, double> dailyTotals;
  final Map<String, double> categoryTotals;
  final List<Expense> recentTransactions;

  const DashboardSummary({
    required this.monthlyBudget,
    required this.totalExpenses,
    required this.dailyTotals,
    required this.categoryTotals,
    required this.recentTransactions,
  });

  double get remainingBudget => monthlyBudget - totalExpenses;
}