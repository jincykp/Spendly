import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:spendly/features/budgets/data/data_sources/budget_data_source.dart';
import 'package:spendly/features/budgets/data/models/budget_model.dart';
import 'package:spendly/features/expenses/data/models/expense_model.dart';

class MockDataSeeder {
  static const settingsBoxName = 'app_settings';
  static const _seededKey = 'mock_data_seeded';
  static const _budgetsSeededKey = 'mock_budgets_seeded';
  static const _budgetsActiveKey = 'mock_budgets_active';
  static const mockPrefix = 'mock_';

  static bool isMockId(String id) => id.startsWith(mockPrefix);

  // ---------------------------------------------------------------------------
  // Expenses
  // ---------------------------------------------------------------------------

  static Future<void> seedData() async {
    final settings = Hive.box(settingsBoxName);
    final expenseBox = Hive.box<ExpenseModel>('expenses');

    // Already seeded before (even if cleared since) -> never seed again
    if (settings.get(_seededKey, defaultValue: false) as bool) return;

    // User already has real data -> don't touch it
    if (expenseBox.isNotEmpty) {
      await settings.put(_seededKey, true);
      return;
    }

    final now = DateTime.now();
    DateTime daysAgo(int d) {
      final day = (now.day - d).clamp(1, now.day);
      return DateTime(now.year, now.month, day);
    }

    // (title, category, amount, daysAgo)
    final items = <(String, String, double, int)>[
      ('Swiggy Order', 'Food', 450, 0),
      ('Uber Ride', 'Transport', 220, 1),
      ('Grocery - Reliance Fresh', 'Food', 1850, 2),
      ('Netflix Subscription', 'Entertainment', 649, 3),
      ('Electricity Bill', 'Bills', 2300, 4),
      ('Amazon - Headphones', 'Shopping', 3499, 5),
      ('Pharmacy', 'Health', 780, 6),
      ('Udemy Course', 'Education', 1299, 7),
      ('Metro Card Recharge', 'Transport', 500, 8),
      ('Restaurant Dinner', 'Food', 1650, 9),
      ('Movie Tickets', 'Entertainment', 700, 10),
      ('Internet Bill', 'Bills', 1179, 12),
      ('Zudio - Clothes', 'Shopping', 2100, 14),
      ('Doctor Consultation', 'Health', 600, 16),
      ('Petrol', 'Transport', 1200, 18),
    ];

    for (var i = 0; i < items.length; i++) {
      final (title, category, amount, ago) = items[i];
      final id = '$mockPrefix$i';
      await expenseBox.put(
        id,
        ExpenseModel(
          id: id,
          title: title,
          category: category,
          amount: amount,
          date: daysAgo(ago),
        ),
      );
    }

    await settings.put(_seededKey, true);
  }

  static bool hasMockExpenses() {
    return Hive.box<ExpenseModel>('expenses')
        .values
        .any((e) => isMockId(e.id));
  }

  /// Removes only mock records; real data is untouched.
  static Future<void> clearMockExpenses() async {
    final box = Hive.box<ExpenseModel>('expenses');
    final mockKeys = box
        .toMap()
        .entries
        .where((e) => isMockId(e.value.id))
        .map((e) => e.key)
        .toList();
    await box.deleteAll(mockKeys);
  }

  // ---------------------------------------------------------------------------
  // Budgets
  // ---------------------------------------------------------------------------

  static bool get isMockBudgetsActive => Hive.box(settingsBoxName)
      .get(_budgetsActiveKey, defaultValue: false) as bool;

  /// Seeds mock budgets once, only if the user has no real data.
  static Future<void> seedBudgets() async {
    final settings = Hive.box(settingsBoxName);
    if (settings.get(_budgetsSeededKey, defaultValue: false) as bool) {
      debugPrint('Budget seed skipped: already seeded before');
      return;
    }

    final budgetBox = Hive.box<BudgetModel>(BudgetLocalDataSource.boxName);
    final expenseBox = Hive.box<ExpenseModel>('expenses');

    final hasRealExpenses = expenseBox.values.any((e) => !isMockId(e.id));
    final hasUserBudget =
        budgetBox.values.any((b) => b.isMonthly || b.limit > 0);

    // Never try again, whatever happens next.
    await settings.put(_budgetsSeededKey, true);

    if (hasRealExpenses || hasUserBudget) {
      debugPrint('Budget seed skipped: realExpenses=$hasRealExpenses, '
          'userBudget=$hasUserBudget');
      return;
    }

    await budgetBox.put(
      'monthly', // same key BudgetLocalDataSource uses for the monthly budget
      const BudgetModel(
        category: 'Monthly Budget',
        limit: 25000,
        isMonthly: true,
      ),
    );

    const categoryLimits = <String, double>{
      'Food': 6000,
      'Transport': 2500,
      'Entertainment': 1500,
      'Bills': 4500,
      'Shopping': 5000, // mock spending is 5599, so this shows "over budget"
      'Health': 1500,
      'Education': 2000,
      'Other': 1000,
    }; // total 24000, leaving 1000 unallocated

    for (final entry in categoryLimits.entries) {
      await budgetBox.put(
        entry.key,
        BudgetModel(category: entry.key, limit: entry.value),
      );
    }

    await settings.put(_budgetsActiveKey, true);
    debugPrint('Mock budgets seeded');
  }

  /// Resets budgets to the empty defaults, only if they are still mock.
  static Future<void> clearMockBudgets() async {
    if (!isMockBudgetsActive) return;

    final box = Hive.box<BudgetModel>(BudgetLocalDataSource.boxName);
    await box.delete('monthly');
    for (final budget in BudgetLocalDataSource.defaultBudgets) {
      await box.put(budget.category, budget);
    }
    await Hive.box(settingsBoxName).put(_budgetsActiveKey, false);
  }

  /// The user edited a budget themselves, so it is no longer mock.
  static Future<void> markBudgetsAsReal() =>
      Hive.box(settingsBoxName).put(_budgetsActiveKey, false);
}