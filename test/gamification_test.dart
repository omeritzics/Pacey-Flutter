import 'package:flutter_test/flutter_test.dart';
import 'package:pacey/features/gamification/gamification_provider.dart';

void main() {
  group('getLevelProgress', () {
    test('returns 0.0 for XP 0', () {
      final notifier = PacingStatsNotifier();
      expect(notifier.getLevelProgress(0), 0.0);
    });

    test('returns 0.5 for XP 100 (halfway through level 1)', () {
      final notifier = PacingStatsNotifier();
      expect(notifier.getLevelProgress(100), 0.5);
    });

    test('returns 0.0 for XP 200 (start of level 2)', () {
      final notifier = PacingStatsNotifier();
      expect(notifier.getLevelProgress(200), 0.0);
    });

    test('returns 0.5 for XP 350 (halfway through level 2)', () {
      final notifier = PacingStatsNotifier();
      expect(notifier.getLevelProgress(350), 0.5);
    });

    test('returns 0.0 for XP 500 (start of level 3)', () {
      final notifier = PacingStatsNotifier();
      expect(notifier.getLevelProgress(500), 0.0);
    });

    test('returns 0.0 for XP 900 (start of level 4)', () {
      final notifier = PacingStatsNotifier();
      expect(notifier.getLevelProgress(900), 0.0);
    });

    test('returns 0.0 for XP 1400 (start of level 5)', () {
      final notifier = PacingStatsNotifier();
      expect(notifier.getLevelProgress(1400), 0.0);
    });

    test('returns 0.5 for XP 1650 (halfway through level 5)', () {
      final notifier = PacingStatsNotifier();
      expect(notifier.getLevelProgress(1650), 0.5);
    });

    test('returns 0.0 for XP 1900 (start of level 6)', () {
      final notifier = PacingStatsNotifier();
      expect(notifier.getLevelProgress(1900), 0.0);
    });

    test('returns 0.0 for XP 2400 (start of level 7)', () {
      final notifier = PacingStatsNotifier();
      expect(notifier.getLevelProgress(2400), 0.0);
    });

    test('returns 0.5 for XP 2650 (halfway through level 7)', () {
      final notifier = PacingStatsNotifier();
      expect(notifier.getLevelProgress(2650), 0.5);
    });

    test('returns 1.0 for XP just below threshold', () {
      final notifier = PacingStatsNotifier();
      expect(notifier.getLevelProgress(1399), closeTo(0.999, 0.001));
    });
  });
}