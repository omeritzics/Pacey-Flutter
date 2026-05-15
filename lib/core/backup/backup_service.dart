import 'dart:convert';

import 'package:drift/drift.dart';

import '../database/database.dart';

const int backupFormatVersion = 1;

enum ImportMode { merge, replace }

class BackupImportResult {
  const BackupImportResult({
    required this.tasksImported,
    required this.energyLogsImported,
    required this.pacingStatsImported,
  });

  final int tasksImported;
  final int energyLogsImported;
  final bool pacingStatsImported;
}

class BackupException implements Exception {
  BackupException(this.message);
  final String message;

  @override
  String toString() => message;
}

class BackupService {
  Future<String> exportData(AppDatabase database) async {
    final tasks = await database.select(database.tasks).get();
    final energyLogs = await database.select(database.energyLogs).get();
    final pacingStats = await database.select(database.pacingStats).get();

    final data = <String, dynamic>{
      'version': backupFormatVersion,
      'app': 'pacey',
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'tasks': tasks.map(_taskToJson).toList(),
      'energyLogs': energyLogs.map(_energyLogToJson).toList(),
      'pacingStats': pacingStats.isEmpty ? null : _pacingStatsToJson(pacingStats.first),
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  Future<BackupImportResult> importData(
    AppDatabase database,
    String jsonString, {
    required ImportMode mode,
  }) async {
    final Map<String, dynamic> data;
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is! Map<String, dynamic>) {
        throw BackupException('Invalid backup file format.');
      }
      data = decoded;
    } on FormatException {
      throw BackupException('Invalid backup file format.');
    }

    if (data['app'] != 'pacey') {
      throw BackupException('This file is not a Pacey backup.');
    }

    final version = (data['version'] as num?)?.toInt();
    if (version == null || version > backupFormatVersion) {
      throw BackupException('Unsupported backup version.');
    }

    var tasksImported = 0;
    var energyLogsImported = 0;
    var pacingStatsImported = false;

    await database.transaction(() async {
      if (mode == ImportMode.replace) {
        await database.delete(database.tasks).go();
        await database.delete(database.energyLogs).go();
        await database.delete(database.pacingStats).go();
      }

      final tasks = data['tasks'];
      if (tasks is List) {
        for (final item in tasks) {
          if (item is Map<String, dynamic>) {
            final imported = await _importTask(database, item, mode: mode);
            if (imported) tasksImported++;
          }
        }
      }

      final energyLogs = data['energyLogs'];
      if (energyLogs is List) {
        for (final item in energyLogs) {
          if (item is Map<String, dynamic>) {
            final imported = await _importEnergyLog(database, item, mode: mode);
            if (imported) energyLogsImported++;
          }
        }
      }

      final pacingStats = data['pacingStats'];
      if (pacingStats is Map<String, dynamic>) {
        pacingStatsImported = await _importPacingStats(
          database,
          pacingStats,
          mode: mode,
        );
      }
    });

    return BackupImportResult(
      tasksImported: tasksImported,
      energyLogsImported: energyLogsImported,
      pacingStatsImported: pacingStatsImported,
    );
  }

  Map<String, dynamic> _taskToJson(Task task) => {
    'id': task.id,
    'title': task.title,
    'requiredEnergy': task.requiredEnergy,
    'priority': task.priority,
    'repeatInterval': task.repeatInterval,
    'nextAllowedCompletionAt': task.nextAllowedCompletionAt?.toIso8601String(),
    'isCompleted': task.isCompleted,
    'createdAt': task.createdAt.toIso8601String(),
    'updatedAt': (task.updatedAt ?? task.createdAt).toIso8601String(),
  };

  Map<String, dynamic> _energyLogToJson(EnergyLog log) => {
    'syncId': log.syncId ?? '',
    'level': log.level,
    'timestamp': log.timestamp.toIso8601String(),
    'updatedAt': (log.updatedAt ?? log.timestamp).toIso8601String(),
  };

  Map<String, dynamic> _pacingStatsToJson(PacingStat stat) => {
    'xp': stat.xp,
    'healingLevel': stat.healingLevel,
    'currentStreak': stat.currentStreak,
    'lastLogDate': stat.lastLogDate?.toIso8601String(),
    'updatedAt':
        stat.updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
  };

  Future<bool> _importTask(
    AppDatabase database,
    Map<String, dynamic> taskData, {
    required ImportMode mode,
  }) async {
    final taskId = taskData['id'] as String?;
    final title = taskData['title'] as String?;
    final requiredEnergy = taskData['requiredEnergy'];
    if (taskId == null || title == null || requiredEnergy is! num) {
      return false;
    }

    final incomingUpdatedAt = DateTime.parse(taskData['updatedAt'] as String);

    final existingTask = await (database.select(
      database.tasks,
    )..where((t) => t.id.equals(taskId))).getSingleOrNull();

    if (mode == ImportMode.merge &&
        existingTask != null &&
        existingTask.updatedAt != null &&
        existingTask.updatedAt!.isAfter(incomingUpdatedAt)) {
      return false;
    }

    final priority = ((taskData['priority'] as num?)?.toInt() ?? 4).clamp(1, 4);
    var repeatInterval = (taskData['repeatInterval'] as num?)?.toInt() ?? 0;
    repeatInterval = repeatInterval.clamp(0, 3);
    DateTime? nextAllowedCompletionAt;
    final nextRaw = taskData['nextAllowedCompletionAt'];
    if (nextRaw is String && nextRaw.isNotEmpty) {
      nextAllowedCompletionAt = DateTime.parse(nextRaw);
    }

    final createdAt = existingTask?.createdAt ??
        (taskData['createdAt'] is String
            ? DateTime.parse(taskData['createdAt'] as String)
            : incomingUpdatedAt);

    final task = TasksCompanion.insert(
      id: taskId,
      title: title,
      requiredEnergy: requiredEnergy.toInt(),
      priority: Value(priority),
      repeatInterval: Value(repeatInterval),
      nextAllowedCompletionAt: Value(nextAllowedCompletionAt),
      isCompleted: Value(taskData['isCompleted'] as bool? ?? false),
      createdAt: Value(createdAt),
      updatedAt: Value(incomingUpdatedAt),
    );

    if (existingTask == null) {
      await database.into(database.tasks).insert(task);
    } else {
      await database.update(database.tasks).replace(task);
    }
    return true;
  }

