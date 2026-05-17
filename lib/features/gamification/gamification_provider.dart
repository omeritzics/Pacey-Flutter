import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/database_provider.dart';
import '../../core/database/database.dart';

final pacingStatsProvider = NotifierProvider<PacingStatsNotifier, PacingStats?>(
  () {
    return PacingStatsNotifier();
  },
);

class PacingStatsNotifier extends Notifier<PacingStats?> {
  @override
  PacingStats? build() {
    _init();
    return null;
  }

  Future<void> _init() async {
    final db = await ref.read(databaseProvider).database;
    final rows = await db.query('pacing_stats', limit: 1);
    if (rows.isEmpty) {
      final newStats = const PacingStats(id: 1, xp: 0, healingLevel: 1, currentStreak: 0);
      await db.insert('pacing_stats', newStats.toMap());
      state = newStats;
    } else {
      state = PacingStats.fromMap(rows.first);
    }
  }

  Future<void> addXp(int amount) async {
    if (state == null) return;
    final db = await ref.read(databaseProvider).database;

    final newXp = state!.xp + amount;
    final newLevel = _calculateLevel(newXp);

    final updated = state!.copyWith(
      xp: newXp,
      healingLevel: newLevel,
      lastLogDate: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await db.update('pacing_stats', updated.toMap(), where: 'id = ?', whereArgs: [state!.id]);
    state = updated;
  }

  Future<void> deductXp(int amount) async {
    if (state == null) return;
    final db = await ref.read(databaseProvider).database;

    final newXp = (state!.xp - amount).clamp(0, 1000000).toInt();
    final newLevel = _calculateLevel(newXp);

    final updated = state!.copyWith(
      xp: newXp,
      healingLevel: newLevel,
      lastLogDate: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await db.update('pacing_stats', updated.toMap(), where: 'id = ?', whereArgs: [state!.id]);
    state = updated;
  }

  int _calculateLevel(int xp) {
    if (xp < 200) return 1;
    if (xp < 500) return 2;
    if (xp < 900) return 3;
    if (xp < 1400) return 4;
    return (xp ~/ 500) + 1;
  }

  double getLevelProgress(int xp) {
    int currentLevelThreshold;
    int nextLevelThreshold;

    if (xp < 200) {
      currentLevelThreshold = 0;
      nextLevelThreshold = 200;
    } else if (xp < 500) {
      currentLevelThreshold = 200;
      nextLevelThreshold = 500;
    } else if (xp < 900) {
      currentLevelThreshold = 500;
      nextLevelThreshold = 900;
    } else if (xp < 1400) {
      currentLevelThreshold = 900;
      nextLevelThreshold = 1400;
    } else {
      // For XP >= 1400, levels increase by 500 XP each
      final levelAbove4 = (xp - 1400) ~/ 500 + 1;
      currentLevelThreshold = 1400 + (levelAbove4 - 1) * 500;
      nextLevelThreshold = 1400 + levelAbove4 * 500;
    }

    final progress =
        (xp - currentLevelThreshold) /
        (nextLevelThreshold - currentLevelThreshold);
    return progress.clamp(0.0, 1.0);
  }
}
