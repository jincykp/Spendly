
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:spendly/features/budgets/data/data_sources/budget_data_source.dart';
import 'package:spendly/features/budgets/data/models/budget_model.dart';
import 'package:spendly/features/expenses/data/models/expense_model.dart';

import 'package:flutter/foundation.dart';


class HiveInit {
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register Expense adapter
    if (!Hive.isAdapterRegistered(ExpenseModelAdapter().typeId)) {
      Hive.registerAdapter(ExpenseModelAdapter());
    }

    // Register Budget adapter
    if (!Hive.isAdapterRegistered(BudgetModelAdapter().typeId)) {
      Hive.registerAdapter(BudgetModelAdapter());
    }

    // Open Hive boxes
    await Hive.openBox<ExpenseModel>('expenses');
    await Hive.openBox<BudgetModel>(
      BudgetLocalDataSource.boxName,
    );

    // Add default budgets if missing
    await BudgetLocalDataSource().seedDefaultBudgets();

    debugPrint('Hive initialized successfully.');
    debugPrint(
      'Budgets loaded: '
      '${Hive.box<BudgetModel>(BudgetLocalDataSource.boxName).values.toList()}',
    );
  }
}
