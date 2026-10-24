
import 'package:hive_ce/hive.dart';
import 'package:spendly/features/expenses/data/models/expense_model.dart';
import 'package:spendly/features/expenses/domain/entities/expense.dart';
import 'package:spendly/features/expenses/domain/repositories/expense_repository.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final Box<ExpenseModel> _box;

  ExpenseRepositoryImpl(this._box);

  @override
  List<Expense> getAllExpenses() {
    final expenses = _box.values
        .map((model) => model.toEntity())
        .toList();

    expenses.sort((a, b) => b.date.compareTo(a.date));

    return expenses;
  }

  @override
  Future<void> saveExpense(Expense expense) async {
    final model = ExpenseModel.fromEntity(expense);

    await _box.put(expense.id, model);
  }

  @override
  Future<void> deleteExpense(String id) async {
    await _box.delete(id);
  }

  @override
  Expense? getExpenseById(String id) {
    final model = _box.get(id);
    return model?.toEntity();
  }
}
