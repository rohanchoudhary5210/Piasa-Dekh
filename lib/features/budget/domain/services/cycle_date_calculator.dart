class CycleDateCalculator {
  CycleDateCalculator._();

  /// Returns the number of days in the specified month and year (handles leap years).
  static int daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  /// Clamps the target day of the month so it never exceeds the month's maximum days.
  static int clampDay(int year, int month, int targetDay) {
    final maxDays = daysInMonth(year, month);
    return targetDay.clamp(1, maxDays);
  }

  /// Calculates the start and end dates for a cycle anchored on [paydayDay] (1 to 31).
  static ({DateTime startDate, DateTime endDate, int totalDays}) computeCycleDates({
    required int year,
    required int month,
    required int paydayDay,
    DateTime? salaryReceivedDate,
  }) {
    final clampedStartDay = clampDay(year, month, paydayDay);
    var start = DateTime(year, month, clampedStartDay);

    if (salaryReceivedDate != null) {
      final normalizedReceived = DateTime(
        salaryReceivedDate.year,
        salaryReceivedDate.month,
        salaryReceivedDate.day,
      );
      if (normalizedReceived.isAfter(start)) {
        start = normalizedReceived;
      }
    }

    final nextMonthYear = month == 12 ? year + 1 : year;
    final nextMonth = month == 12 ? 1 : month + 1;
    final clampedNextPayday = clampDay(nextMonthYear, nextMonth, paydayDay);
    final nextPayday = DateTime(nextMonthYear, nextMonth, clampedNextPayday);

    final end = nextPayday.subtract(const Duration(days: 1));
    final totalDays = end.difference(start).inDays + 1;

    return (
      startDate: start,
      endDate: end,
      totalDays: totalDays > 0 ? totalDays : 1,
    );
  }

  /// Calculates the currently active cycle dates based on current [now] date and user's [paydayDay].
  /// - If paydayDay is 1: Cycle runs strictly within the calendar month (1st to last day of month).
  /// - If today's day of month >= paydayDay: Active cycle started in the current month on [paydayDay].
  /// - If today's day of month < paydayDay: Active cycle started in the previous month on [paydayDay].
  static ({DateTime startDate, DateTime endDate, int totalDays, int cycleYear, int cycleMonth}) computeActiveCycleDates({
    required DateTime now,
    required int paydayDay,
    DateTime? salaryReceivedDate,
  }) {
    int startYear;
    int startMonth;

    if (paydayDay <= 1) {
      startYear = now.year;
      startMonth = now.month;
    } else if (now.day >= paydayDay) {
      startYear = now.year;
      startMonth = now.month;
    } else {
      startYear = now.month == 1 ? now.year - 1 : now.year;
      startMonth = now.month == 1 ? 12 : now.month - 1;
    }

    final cycleDates = computeCycleDates(
      year: startYear,
      month: startMonth,
      paydayDay: paydayDay,
      salaryReceivedDate: salaryReceivedDate,
    );

    return (
      startDate: cycleDates.startDate,
      endDate: cycleDates.endDate,
      totalDays: cycleDates.totalDays,
      cycleYear: startYear,
      cycleMonth: startMonth,
    );
  }

  /// Returns the day index (1 to totalDays) for a given transaction [timestamp]
  /// strictly using the local device timezone calendar day.
  /// A payment at 23:59:59 and a payment at 00:00:01 will correctly land on different days.
  static int getDayIndexForTimestamp({
    required DateTime timestamp,
    required DateTime cycleStartDate,
    required int totalDays,
  }) {
    final localTx = timestamp.toLocal();
    final localStart = cycleStartDate.toLocal();

    final txDate = DateTime(localTx.year, localTx.month, localTx.day);
    final startDate = DateTime(localStart.year, localStart.month, localStart.day);

    final diff = txDate.difference(startDate).inDays + 1;
    if (diff < 1) return 1;
    if (diff > totalDays) return totalDays;
    return diff;
  }
}
