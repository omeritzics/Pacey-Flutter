import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/backup/backup_provider.dart';
import '../../core/backup/backup_settings_provider.dart';
import '../../core/database/database_provider.dart';
import '../../core/database/database.dart';
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
    final db = await ref.read(databaseProvider).database;
    final rows = await db.query(
      'energy_logs',
      orderBy: 'timestamp DESC',
      limit: 1,
    );

    if (rows.isNotEmpty) {
      state = EnergyLog.fromMap(rows.first).level;
    }
  }

  Future<bool> updateLevel(int newLevel) async {
    if (newLevel < 1) newLevel = 1;
    if (newLevel > 10) newLevel = 10;

    final db = await ref.read(databaseProvider).database;
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
    final logRows = await db.query(
      'energy_logs',
      where: 'timestamp >= ?',
      whereArgs: [todayStart.millisecondsSinceEpoch],
    );
    final logsToday = logRows.map(EnergyLog.fromMap).toList();

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

    final syncId = const Uuid().v4();
    await db.insert('energy_logs', {
      'sync_id': syncId,
      'level': newLevel,
      'timestamp': now.millisecondsSinceEpoch,
      'updated_at': now.millisecondsSinceEpoch,
    });

    // Gamification Rewards
    if (logsToday.isEmpty) {
      // First log of the day (Morning or whenever they wake up)
      await ref.read(pacingStatsProvider.notifier).addXp(10);
    } else if (logsToday.length == 2) {
      // Third and final block log of the day
      await ref.read(pacingStatsProvider.notifier).addXp(50);
    }

    final settings = ref.read(backupSettingsProvider);
    if (settings.isAutoExportEnabled) {
      ref.read(backupServiceProvider).autoExport(
            ref.read(databaseProvider),
            path: settings.autoExportPath,
          );
    }

    return true;
  }
}
