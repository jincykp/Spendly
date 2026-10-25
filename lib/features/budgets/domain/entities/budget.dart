class Budget {
  final String category;
  final double limit;
  final bool isMonthly;

  const Budget({
    required this.category,
    required this.limit,
    this.isMonthly = false,
  });

  Budget copyWith({
    String? category,
    double? limit,
    bool? isMonthly,
  }) {
    return Budget(
      category: category ?? this.category,
      limit: limit ?? this.limit,
      isMonthly: isMonthly ?? this.isMonthly,
    );
  }
}