
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:spendly/features/expenses/data/models/expense_model.dart';
import 'package:spendly/features/expenses/data/repositories/expense_repository_impl.dart';
import 'package:spendly/features/expenses/domain/entities/expense.dart';
import 'package:spendly/features/expenses/domain/repositories/expense_repository.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  final box = Hive.box<ExpenseModel>('expenses');
  return ExpenseRepositoryImpl(box);
});

final expensesProvider =
    NotifierProvider<ExpensesNotifier, List<Expense>>(
  ExpensesNotifier.new,
);

class ExpensesNotifier extends Notifier<List<Expense>> {
  @override
  List<Expense> build() {
    return ref.read(expenseRepositoryProvider).getAllExpenses();
  }

  Future<void> saveExpense(Expense expense) async {
    final repository = ref.read(expenseRepositoryProvider);

    await repository.saveExpense(expense);

    state = repository.getAllExpenses();
  }

  Future<void> deleteExpense(String id) async {
    final repository = ref.read(expenseRepositoryProvider);

    await repository.deleteExpense(id);

    state = repository.getAllExpenses();
  }
}
