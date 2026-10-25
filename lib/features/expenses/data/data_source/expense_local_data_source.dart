import 'package:hive_ce/hive.dart';
import 'package:spendly/features/expenses/data/models/expense_model.dart';

class ExpenseLocalDataSource {
  final Box<ExpenseModel> _box;

  ExpenseLocalDataSource(this._box);

  List<ExpenseModel> getAllExpenses() {
    final expenses = _box.values.toList();

    expenses.sort((a, b) => b.date.compareTo(a.date));

    return expenses;
  }

  Future<void> saveExpense(ExpenseModel expense) async {
    await _box.put(expense.id, expense);
  }

  Future<void> deleteExpense(String id) async {
    await _box.delete(id);
  }

  ExpenseModel? getExpenseById(String id) {
    return _box.get(id);
  }
}