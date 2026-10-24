
import 'package:hive_ce/hive.dart';
import 'package:spendly/features/expenses/domain/entities/expense.dart';

part 'expense_model.g.dart';

@HiveType(typeId: 0)
class ExpenseModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final String category;

  @HiveField(4)
  final DateTime date;

  @HiveField(5)
  final String description;

  


const ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.description = '',
  });

  factory ExpenseModel.fromEntity(Expense expense) {
    return ExpenseModel(
      id: expense.id,
      title: expense.title,
      amount: expense.amount,
      category: expense.category,
      date: expense.date,
      description: expense.description,
    );
  }

  Expense toEntity() {
    return Expense(
      id: id,
      title: title,
      amount: amount,
      category: category,
      date: date,
      description: description,
    );
  }
}




