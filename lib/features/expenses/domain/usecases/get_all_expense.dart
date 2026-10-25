import 'package:spendly/features/expenses/domain/entities/expense.dart';
import 'package:spendly/features/expenses/domain/repositories/expense_repository.dart';

class GetAllExpenses {
  final ExpenseRepository repository;

  GetAllExpenses(this.repository);

  List<Expense> call() {
    return repository.getAllExpenses();
  }
}