class NotificationPreferences {
  final bool enabled;
  final int maxPerDay;
  final int quietHoursStartHour;
  final int quietHoursEndHour;
  final bool showAmountsOnLockScreen;
  final bool budget80AlertEnabled;
  final bool streakAtRiskAlertEnabled;
  final bool cashReminderEnabled;
  final bool goalMilestonesEnabled;

  const NotificationPreferences({
    this.enabled = true,
    this.maxPerDay = 2,
    this.quietHoursStartHour = 22, // 10 PM
    this.quietHoursEndHour = 7,    // 7 AM
    this.showAmountsOnLockScreen = false,
    this.budget80AlertEnabled = true,
    this.streakAtRiskAlertEnabled = true,
    this.cashReminderEnabled = true,
    this.goalMilestonesEnabled = true,
  });

  /// Returns true if the given hour falls inside the defined Quiet Hours window.
  /// Handles windows that span midnight (e.g. 22:00 to 07:00).
  bool isQuietHour(int hour) {
    if (quietHoursStartHour == quietHoursEndHour) return false;
    if (quietHoursStartHour < quietHoursEndHour) {
      return hour >= quietHoursStartHour && hour < quietHoursEndHour;
    } else {
      // Spans midnight (e.g. 22 to 7)
      return hour >= quietHoursStartHour || hour < quietHoursEndHour;
    }
  }

  NotificationPreferences copyWith({
    bool? enabled,
    int? maxPerDay,
    int? quietHoursStartHour,
    int? quietHoursEndHour,
    bool? showAmountsOnLockScreen,
    bool? budget80AlertEnabled,
    bool? streakAtRiskAlertEnabled,
    bool? cashReminderEnabled,
    bool? goalMilestonesEnabled,
  }) {
    return NotificationPreferences(
      enabled: enabled ?? this.enabled,
      maxPerDay: maxPerDay ?? this.maxPerDay,
      quietHoursStartHour: quietHoursStartHour ?? this.quietHoursStartHour,
      quietHoursEndHour: quietHoursEndHour ?? this.quietHoursEndHour,
      showAmountsOnLockScreen:
          showAmountsOnLockScreen ?? this.showAmountsOnLockScreen,
      budget80AlertEnabled: budget80AlertEnabled ?? this.budget80AlertEnabled,
      streakAtRiskAlertEnabled:
          streakAtRiskAlertEnabled ?? this.streakAtRiskAlertEnabled,
      cashReminderEnabled: cashReminderEnabled ?? this.cashReminderEnabled,
      goalMilestonesEnabled:
          goalMilestonesEnabled ?? this.goalMilestonesEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'maxPerDay': maxPerDay,
        'quietHoursStartHour': quietHoursStartHour,
        'quietHoursEndHour': quietHoursEndHour,
        'showAmountsOnLockScreen': showAmountsOnLockScreen,
        'budget80AlertEnabled': budget80AlertEnabled,
        'streakAtRiskAlertEnabled': streakAtRiskAlertEnabled,
        'cashReminderEnabled': cashReminderEnabled,
        'goalMilestonesEnabled': goalMilestonesEnabled,
      };

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      enabled: json['enabled'] as bool? ?? true,
      maxPerDay: json['maxPerDay'] as int? ?? 2,
      quietHoursStartHour: json['quietHoursStartHour'] as int? ?? 22,
      quietHoursEndHour: json['quietHoursEndHour'] as int? ?? 7,
      showAmountsOnLockScreen: json['showAmountsOnLockScreen'] as bool? ?? false,
      budget80AlertEnabled: json['budget80AlertEnabled'] as bool? ?? true,
      streakAtRiskAlertEnabled: json['streakAtRiskAlertEnabled'] as bool? ?? true,
      cashReminderEnabled: json['cashReminderEnabled'] as bool? ?? true,
      goalMilestonesEnabled: json['goalMilestonesEnabled'] as bool? ?? true,
    );
  }
}
