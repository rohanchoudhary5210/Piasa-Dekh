class InsufficientCoinsException implements Exception {
  final String message;
  const InsufficientCoinsException([this.message = 'Not enough coins to perform this action!']);

  @override
  String toString() => message;
}

class StreakAlreadyRepairedException implements Exception {
  final String message;
  const StreakAlreadyRepairedException([this.message = 'Streak shield has already been used this cycle!']);

  @override
  String toString() => message;
}

class NoBrokenStreakException implements Exception {
  final String message;
  const NoBrokenStreakException([this.message = 'There is no broken streak to repair!']);

  @override
  String toString() => message;
}
