import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/backup/backup_settings_provider.dart';
import '../../core/backup/backup_provider.dart';
import '../../core/database/database_provider.dart';
import '../../core/database/database.dart';
import '../energy/energy_provider.dart';
import '../gamification/gamification_provider.dart';
import 'repeat_schedule.dart';

/// Polls the tasks table and emits updates.
final tasksProvider = StreamProvider<List<Task>>((ref) {
  final appDb = ref.watch(databaseProvider);
  // sqflite has no built-in watch(); poll every 500ms.
  final controller = StreamController<List<Task>>();

  Timer? timer;

  Future<void> fetch() async {
    final db = await appDb.database;
    final rows = await db.query('tasks');
    controller.add(rows.map(Task.fromMap).toList());
  }

  fetch(); // initial load
  timer = Timer.periodic(const Duration(milliseconds: 500), (_) => fetch());

  ref.onDispose(() {
    timer?.cancel();
    controller.close();
  });

  return controller.stream;
});

final filteredTasksProvider = Provider<List<Task>>((ref) {
  final allTasks = ref.watch(tasksProvider).value ?? [];
  final energyLevel = ref.watch(energyLevelProvider);

  final list = allTasks.where((task) {
    return task.isCompleted || task.requiredEnergy <= energyLevel;
  }).toList();

  list.sort((a, b) {
    final byPriority = a.priority.compareTo(b.priority);
    if (byPriority != 0) return byPriority;
    final byCreated = a.createdAt.compareTo(b.createdAt);
    if (byCreated != 0) return byCreated;
    return a.title.compareTo(b.title);
  });
  return list;
});

final taskActionsProvider = Provider((ref) => TaskActions(ref));

class TaskActions {
  final Ref _ref;
  final _uuid = const Uuid();

  TaskActions(this._ref);

  int _clampPriority(int priority) => priority.clamp(1, 4);

  int _clampRepeatInterval(int v) => v.clamp(0, 3);

  Future<void> addTask(
    String title,
    int requiredEnergy, {
    int priority = 4,
    int repeatInterval = 0,
  }) async {
    final db = await _ref.read(databaseProvider).database;

    final taskId = _uuid.v4();
    final now = DateTime.now();
    final p = _clampPriority(priority);
    final r = _clampRepeatInterval(repeatInterval);

    await db.insert('tasks', {
      'id': taskId,
      'title': title,
      'required_energy': requiredEnergy,
      'priority': p,
      'repeat_interval': r,
      'is_completed': 0,
      'updated_at': now.millisecondsSinceEpoch,
      'created_at': now.millisecondsSinceEpoch,
    });
    final settings = _ref.read(backupSettingsProvider);
    if (settings.isAutoExportEnabled) {
      _ref.read(backupServiceProvider).autoExport(
            _ref.read(databaseProvider),
            path: settings.autoExportPath,
          );
    }
  }

  Future<void> toggleTask(Task task) async {
    final db = await _ref.read(databaseProvider).database;
    final isNowCompleted = !task.isCompleted;
    final now = DateTime.now();

    if (isNowCompleted &&
        task.repeatInterval != 0 &&
        isTaskCompletionGated(
          isCompleted: task.isCompleted,
          repeatInterval: task.repeatInterval,
          nextAllowedCompletionAt: task.nextAllowedCompletionAt,
          now: now,
        )) {
      return;
    }

    if (isNowCompleted && task.repeatInterval != 0) {
      // Mark original as completed
      await db.update(
        'tasks',
        {
          'is_completed': 1,
          'updated_at': now.millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [task.id],
      );

      // Award XP
      final currentEnergy = _ref.read(energyLevelProvider);
      if (task.requiredEnergy <= currentEnergy) {
        await _ref.read(pacingStatsProvider.notifier).addXp(20);
      } else {
        await _ref.read(pacingStatsProvider.notifier).deductXp(30);
      }

      // Create the NEXT occurrence of this task
      final newId = _uuid.v4();
      final nextAt = nextBoundaryAfterCompletion(now, task.repeatInterval);

      await db.insert('tasks', {
        'id': newId,
        'title': task.title,
        'required_energy': task.requiredEnergy,
        'priority': task.priority,
        'repeat_interval': task.repeatInterval,
        'next_allowed_completion_at': nextAt?.millisecondsSinceEpoch,
        'is_completed': 0,
        'created_at': now.millisecondsSinceEpoch,
        'updated_at': now.millisecondsSinceEpoch,
      });

      final settings = _ref.read(backupSettingsProvider);
      if (settings.isAutoExportEnabled) {
        _ref.read(backupServiceProvider).autoExport(
              _ref.read(databaseProvider),
              path: settings.autoExportPath,
            );
      }

      return;
    }

    await db.update(
      'tasks',
      {
        'is_completed': isNowCompleted ? 1 : 0,
        'updated_at': now.millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [task.id],
    );

    final currentEnergy = _ref.read(energyLevelProvider);
    if (isNowCompleted) {
      if (task.requiredEnergy <= currentEnergy) {
        await _ref.read(pacingStatsProvider.notifier).addXp(20);
      } else {
        await _ref.read(pacingStatsProvider.notifier).deductXp(30);
      }
    } else {
      if (task.requiredEnergy <= currentEnergy) {
        await _ref.read(pacingStatsProvider.notifier).deductXp(20);
      }
    }

    final settings = _ref.read(backupSettingsProvider);
    if (settings.isAutoExportEnabled) {
      _ref.read(backupServiceProvider).autoExport(
            _ref.read(databaseProvider),
            path: settings.autoExportPath,
          );
    }
  }

  Future<void> editTask(
    String id,
    String title,
    int requiredEnergy, {
    required int priority,
    required int repeatInterval,
  }) async {
    final db = await _ref.read(databaseProvider).database;
    final p = _clampPriority(priority);
    final r = _clampRepeatInterval(repeatInterval);
    final now = DateTime.now();

    final values = <String, dynamic>{
      'title': title,
      'required_energy': requiredEnergy,
      'priority': p,
      'repeat_interval': r,
      'updated_at': now.millisecondsSinceEpoch,
    };
    if (r == 0) {
      values['next_allowed_completion_at'] = null;
    }

    await db.update(
      'tasks',
      values,
      where: 'id = ?',
      whereArgs: [id],
    );

    final settings = _ref.read(backupSettingsProvider);
    if (settings.isAutoExportEnabled) {
      _ref.read(backupServiceProvider).autoExport(
            _ref.read(databaseProvider),
            path: settings.autoExportPath,
          );
    }
  }

  Future<void> deleteTask(String id) async {
    final db = await _ref.read(databaseProvider).database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);

    final settings = _ref.read(backupSettingsProvider);
    if (settings.isAutoExportEnabled) {
      _ref.read(backupServiceProvider).autoExport(
            _ref.read(databaseProvider),
            path: settings.autoExportPath,
          );
    }
  }
}
