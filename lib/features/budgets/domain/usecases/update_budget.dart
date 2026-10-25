import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';

class UpdateBudget {
  final BudgetRepository repository;

  UpdateBudget(this.repository);

  Future<void> call({
    required List<Budget> currentBudgets,
    required String category,
    required double limit,
    required bool isMonthly,
  }) async {
    if (!limit.isFinite || limit <= 0) {
      throw StateError('Budget must be greater than zero.');
    }

    final monthlyBudgets =
        currentBudgets.where((budget) => budget.isMonthly).toList();

    final categoryBudgets =
        currentBudgets.where((budget) => !budget.isMonthly).toList();

    final allocatedTotal = categoryBudgets.fold<double>(
      0,
      (total, budget) => total + budget.limit,
    );

    if (isMonthly) {
      if (limit < allocatedTotal) {
        throw StateError(
          'Monthly budget cannot be less than the '
          '₹${allocatedTotal.toStringAsFixed(0)} already allocated.',
        );
      }
    } else {
      if (monthlyBudgets.isEmpty) {
        throw StateError('Please set your monthly budget first.');
      }

      final matchingBudgets = categoryBudgets
          .where((budget) => budget.category == category)
          .toList();

      if (matchingBudgets.length != 1) {
        throw StateError('Category budget not found: $category');
      }

      final otherAllocations =
          allocatedTotal - matchingBudgets.first.limit;

      final available =
          monthlyBudgets.first.limit - otherAllocations;

      if (limit > available) {
        throw StateError(
          'Only ₹${available.toStringAsFixed(0)} is available '
          'for $category within the monthly budget.',
        );
      }
    }

    await repository.saveBudget(
      Budget(
        category: category,
        limit: limit,
        isMonthly: isMonthly,
      ),
    );
  }
}