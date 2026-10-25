import 'package:spendly/features/expenses/domain/entities/expense.dart';
import 'package:spendly/features/expenses/domain/repositories/expense_repository.dart';

class SaveExpense {
  final ExpenseRepository repository;

  SaveExpense(this.repository);

  Future<void> call(Expense expense) {
    return repository.saveExpense(expense);
  }
}