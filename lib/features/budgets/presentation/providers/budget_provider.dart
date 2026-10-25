import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/features/budgets/data/data_sources/budget_data_source.dart';

import '../../data/repositories/budget_repository_impl.dart';
import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';
import '../../domain/usecases/get_budgets.dart';
import '../../domain/usecases/update_budget.dart';



final budgetLocalDataSourceProvider = Provider<BudgetLocalDataSource>((ref) {
  return BudgetLocalDataSource();
});

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepositoryImpl(
    ref.watch(budgetLocalDataSourceProvider),
  );
});

final getBudgetsProvider = Provider<GetBudgets>((ref) {
  return GetBudgets(ref.watch(budgetRepositoryProvider));
});

final updateBudgetProvider = Provider<UpdateBudget>((ref) {
  return UpdateBudget(ref.watch(budgetRepositoryProvider));
});

final budgetsProvider = NotifierProvider<BudgetNotifier, List<Budget>>(
  BudgetNotifier.new,
);

class BudgetNotifier extends Notifier<List<Budget>> {
  @override
  List<Budget> build() {
    return ref.watch(getBudgetsProvider).call();
  }

  double get monthlyLimit {
    final monthlyBudgets = state.where((budget) => budget.isMonthly);
    return monthlyBudgets.isEmpty ? 0 : monthlyBudgets.first.limit;
  }

  double get allocatedTotal {
    return state
        .where((budget) => !budget.isMonthly)
        .fold<double>(0, (total, budget) => total + budget.limit);
  }

  double get unallocatedAmount => monthlyLimit - allocatedTotal;

  Future<void> updateBudget({
    required String category,
    required double limit,
    required bool isMonthly,
  }) async {
    debugPrint('--- BudgetNotifier.updateBudget ---');
    debugPrint('Category: $category');
    debugPrint('Limit: $limit');
    debugPrint('Is monthly: $isMonthly');

    try {
      if (isMonthly) {
        // Use local data source directly to calculate and save dynamic category percentages based on custom amount
        final dataSource = ref.read(budgetLocalDataSourceProvider);
        await dataSource.saveMonthlyBudget(limit);
        // Refresh state from repository
        state = ref.read(getBudgetsProvider).call();
      } else {
        final useCase = ref.read(updateBudgetProvider);
        await useCase(
          currentBudgets: state,
          category: category,
          limit: limit,
          isMonthly: isMonthly,
        );

        final updatedBudget = Budget(
          category: category,
          limit: limit,
          isMonthly: isMonthly,
        );
        
        final index = state.indexWhere(
          (budget) =>
              budget.isMonthly == isMonthly &&
              (isMonthly || budget.category == category),
        );

        if (index == -1) {
          state = [...state, updatedBudget];
        } else {
          state = [
            for (var i = 0; i < state.length; i++)
              if (i == index) updatedBudget else state[i],
          ];
        }
      }
      debugPrint('Budgets after update: $state');
    } catch (error, stackTrace) {
      debugPrint('BudgetNotifier ERROR: $error');
      debugPrint('BudgetNotifier STACK TRACE: $stackTrace');
      rethrow;
    }
  }
}