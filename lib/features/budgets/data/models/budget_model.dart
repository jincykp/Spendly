
import 'package:hive_ce/hive.dart';
import '../../domain/entities/budget.dart';

part 'budget_model.g.dart';

@HiveType(typeId: 20)
class BudgetModel extends Budget {
  const BudgetModel({
    required super.category,
    required super.limit,
    super.isMonthly = false,
  });

  factory BudgetModel.fromEntity(Budget budget) {
    return BudgetModel(
      category: budget.category,
      limit: budget.limit,
      isMonthly: budget.isMonthly,
    );
  }

  factory BudgetModel.fromMap(Map<dynamic, dynamic> map) {
    return BudgetModel(
      category: map['category'] as String,
      limit: (map['limit'] as num).toDouble(),
      isMonthly: map['isMonthly'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'limit': limit,
      'isMonthly': isMonthly,
    };
  }
}
