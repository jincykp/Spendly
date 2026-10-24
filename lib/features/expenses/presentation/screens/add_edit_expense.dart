
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:spendly/core/theme/app_colors.dart';
import 'package:spendly/features/expenses/domain/entities/expense.dart';
import 'package:spendly/features/expenses/presentation/providers/expense_providers.dart';

class AddEditExpenseScreen extends ConsumerStatefulWidget {
  final Expense? expense;

  const AddEditExpenseScreen({
    super.key,
    this.expense,
  });

  @override
  ConsumerState<AddEditExpenseScreen> createState() =>
      _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState
    extends ConsumerState<AddEditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;

  final List<String> _categories = [
    'Food',
    'Transport',
    'Entertainment',
    'Bills',
    'Shopping',
    'Health',
    'Education',
    'Other',
  ];

  String _selectedCategory = 'Food';
  DateTime _selectedDate = DateTime.now();

  bool get _isEditing => widget.expense != null;

  @override
  void initState() {
    super.initState();

    final expense = widget.expense;

    _titleController = TextEditingController(
      text: expense?.title ?? '',
    );

    _amountController = TextEditingController(
      text: expense?.amount.toString() ?? '',
    );

    _descriptionController = TextEditingController(
      text: expense?.description ?? '',
    );

    if (expense != null) {
      _selectedCategory = _categories.contains(expense.category)
          ? expense.category
          : 'Other';

      _selectedDate = expense.date;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && mounted) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    final expense = Expense(
      id: widget.expense?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      amount: double.parse(_amountController.text.trim()),
      category: _selectedCategory,
      date: _selectedDate,
      description: _descriptionController.text.trim(),
    );

    try {
      await ref.read(expensesProvider.notifier).saveExpense(expense);

      debugPrint('Expense saved successfully!');
      debugPrint('ID: ${expense.id}');
      debugPrint('Title: ${expense.title}');
      debugPrint('Amount: ₹${expense.amount}');
      debugPrint('Category: ${expense.category}');
      debugPrint('Date: ${expense.date}');
      debugPrint('Description: ${expense.description}');

      final allExpenses = ref.read(expensesProvider);

      debugPrint('---------- ALL SAVED EXPENSES ----------');
      for (final item in allExpenses) {
        debugPrint(
          'ID: ${item.id}, '
          'Title: ${item.title}, '
          'Amount: ₹${item.amount}, '
          'Category: ${item.category}, '
          'Date: ${item.date}, '
          'Description: ${item.description}',
        );
      }
      debugPrint('----------------------------------------');

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (error, stackTrace) {
      debugPrint('Error saving expense: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to save expense. Please try again.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final secondaryText =
        isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    final primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back_rounded,
            color: textColor,
          ),
        ),
        title: Text(
          _isEditing ? 'Edit Expense' : 'Add Expense',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.r),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditing
                      ? 'Update your expense details'
                      : 'Record your daily spending',
                  style: TextStyle(
                    color: secondaryText,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 24.h),

                // Expense title
                _buildLabel('Expense title', textColor),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(color: textColor),
                  decoration: _inputDecoration(
                    hint: 'e.g. Grocery Shopping',
                    icon: Icons.receipt_long_rounded,
                    surfaceColor: surfaceColor,
                    secondaryText: secondaryText,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an expense title';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.h),

                // Amount
                _buildLabel('Amount (₹)', textColor),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(color: textColor),
                  decoration: _inputDecoration(
                    hint: '0.00',
                    icon: Icons.currency_rupee_rounded,
                    surfaceColor: surfaceColor,
                    secondaryText: secondaryText,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an amount';
                    }

                    final amount = double.tryParse(value.trim());

                    if (amount == null ||
                        !amount.isFinite ||
                        amount <= 0) {
                      return 'Enter a valid amount greater than zero';
                    }

                    return null;
                  },
                ),
                SizedBox(height: 20.h),

                // Category
                _buildLabel('Category', textColor),
                SizedBox(height: 8.h),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  isExpanded: true,
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  dropdownColor: surfaceColor,
                  style: TextStyle(color: textColor),
                  decoration: _inputDecoration(
                    hint: 'Select category',
                    icon: Icons.category_rounded,
                    surfaceColor: surfaceColor,
                    secondaryText: secondaryText,
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Text(category),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    }
                  },
                ),
                SizedBox(height: 20.h),

                // Date
                _buildLabel('Date', textColor),
                SizedBox(height: 8.h),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(14.r),
                  child: InputDecorator(
                    decoration: _inputDecoration(
                      hint: 'Select date',
                      icon: Icons.calendar_month_rounded,
                      surfaceColor: surfaceColor,
                      secondaryText: secondaryText,
                    ),
                    child: Text(
                      DateFormat('dd MMM yyyy').format(_selectedDate),
                      style: TextStyle(color: textColor),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),

                // Description
                _buildLabel('Description (optional)', textColor),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(color: textColor),
                  decoration: _inputDecoration(
                    hint: 'Add notes about this expense',
                    icon: Icons.notes_rounded,
                    surfaceColor: surfaceColor,
                    secondaryText: secondaryText,
                  ),
                ),
                SizedBox(height: 32.h),

                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 54.h,
                  child: ElevatedButton.icon(
                    onPressed: _saveExpense,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor:
                          isDark ? Colors.black : Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    icon: Icon(
                      _isEditing
                          ? Icons.check_rounded
                          : Icons.add_rounded,
                    ),
                    label: Text(
                      _isEditing ? 'Update Expense' : 'Save Expense',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String title, Color textColor) {
    return Text(
      title,
      style: TextStyle(
        color: textColor,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    required Color surfaceColor,
    required Color secondaryText,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: secondaryText),
      prefixIcon: Icon(
        icon,
        color: secondaryText,
      ),
      filled: true,
      fillColor: surfaceColor,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 16.h,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkPrimary
              : AppColors.lightPrimary,
          width: 1.5.w,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.5,
        ),
      ),
    );
  }
}
