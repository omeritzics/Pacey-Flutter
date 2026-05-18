import 'package:flutter_test/flutter_test.dart';
import 'package:pacey/features/tasks/repeat_schedule.dart';

void main() {
  group('nextBoundaryAfterCompletion', () {
    test('returns null for off', () {
      final now = DateTime(2026, 6, 15, 14, 30);
      expect(nextBoundaryAfterCompletion(now, 0), isNull);
    });

    test('daily is start of next calendar day', () {
      final now = DateTime(2026, 6, 15, 14, 30);
      expect(nextBoundaryAfterCompletion(now, 1), DateTime(2026, 6, 16));
    });

    test('daily at midnight still next day', () {
      final now = DateTime(2026, 6, 15, 0, 0);
      expect(nextBoundaryAfterCompletion(now, 1), DateTime(2026, 6, 16));
    });

    test('weekly is start of day plus seven days', () {
      final now = DateTime(2026, 6, 15, 9, 0);
      expect(nextBoundaryAfterCompletion(now, 2), DateTime(2026, 6, 22));
    });

    test('monthly clamps Jan 31 to Feb last day', () {
      final now = DateTime(2026, 1, 31, 12, 0);
      expect(nextBoundaryAfterCompletion(now, 3), DateTime(2026, 2, 28));
    });

    test('monthly from Feb 28 non-leap', () {
      final now = DateTime(2025, 2, 28, 12, 0);
      expect(nextBoundaryAfterCompletion(now, 3), DateTime(2025, 3, 28));
    });
  });
}
