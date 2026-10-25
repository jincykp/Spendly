import '../entities/budget.dart';
import '../repositories/budget_repository.dart';

class GetBudgets {
  final BudgetRepository repository;

  GetBudgets(this.repository);

  List<Budget> call() {
    return repository.getBudgets();
  }
}