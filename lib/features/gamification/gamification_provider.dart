import 'dart:math' as math;
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
      final newStats = const PacingStats(
        id: 1,
        xp: 0,
        healingLevel: 1,
        currentStreak: 0,
      );
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
    await db.update(
      'pacing_stats',
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [state!.id],
    );
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
    await db.update(
      'pacing_stats',
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [state!.id],
    );
    state = updated;
  }

  int _calculateLevel(int xp) {
    if (xp < 0) return 1;
    final val = 2.25 + xp / 50.0;
    final level = (-0.5 + math.sqrt(val)).floor();
    return level < 1 ? 1 : level;
  }

  double getLevelProgress(int xp) {
    final level = _calculateLevel(xp);
    final currentLevelThreshold = 50 * level * level + 50 * level - 100;
    final nextLevelThreshold =
        50 * (level + 1) * (level + 1) + 50 * (level + 1) - 100;

    final progress =
        (xp - currentLevelThreshold) /
        (nextLevelThreshold - currentLevelThreshold);
    return progress.clamp(0.0, 1.0);
  }
}
