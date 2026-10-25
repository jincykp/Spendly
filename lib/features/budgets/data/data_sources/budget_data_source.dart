import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:spendly/core/services/mock_data_seeder.dart';
import 'package:spendly/core/utils/budget_allocation.dart';
import '../models/budget_model.dart';

class BudgetLocalDataSource {
  static const String boxName = 'budgets';

  Box<BudgetModel> get _box => Hive.box<BudgetModel>(boxName);

  static const List<BudgetModel> defaultBudgets = [
    BudgetModel(category: 'Food', limit: 0),
    BudgetModel(category: 'Transport', limit: 0),
    BudgetModel(category: 'Entertainment', limit: 0),
    BudgetModel(category: 'Bills', limit: 0),
    BudgetModel(category: 'Shopping', limit: 0),
    BudgetModel(category: 'Health', limit: 0),
    BudgetModel(category: 'Education', limit: 0),
    BudgetModel(category: 'Other', limit: 0),
  ];

  Future<void> seedDefaultBudgets() async {
    for (final budget in defaultBudgets) {
      if (!_box.containsKey(budget.category)) {
        await _box.put(budget.category, budget);
      }
    }
  }

  String _keyFor(BudgetModel budget) {
    return budget.isMonthly ? 'monthly' : budget.category;
  }

  List<BudgetModel> getBudgets() {
    return _box.values.toList();
  }

  Future<void> saveBudget(BudgetModel budget) async {
  await MockDataSeeder.markBudgetsAsReal(); 
    await _box.put(_keyFor(budget), budget);
  }

  Future<void> saveMonthlyBudget(double amount) async {
    if (!amount.isFinite || amount <= 0) {
      throw ArgumentError('Monthly budget must be greater than zero.');
    }

    // Calculate allocations based on the custom user amount
    final allocations = BudgetAllocation.calculate(amount);

    // Save the monthly budget
    await saveBudget(
      BudgetModel(
        category: 'Monthly Budget',
        limit: amount,
        isMonthly: true,
      ),
    );

    // Save each automatically calculated category limit based on the custom amount
    for (final entry in allocations.entries) {
      await saveBudget(
        BudgetModel(
          category: entry.key,
          limit: entry.value,
        ),
      );
    }

    debugPrint('Custom monthly budget saved: $amount');
    debugPrint('Calculated category allocations: $allocations');
  }
}