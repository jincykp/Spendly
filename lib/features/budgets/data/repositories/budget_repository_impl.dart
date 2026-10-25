import 'package:spendly/features/budgets/data/data_sources/budget_data_source.dart';

import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';
import '../models/budget_model.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetLocalDataSource localDataSource;

  BudgetRepositoryImpl(this.localDataSource);

  @override
  List<Budget> getBudgets() {
    return localDataSource.getBudgets();
  }

  @override
  Future<void> saveBudget(Budget budget) {
    final model = BudgetModel.fromEntity(budget);
    return localDataSource.saveBudget(model);
  }
}