import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:spendly/features/expenses/data/data_source/expense_local_data_source.dart';

import 'package:spendly/features/expenses/data/models/expense_model.dart';
import 'package:spendly/features/expenses/data/repositories/expense_repository_impl.dart';
import 'package:spendly/features/expenses/domain/entities/expense.dart';
import 'package:spendly/features/expenses/domain/repositories/expense_repository.dart';
import 'package:spendly/features/expenses/domain/usecases/get_all_expense.dart';
import 'package:spendly/features/expenses/domain/usecases/save_expense.dart';
import 'package:spendly/features/expenses/domain/usecases/delete_expense.dart';
import 'package:spendly/features/expenses/domain/usecases/get_expense_by_id.dart';

// 1. Data source provider
final expenseLocalDataSourceProvider =
    Provider<ExpenseLocalDataSource>((ref) {
  final box = Hive.box<ExpenseModel>('expenses');
  return ExpenseLocalDataSource(box);
});

// 2. Repository provider
final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  final dataSource = ref.read(expenseLocalDataSourceProvider);

  return ExpenseRepositoryImpl(dataSource);
});

// 3. Use case providers
final getAllExpensesUseCaseProvider = Provider<GetAllExpenses>((ref) {
  return GetAllExpenses(ref.read(expenseRepositoryProvider));
});

final saveExpenseUseCaseProvider = Provider<SaveExpense>((ref) {
  return SaveExpense(ref.read(expenseRepositoryProvider));
});

final deleteExpenseUseCaseProvider = Provider<DeleteExpense>((ref) {
  return DeleteExpense(ref.read(expenseRepositoryProvider));
});

final getExpenseByIdUseCaseProvider = Provider<GetExpenseById>((ref) {
  return GetExpenseById(ref.read(expenseRepositoryProvider));
});

// 4. Expenses state provider
final expensesProvider =
    NotifierProvider<ExpensesNotifier, List<Expense>>(
  ExpensesNotifier.new,
);

class ExpensesNotifier extends Notifier<List<Expense>> {
  @override
  List<Expense> build() {
    return ref.read(getAllExpensesUseCaseProvider).call();
  }

  Future<void> saveExpense(Expense expense) async {
    await ref.read(saveExpenseUseCaseProvider).call(expense);

    state = ref.read(getAllExpensesUseCaseProvider).call();
  }

  Future<void> deleteExpense(String id) async {
    await ref.read(deleteExpenseUseCaseProvider).call(id);

    state = ref.read(getAllExpensesUseCaseProvider).call();
  }
}