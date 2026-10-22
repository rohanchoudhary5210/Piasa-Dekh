class DuplicateTransactionException implements Exception {
  final String message;
  const DuplicateTransactionException(this.message);

  @override
  String toString() => message;
}
