import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import '../../core/database/database_provider.dart';
import '../../core/database/database.dart';
import '../../core/p2p/p2p_sync_provider.dart';
import '../gamification/gamification_provider.dart';

final energyLevelProvider = NotifierProvider<EnergyLevelNotifier, int>(() {
  return EnergyLevelNotifier();
});

class EnergyLevelNotifier extends Notifier<int> {
  @override
  int build() {
    _loadLatestLevel();
    return 5; // Default value
  }

  Future<void> _loadLatestLevel() async {
    final db = ref.read(databaseProvider);
    final latest =
        await (db.select(db.energyLogs)
              ..orderBy([(t) => OrderingTerm.desc(t.timestamp)])
              ..limit(1))
            .getSingleOrNull();

    if (latest != null) {
      state = latest.level;
    }
  }

  Future<bool> updateLevel(int newLevel) async {
    if (newLevel < 1) newLevel = 1;
    if (newLevel > 10) newLevel = 10;

    final db = ref.read(databaseProvider);
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    // Define time blocks
    // Morning: 5am - 12pm
    // Afternoon: 12pm - 6pm
    // Night: 6pm - 5am (next day)
    String currentBlock;
    if (now.hour >= 5 && now.hour < 12) {
      currentBlock = 'morning';
    } else if (now.hour >= 12 && now.hour < 18) {
      currentBlock = 'afternoon';
    } else {
      currentBlock = 'night';
    }

    // Check if we already have a log in this block today
    final logsToday = await (db.select(
      db.energyLogs,
    )..where((t) => t.timestamp.isBiggerOrEqualValue(todayStart))).get();

    bool alreadyLoggedThisBlock = logsToday.any((log) {
      final h = log.timestamp.hour;
      if (currentBlock == 'morning') return h >= 5 && h < 12;
      if (currentBlock == 'afternoon') return h >= 12 && h < 18;
      return h >= 18 || h < 5;
    });

    if (alreadyLoggedThisBlock) {
      return false; // Prevent double logging
    }

    state = newLevel;

    final energyLog = await db
        .into(db.energyLogs)
        .insertReturning(
          EnergyLogsCompanion.insert(level: newLevel, timestamp: Value(now)),
        );

    // Broadcast energy log to connected peers
    final syncService = ref.read(p2pSyncServiceProvider);
    syncService.broadcastEnergyLogCreated(energyLog);

    // Gamification Rewards
    if (logsToday.isEmpty) {
      // First log of the day (Morning or whenever they wake up)
      await ref.read(pacingStatsProvider.notifier).addXp(10);
    } else if (logsToday.length == 2) {
      // Third and final block log of the day
      await ref.read(pacingStatsProvider.notifier).addXp(50);
    }

    return true;
  }
}
