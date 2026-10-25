import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../budgets/presentation/providers/budget_provider.dart';
import '../../../expenses/presentation/providers/expense_providers.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/usecases/get_dashboard_summary.dart';

final getDashboardSummaryProvider =
    Provider<GetDashboardSummary>((ref) {
  return GetDashboardSummary();
});

final dashboardSummaryProvider = Provider<DashboardSummary>((ref) {
  final expenses = ref.watch(expensesProvider);
  final budgets = ref.watch(budgetsProvider);

  return ref.watch(getDashboardSummaryProvider).call(
        expenses: expenses,
        budgets: budgets,
      );
});