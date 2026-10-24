
import 'package:go_router/go_router.dart';
import 'package:spendly/features/expenses/domain/entities/expense.dart';
import 'package:spendly/features/expenses/presentation/screens/add_edit_expense.dart';
import 'package:spendly/features/expenses/presentation/screens/budget_screen.dart';
import 'package:spendly/features/expenses/presentation/screens/dashboard.dart';
import 'package:spendly/features/expenses/presentation/screens/splash_screen.dart';
import 'package:spendly/features/expenses/presentation/screens/transaction_history.dart';

class AppRoutes {
  static const splash = '/';
  static const dashboard = '/dashboard';
   static const addExpense = '/add-expense';
  static const transactions = '/transactions';
  static const budgets = '/budgets';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.dashboard,
      builder: (context, state) => const DashboardScreen(),
    ),
     GoRoute(
      path: AppRoutes.addExpense,
      builder: (context, state) {
        final expense = state.extra as Expense?;

        return AddEditExpenseScreen(
          expense: expense,
        );
      },
    ),
  GoRoute(
      path: AppRoutes.transactions,
      builder: (context, state) => const TransactionHistoryScreen(),
    ),
    GoRoute(
      path: AppRoutes.budgets,
      builder: (context, state) => const BudgetsScreen(),
    ),
  ],
);
