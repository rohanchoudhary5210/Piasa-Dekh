enum NotificationAlertType {
  budget80Used,
  streakAtRisk,
  endOfDayCash,
  goalMilestone,
}

class NotificationAlert {
  final int id;
  final NotificationAlertType type;
  final String title;
  final String bodyWithAmounts;
  final String bodyMasked;
  final DateTime timestamp;

  const NotificationAlert({
    required this.id,
    required this.type,
    required this.title,
    required this.bodyWithAmounts,
    required this.bodyMasked,
    required this.timestamp,
  });

  /// Resolves the actual body text based on user's lockscreen / amount privacy setting
  String getEffectiveBody({required bool showExactAmounts}) {
    return showExactAmounts ? bodyWithAmounts : bodyMasked;
  }
}
