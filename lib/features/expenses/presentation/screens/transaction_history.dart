
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:spendly/core/theme/app_colors.dart';
import 'package:spendly/features/expenses/domain/entities/expense.dart';
import 'package:spendly/features/expenses/presentation/providers/expense_providers.dart';
import 'package:spendly/features/expenses/presentation/widgets/bottom_nav.dart';

class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState
    extends ConsumerState<TransactionHistoryScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  String _selectedCategory = 'All';
  bool _newestFirst = true;
  DateTimeRange? _dateRange;

  final List<String> _categories = [
    'All',
    'Food',
    'Transport',
    'Entertainment',
    'Bills',
    'Shopping',
    'Health',
    'Education',
    'Other',
  ];

  List<Expense> _filterTransactions(List<Expense> expenses) {
    final query = _searchController.text.trim().toLowerCase();

    final results = expenses.where((expense) {
      final matchesSearch =
          expense.title.toLowerCase().contains(query) ||
          expense.category.toLowerCase().contains(query) ||
          expense.description.toLowerCase().contains(query);

      final matchesCategory = _selectedCategory == 'All' ||
          expense.category == _selectedCategory;

      final date = expense.date;

      final matchesDate = _dateRange == null ||
          (!date.isBefore(_dateRange!.start) &&
              !date.isAfter(
                DateTime(
                  _dateRange!.end.year,
                  _dateRange!.end.month,
                  _dateRange!.end.day,
                  23,
                  59,
                  59,
                  999,
                ),
              ));

      return matchesSearch && matchesCategory && matchesDate;
    }).toList();

    results.sort((a, b) {
      return _newestFirst
          ? b.date.compareTo(a.date)
          : a.date.compareTo(b.date);
    });

    return results;
  }

  double _calculateTotal(List<Expense> expenses) {
    return expenses.fold(
      0.0,
      (total, expense) => total + expense.amount,
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.shopping_basket_rounded;
      case 'transport':
        return Icons.directions_car_rounded;
      case 'entertainment':
        return Icons.movie_rounded;
      case 'bills':
        return Icons.bolt_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'health':
        return Icons.medical_services_rounded;
      case 'education':
        return Icons.school_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  Color _getCategoryColor(String category, Color primary) {
    switch (category.toLowerCase()) {
      case 'food':
        return AppColors.budgetWarning;
      case 'transport':
        return AppColors.darkPrimary;
      case 'entertainment':
        return AppColors.budgetOverBudget;
      case 'bills':
        return AppColors.lightPrimary;
      default:
        return primary;
    }
  }

  Future<void> _editTransaction(Expense expense) async {
    await context.push<void>(
      '/add-expense',
      extra: expense,
    );

    // The screen refreshes automatically when the provider changes.
  }
void _showSnack(String message, {bool isError = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        backgroundColor: isError ? AppColors.budgetOverBudget : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
}
  Future<void> _deleteTransaction(Expense expense) async {
    await ref
        .read(expensesProvider.notifier)
        .deleteExpense(expense.id);

    if (!mounted) return;

   _showSnack('Transaction deleted');
  }

  Future<void> _selectDateRange() async {
    final now = DateTime.now();

    final selected = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 1, 12, 31),
      initialDateRange: _dateRange,
    );

    if (selected != null && mounted) {
      setState(() => _dateRange = selected);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Read the shared expense state from Riverpod.
    final allExpenses = ref.watch(expensesProvider);

    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final textColor = isDark
        ? AppColors.darkText
        : AppColors.lightText;

    final secondary = isDark
        ? AppColors.darkSecondaryText
        : AppColors.lightSecondaryText;

    final surface = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;

    final background = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;

    final primary = isDark
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;

    final transactions = _filterTransactions(allExpenses);
    final filteredTotal = _calculateTotal(transactions);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        title: Text(
          'Transaction History',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                16.w,
                8.h,
                16.w,
                12.h,
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      hintText: 'Search transactions...',
                      hintStyle: TextStyle(color: secondary),
                      prefixIcon: Icon(
                        Icons.search,
                        color: secondary,
                      ),
                      filled: true,
                      fillColor: surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    height: 40.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (_, __) =>
                          SizedBox(width: 8.w),
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final selected =
                            category == _selectedCategory;

                        return ChoiceChip(
                          label: Text(category),
                          selected: selected,
                          onSelected: (_) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                          selectedColor: primary,
                          labelStyle: TextStyle(
                            color: selected
                                ? (isDark
                                    ? AppColors.lightText
                                    : AppColors.budgetCardText)
                                : textColor,
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _selectDateRange,
                          icon: const Icon(
                            Icons.calendar_month_outlined,
                          ),
                          label: Text(
                            _dateRange == null
                                ? 'Date range'
                                : '${DateFormat('dd MMM').format(_dateRange!.start)}'
                                    ' - ${DateFormat('dd MMM').format(_dateRange!.end)}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      IconButton(
                        tooltip: _newestFirst
                            ? 'Newest first'
                            : 'Oldest first',
                        onPressed: () {
                          setState(() {
                            _newestFirst = !_newestFirst;
                          });
                        },
                        icon: Icon(
                          _newestFirst
                              ? Icons.arrow_downward_rounded
                              : Icons.arrow_upward_rounded,
                          color: primary,
                        ),
                      ),
                      if (_dateRange != null)
                        IconButton(
                          tooltip: 'Clear date filter',
                          onPressed: () {
                            setState(() => _dateRange = null);
                          },
                          icon: Icon(
                            Icons.close,
                            color: secondary,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${transactions.length} transactions',
                      style: TextStyle(color: secondary),
                    ),
                    Text(
                      NumberFormat.currency(
                        locale: 'en_IN',
                        symbol: '₹',
                        decimalDigits: 0,
                      ).format(filteredTotal),
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Expanded(
              child: transactions.isEmpty
                  ? Center(
                      child: Text(
                        allExpenses.isEmpty
                            ? 'No expenses added yet'
                            : 'No transactions found',
                        style: TextStyle(color: secondary),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.fromLTRB(
                        16.w,
                        8.h,
                        16.w,
                        16.h,
                      ),
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final expense = transactions[index];

                        final color = _getCategoryColor(
                          expense.category,
                          primary,
                        );

                        return Container(
                          margin: EdgeInsets.only(bottom: 10.h),
                          decoration: BoxDecoration(
                            color: surface,
                            borderRadius:
                                BorderRadius.circular(16.r),
                          ),
                          child: ListTile(
                            contentPadding:
                                EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 4.h,
                            ),
                            onTap: () =>
                                _editTransaction(expense),
                            leading: CircleAvatar(
                              backgroundColor:
                                  color.withValues(alpha: 0.13),
                              child: Icon(
                                _getCategoryIcon(
                                  expense.category,
                                ),
                                color: color,
                              ),
                            ),
                            title: Text(
                              expense.title,
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              '${expense.category} • '
                              '${DateFormat('dd MMM yyyy').format(expense.date)}',
                              style: TextStyle(color: secondary),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '-${NumberFormat.currency(
                                    locale: 'en_IN',
                                    symbol: '₹',
                                    decimalDigits: 0,
                                  ).format(expense.amount)}',
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _editTransaction(expense);
                                    } else if (value == 'delete') {
                                      _deleteTransaction(expense);
                                    }
                                  },
                                  itemBuilder: (_) => const [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Text('Edit'),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Delete'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push<void>('/add-expense');
        },
        backgroundColor: primary,
        child: const Icon(Icons.add_rounded),
      ),
      bottomNavigationBar: const SpendlyBottomNavigation(
        currentIndex: 1,
      ),
    );
  }
}
