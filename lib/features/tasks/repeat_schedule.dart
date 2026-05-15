DateTime _startOfLocalDay(DateTime d) => DateTime(d.year, d.month, d.day);

/// Next moment the user may complete a repeating task again (local midnight rules).
/// Returns `null` when [repeatInterval] is 0 (no repeat) or unknown.
DateTime? nextBoundaryAfterCompletion(DateTime now, int repeatInterval) {
  final start = _startOfLocalDay(now);
  switch (repeatInterval) {
    case 0:
      return null;
    case 1:
      return start.add(const Duration(days: 1));
    case 2:
      return start.add(const Duration(days: 7));
    case 3:
      return _addOneCalendarMonthStartOfDay(start);
    default:
      return null;
  }
}

DateTime _addOneCalendarMonthStartOfDay(DateTime startOfDay) {
  var y = startOfDay.year;
  var m = startOfDay.month + 1;
  if (m > 12) {
    m = 1;
    y++;
  }
  // drift/dart DateTime(y, m+1, 0) gives the last day of month m.
  // We want the last day of our target month 'm'.
  final lastDayOfTargetMonth = DateTime(y, m + 1, 0).day;
  final day = startOfDay.day > lastDayOfTargetMonth
      ? lastDayOfTargetMonth
      : startOfDay.day;
  return DateTime(y, m, day);
}

bool isTaskCompletionGated({
  required bool isCompleted,
  required int repeatInterval,
  required DateTime? nextAllowedCompletionAt,
  required DateTime now,
}) {
  if (isCompleted) return false;
  if (repeatInterval == 0) return false;
  final t = nextAllowedCompletionAt;
  return t != null && now.isBefore(t);
}