  Future<bool> _importEnergyLog(
    AppDatabase database,
    Map<String, dynamic> logData, {
    required ImportMode mode,
  }) async {
    final syncId = logData['syncId'] as String?;
    if (syncId == null || syncId.isEmpty) return false;

    final timestampRaw = logData['timestamp'] as String?;
    if (timestampRaw == null) return false;

    final timestamp = DateTime.parse(timestampRaw);
    final updatedAtRaw = logData['updatedAt'] as String?;
    final incomingUpdatedAt = updatedAtRaw != null
        ? DateTime.parse(updatedAtRaw)
        : timestamp;

    final existingLog = await (database.select(
      database.energyLogs,
    )..where((t) => t.syncId.equals(syncId))).getSingleOrNull();

    if (mode == ImportMode.merge &&
        existingLog != null &&
        existingLog.updatedAt != null &&
        existingLog.updatedAt!.isAfter(incomingUpdatedAt)) {
      return false;
    }

    final level = logData['level'];
    if (level is! num) return false;

    final log = EnergyLogsCompanion.insert(
      syncId: Value(syncId),
      level: level.toInt(),
      timestamp: Value(timestamp),
      updatedAt: Value(incomingUpdatedAt),
    );

    if (existingLog == null) {
      await database.into(database.energyLogs).insert(log);
    } else {
      final updatedLog = log.copyWith(id: Value(existingLog.id));
      await database.update(database.energyLogs).replace(updatedLog);
    }
    return true;
  }

  Future<bool> _importPacingStats(
    AppDatabase database,
    Map<String, dynamic> statsData, {
    required ImportMode mode,
  }) async {
    final incomingUpdatedAt = DateTime.parse(statsData['updatedAt'] as String);
    final incomingXp = (statsData['xp'] as num).toInt();
    final incomingStreak = (statsData['currentStreak'] as num).toInt();

    DateTime? incomingLastLogDate;
    final lastLogDateRaw = statsData['lastLogDate'];
    if (lastLogDateRaw is String && lastLogDateRaw.isNotEmpty) {
      incomingLastLogDate = DateTime.parse(lastLogDateRaw);
    }

    final existingStats = await database.select(database.pacingStats).get();

    if (existingStats.isEmpty || mode == ImportMode.replace) {
      if (existingStats.isNotEmpty) {
        await database.delete(database.pacingStats).go();
      }
      final stats = PacingStatsCompanion.insert(
        xp: Value(incomingXp.clamp(0, 1000000)),
        healingLevel: Value(_calculateHealingLevel(incomingXp)),
        currentStreak: Value(incomingStreak),
        lastLogDate: incomingLastLogDate != null
            ? Value(incomingLastLogDate)
            : const Value.absent(),
        updatedAt: Value(incomingUpdatedAt),
      );
      await database.into(database.pacingStats).insert(stats);
      return true;
    }

    final localStats = existingStats.first;
    final mergedXp = localStats.xp > incomingXp ? localStats.xp : incomingXp;
    final mergedStreak = localStats.currentStreak > incomingStreak
        ? localStats.currentStreak
        : incomingStreak;

    DateTime? mergedLastLogDate;
    if (localStats.lastLogDate != null && incomingLastLogDate != null) {
      mergedLastLogDate = localStats.lastLogDate!.isAfter(incomingLastLogDate)
          ? localStats.lastLogDate
          : incomingLastLogDate;
    } else {
      mergedLastLogDate = localStats.lastLogDate ?? incomingLastLogDate;
    }

    final xpChanged = mergedXp != localStats.xp;
    final streakChanged = mergedStreak != localStats.currentStreak;
    final dateChanged = mergedLastLogDate != localStats.lastLogDate;

    final incomingIsNewer =
        localStats.updatedAt == null ||
        incomingUpdatedAt.isAfter(localStats.updatedAt!);

    if (!incomingIsNewer && !xpChanged && !streakChanged && !dateChanged) {
      return false;
    }

    final updatedStats = PacingStatsCompanion.insert(
      xp: Value(mergedXp),
      healingLevel: Value(_calculateHealingLevel(mergedXp)),
      currentStreak: Value(mergedStreak),
      lastLogDate: mergedLastLogDate != null
          ? Value(mergedLastLogDate)
          : const Value.absent(),
      updatedAt: Value(
        incomingIsNewer ? incomingUpdatedAt : localStats.updatedAt!,
      ),
    ).copyWith(id: Value(localStats.id));

    await database.update(database.pacingStats).replace(updatedStats);
    return true;
  }

  int _calculateHealingLevel(int xp) {
    if (xp < 200) return 1;
    if (xp < 500) return 2;
    if (xp < 900) return 3;
    if (xp < 1400) return 4;
    return (xp / 500).floor() + 1;
  }
}
