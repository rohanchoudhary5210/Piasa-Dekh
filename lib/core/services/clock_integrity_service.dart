class ClockIntegrityService {
  ClockIntegrityService._();

  /// Tolerance for small clock drifts (e.g. network NTP synchronization)
  static const Duration driftTolerance = Duration(minutes: 2);

  /// Checks if the device clock has moved backwards relative to the last recorded timestamp.
  /// If [currentTimestamp] is earlier than [lastKnownTimestamp] by more than [driftTolerance],
  /// it is flagged as tampered.
  static bool isClockManipulated({
    required DateTime currentTimestamp,
    DateTime? lastKnownTimestamp,
  }) {
    if (lastKnownTimestamp == null) return false;
    final diff = lastKnownTimestamp.difference(currentTimestamp);
    return diff > driftTolerance;
  }
}
