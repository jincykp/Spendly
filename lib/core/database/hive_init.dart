
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:spendly/features/expenses/data/models/expense_model.dart';

class HiveInit {
  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(ExpenseModelAdapter());

    await Hive.openBox<ExpenseModel>('expenses');
  }
}
