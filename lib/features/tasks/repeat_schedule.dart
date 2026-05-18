/// Next moment the user may complete a repeating task again (local midnight rules).
/// Returns `null` when [repeatInterval] is 0 (no repeat) or unknown.
DateTime? nextBoundaryAfterCompletion(
  DateTime now,
  int repeatInterval, {
  String? repeatDays,
}) {
  final start = DateTime(now.year, now.month, now.day);
  switch (repeatInterval) {
    case 0:
      return null;
    case 1:
      return start.add(const Duration(days: 1));
    case 2:
      if (repeatDays != null && repeatDays.isNotEmpty) {
        final days = repeatDays
            .split(',')
            .map((s) => int.tryParse(s.trim()))
            .whereType<int>()
            .toList();
        if (days.isNotEmpty) {
          for (int i = 1; i <= 7; i++) {
            final nextDay = start.add(Duration(days: i));
            if (days.contains(nextDay.weekday)) {
              return nextDay;
            }
          }
        }
      }
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
