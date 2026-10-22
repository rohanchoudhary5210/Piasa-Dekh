class DatabaseFailureException implements Exception {
  final String userMessage;
  final Object? cause;

  const DatabaseFailureException(this.userMessage, [this.cause]);

  @override
  String toString() => userMessage;
}
