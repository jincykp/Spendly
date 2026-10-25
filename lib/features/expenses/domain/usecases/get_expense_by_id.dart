import 'package:spendly/features/expenses/domain/entities/expense.dart';
import 'package:spendly/features/expenses/domain/repositories/expense_repository.dart';

class GetExpenseById {
  final ExpenseRepository repository;

  GetExpenseById(this.repository);

  Expense? call(String id) {
    return repository.getExpenseById(id);
  }
}