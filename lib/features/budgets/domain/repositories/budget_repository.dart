import '../entities/budget.dart';

abstract class BudgetRepository {
  List<Budget> getBudgets();

  Future<void> saveBudget(Budget budget);
}