class BudgetGoal {
  final String categoryId;
  final double monthlyLimit;

  BudgetGoal({
    required this.categoryId,
    required this.monthlyLimit,
  });

  Map<String, dynamic> toJson() => {
        'categoryId': categoryId,
        'monthlyLimit': monthlyLimit,
      };

  factory BudgetGoal.fromJson(Map<String, dynamic> json) {
    return BudgetGoal(
      categoryId: json['categoryId'] as String,
      monthlyLimit: (json['monthlyLimit'] as num).toDouble(),
    );
  }
}
