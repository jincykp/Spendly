import 'package:spendly/features/expenses/data/data_source/expense_local_data_source.dart';
import 'package:spendly/features/expenses/data/models/expense_model.dart';
import 'package:spendly/features/expenses/domain/entities/expense.dart';
import 'package:spendly/features/expenses/domain/repositories/expense_repository.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseLocalDataSource _dataSource;

  ExpenseRepositoryImpl(this._dataSource);

  @override
  List<Expense> getAllExpenses() {
    return _dataSource
        .getAllExpenses()
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<void> saveExpense(Expense expense) async {
    final model = ExpenseModel.fromEntity(expense);
    await _dataSource.saveExpense(model);
  }

  @override
  Future<void> deleteExpense(String id) async {
    await _dataSource.deleteExpense(id);
  }

  @override
  Expense? getExpenseById(String id) {
    final model = _dataSource.getExpenseById(id);
    return model?.toEntity();
  }
}