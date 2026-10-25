class BudgetAllocation {
  static const Map<String, double> percentages = {
    'Food': 30,
    'Bills': 20,
    'Transport': 15,
    'Shopping': 10,
    'Health': 10,
    'Entertainment': 5,
    'Education': 5,
    'Other': 5,
  };

  static Map<String, double> calculate(double monthlyAmount) {
    final allocations = <String, double>{};

    for (final entry in percentages.entries) {
      allocations[entry.key] = monthlyAmount * entry.value / 100;
    }

    return allocations;
  }
}