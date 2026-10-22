class BudgetValidationException implements Exception {
  final String message;

  const BudgetValidationException(this.message);

  @override
  String toString() => message;
}
