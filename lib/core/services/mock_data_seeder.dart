import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:spendly/features/budgets/data/data_sources/budget_data_source.dart';
import 'package:spendly/features/budgets/data/models/budget_model.dart';
import 'package:spendly/features/expenses/data/models/expense_model.dart';

class MockDataSeeder {
  static const settingsBoxName = 'app_settings';
  static const _seededKey = 'mock_data_seeded';
  static const mockPrefix = 'mock_';
  static bool isMockId(String id) => id.startsWith(mockPrefix);

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
}