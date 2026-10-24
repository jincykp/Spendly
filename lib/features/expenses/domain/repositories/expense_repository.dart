
import 'package:spendly/features/expenses/domain/entities/expense.dart';

abstract class ExpenseRepository {
  List<Expense> getAllExpenses();

  Future<void> saveExpense(Expense expense);

  Future<void> deleteExpense(String id);

  Expense? getExpenseById(String id);
}
