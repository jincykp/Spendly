import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditBudgetDialog extends StatefulWidget {
  const EditBudgetDialog({
    required this.title,
    required this.currentLimit,
    required this.unallocatedAmount,
    required this.isMonthly,
  });

  final String title;
  final double currentLimit;
  final double unallocatedAmount;
  final bool isMonthly;

  @override
  State<EditBudgetDialog> createState() => EditBudgetDialogState();
}

class EditBudgetDialogState extends State<EditBudgetDialog> {
  late final TextEditingController controller;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(
      text: widget.currentLimit > 0
          ? widget.currentLimit.toStringAsFixed(0)
          : '',
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isNewBudget = widget.currentLimit <= 0;
    
    // Calculate max possible limit user can set for this category
    // (Current limit + remaining unallocated amount)
    final maxAvailableForCategory = widget.currentLimit + widget.unallocatedAmount;

    return AlertDialog(
      title: Text(
        '${isNewBudget ? 'Set' : 'Edit'} ${widget.title}',
      ),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Budget amount',
                prefixText: '₹ ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.r),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 12.h,
                ),
              ),
              validator: (value) {
                final amount = double.tryParse(value?.trim() ?? '');

                if (amount == null || !amount.isFinite || amount <= 0) {
                  return 'Enter an amount greater than zero';
                }

                if (!widget.isMonthly && amount > maxAvailableForCategory) {
                  return 'Exceeds available unallocated balance';
                }

                return null;
              },
            ),
            
            // Show available balance helper text conditionally
            if (!widget.isMonthly && widget.unallocatedAmount > 0) ...[
              SizedBox(height: 8.h),
              Text(
                'You can spend up to ₹${widget.unallocatedAmount.toStringAsFixed(0)} more from unallocated funds.',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 12.sp,
                ),
              ),
            ] else if (!widget.isMonthly && widget.unallocatedAmount < 0) ...[
              SizedBox(height: 8.h),
              Text(
                'Over-allocated by ₹${widget.unallocatedAmount.abs().toStringAsFixed(0)}. Reduce other categories first.',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              Navigator.pop(
                context,
                double.parse(controller.text.trim()),
              );
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}