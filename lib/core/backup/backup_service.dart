import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/database/database.dart';

const int backupFormatVersion = 2;

enum ImportMode { merge, replace }

class BackupImportResult {
  const BackupImportResult({
    required this.tasksImported,
    required this.energyLogsImported,
  });

  final int tasksImported;
  final int energyLogsImported;
}

class BackupException implements Exception {
  BackupException(this.message);
  final String message;

  @override
  String toString() => message;
}

class BackupService {
  Future<String> exportData(AppDatabase appDb) async {
    final db = await appDb.database;
    final tasks = await db.query('tasks');
    final energyLogs = await db.query('energy_logs');

    final data = <String, dynamic>{
      'version': backupFormatVersion,
      'app': 'pacey',
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'tasks': tasks.map((row) {
        final task = Task.fromMap(row);
        return {
          'id': task.id,
          'title': task.title,
          'requiredEnergy': task.requiredEnergy,
          'priority': task.priority,
          'repeatInterval': task.repeatInterval,
          'nextAllowedCompletionAt': task.nextAllowedCompletionAt
              ?.toIso8601String(),
          'isCompleted': task.isCompleted,
          'createdAt': task.createdAt.toIso8601String(),
          'updatedAt': (task.updatedAt ?? task.createdAt).toIso8601String(),
        };
      }).toList(),
      'energyLogs': energyLogs.map((row) {
        final log = EnergyLog.fromMap(row);
        return {
          'syncId': log.syncId ?? '',
          'level': log.level,
          'timestamp': log.timestamp.toIso8601String(),
          'updatedAt': (log.updatedAt ?? log.timestamp).toIso8601String(),
        };
      }).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  Future<BackupImportResult> importData(
    AppDatabase appDb,
    String jsonString, {
    required ImportMode mode,
  }) async {
    final db = await appDb.database;

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

    await db.transaction((txn) async {
      if (mode == ImportMode.replace) {
        await txn.delete('tasks');
        await txn.delete('energy_logs');
      }

      final tasks = data['tasks'];
      if (tasks is List) {
        for (final item in tasks) {
          if (item is Map<String, dynamic>) {
            final imported = await _importTask(txn, item, mode: mode);
            if (imported) tasksImported++;
          }
        }
      }

      final energyLogs = data['energyLogs'];
      if (energyLogs is List) {
        for (final item in energyLogs) {
          if (item is Map<String, dynamic>) {
            final imported = await _importEnergyLog(txn, item, mode: mode);
            if (imported) energyLogsImported++;
          }
        }
      }
    });

    return BackupImportResult(
      tasksImported: tasksImported,
      energyLogsImported: energyLogsImported,
    );
  }

  Future<bool> _importTask(
    dynamic txn,
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

    final existing =
        await txn.query('tasks', where: 'id = ?', whereArgs: [taskId])
            as List<Map<String, dynamic>>;

    if (mode == ImportMode.merge && existing.isNotEmpty) {
      final existingTask = Task.fromMap(existing.first);
      if (existingTask.updatedAt != null &&
          existingTask.updatedAt!.isAfter(incomingUpdatedAt)) {
        return false;
      }
    }

    final priority = ((taskData['priority'] as num?)?.toInt() ?? 4).clamp(1, 4);
    var repeatInterval = (taskData['repeatInterval'] as num?)?.toInt() ?? 0;
    repeatInterval = repeatInterval.clamp(0, 3);

    DateTime? nextAllowedCompletionAt;
    final nextRaw = taskData['nextAllowedCompletionAt'];
    if (nextRaw is String && nextRaw.isNotEmpty) {
      nextAllowedCompletionAt = DateTime.parse(nextRaw);
    }

    final createdAt = existing.isNotEmpty
        ? Task.fromMap(existing.first).createdAt
        : (taskData['createdAt'] is String
              ? DateTime.parse(taskData['createdAt'] as String)
              : incomingUpdatedAt);

    final values = {
      'id': taskId,
      'title': title,
      'required_energy': requiredEnergy.toInt(),
      'priority': priority,
      'repeat_interval': repeatInterval,
      'next_allowed_completion_at':
          nextAllowedCompletionAt?.millisecondsSinceEpoch,
      'is_completed': (taskData['isCompleted'] as bool? ?? false) ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': incomingUpdatedAt.millisecondsSinceEpoch,
    };

    if (existing.isEmpty) {
      await txn.insert('tasks', values);
    } else {
      await txn.update('tasks', values, where: 'id = ?', whereArgs: [taskId]);
    }
    return true;
  }

  Future<bool> _importEnergyLog(
    dynamic txn,
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

    final existing =
        await txn.query(
              'energy_logs',
              where: 'sync_id = ?',
              whereArgs: [syncId],
            )
            as List<Map<String, dynamic>>;

    if (mode == ImportMode.merge && existing.isNotEmpty) {
      final existingLog = EnergyLog.fromMap(existing.first);
      if (existingLog.updatedAt != null &&
          existingLog.updatedAt!.isAfter(incomingUpdatedAt)) {
        return false;
      }
    }

    final level = logData['level'];
    if (level is! num) return false;

    final values = {
      'sync_id': syncId,
      'level': level.toInt(),
      'timestamp': timestamp.millisecondsSinceEpoch,
      'updated_at': incomingUpdatedAt.millisecondsSinceEpoch,
    };

    if (existing.isEmpty) {
      await txn.insert('energy_logs', values);
    } else {
      final existingId = existing.first['id'];
      await txn.update(
        'energy_logs',
        values,
        where: 'id = ?',
        whereArgs: [existingId],
      );
    }
    return true;
  }

  Future<void> autoExport(AppDatabase appDb, {String? path}) async {
    try {
      final json = await exportData(appDb);

      late final File file;
      if (path != null) {
        file = File(path);
      } else {
        final dir = await getApplicationDocumentsDirectory();
        file = File('${dir.path}/pacey_auto_backup.json');
      }

      // Ensure the directory exists
      final bool directoryExists = await file.parent.exists();
      if (!directoryExists) {
        await file.parent.create(recursive: true);
      }

      await file.writeAsString(json);
    } catch (e) {
      // Log the error for debugging
      if (kDebugMode) print('Auto export failed: $e');
    }
  }

  Future<BackupImportResult?> importFromFolder(
    AppDatabase appDb, {
    String? path,
    ImportMode mode = ImportMode.merge,
  }) async {
    late final File file;
    if (path != null) {
      file = File(path);
    } else {
      final dir = await getApplicationDocumentsDirectory();
      file = File('${dir.path}/pacey_auto_backup.json');
    }

    if (!await file.exists()) return null;

    final jsonString = await file.readAsString();
    return importData(appDb, jsonString, mode: mode);
  }
}
