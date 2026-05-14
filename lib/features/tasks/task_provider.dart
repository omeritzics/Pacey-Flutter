import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import '../../core/database/database_provider.dart';
import '../../core/database/database.dart';
import '../../core/p2p/p2p_sync_provider.dart';
import '../energy/energy_provider.dart';
import '../gamification/gamification_provider.dart';
import 'repeat_schedule.dart';

final tasksProvider = StreamProvider<List<Task>>((ref) {
  final db = ref.read(databaseProvider);
  return db.select(db.tasks).watch();
});

final filteredTasksProvider = Provider<List<Task>>((ref) {
  final allTasks = ref.watch(tasksProvider).value ?? [];
  final energyLevel = ref.watch(energyLevelProvider);

  final list = allTasks.where((task) {
    return task.isCompleted || task.energyCost <= energyLevel;
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
    int energyCost, {
    int priority = 4,
    int repeatInterval = 0,
  }) async {
    final db = _ref.read(databaseProvider);
    final syncService = _ref.read(p2pSyncServiceProvider);

    final taskId = _uuid.v4();
    final now = DateTime.now();
    final p = _clampPriority(priority);
    final r = _clampRepeatInterval(repeatInterval);
    await db.into(db.tasks).insert(
          TasksCompanion.insert(
            id: taskId,
            title: title,
            energyCost: energyCost,
            priority: Value(p),
            repeatInterval: Value(r),
            updatedAt: Value(now),
          ),
        );

    final createdTask = await (db.select(db.tasks)
          ..where((t) => t.id.equals(taskId)))
        .getSingle();
    syncService.broadcastTaskCreated(createdTask);
  }

  Future<void> toggleTask(Task task) async {
    final db = _ref.read(databaseProvider);
    final syncService = _ref.read(p2pSyncServiceProvider);
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
      await (db.update(db.tasks)..where((t) => t.id.equals(task.id))).write(
            TasksCompanion(
              isCompleted: const Value(true),
              updatedAt: Value(now),
            ),
          );

      final completedTask = await (db.select(db.tasks)
            ..where((t) => t.id.equals(task.id)))
          .getSingle();
      syncService.broadcastTaskUpdated(completedTask);

      final currentEnergy = _ref.read(energyLevelProvider);
      if (task.energyCost <= currentEnergy) {
        await _ref.read(pacingStatsProvider.notifier).addXp(20);
      } else {
        await _ref.read(pacingStatsProvider.notifier).deductXp(30);
      }

      final newId = _uuid.v4();
      final nextAt = nextBoundaryAfterCompletion(now, task.repeatInterval);
      await db.into(db.tasks).insert(
            TasksCompanion.insert(
              id: newId,
              title: task.title,
              energyCost: task.energyCost,
              priority: Value(task.priority),
              repeatInterval: Value(task.repeatInterval),
              nextAllowedCompletionAt: Value(nextAt),
              isCompleted: const Value(false),
              updatedAt: Value(now),
            ),
          );

      final newTask = await (db.select(db.tasks)
            ..where((t) => t.id.equals(newId)))
          .getSingle();
      syncService.broadcastTaskCreated(newTask);
      return;
    }

    await (db.update(db.tasks)..where((t) => t.id.equals(task.id))).write(
          TasksCompanion(
            isCompleted: Value(isNowCompleted),
            updatedAt: Value(DateTime.now()),
          ),
        );

    final updatedTask = await (db.select(db.tasks)
          ..where((t) => t.id.equals(task.id)))
        .getSingle();
    syncService.broadcastTaskUpdated(updatedTask);

    final currentEnergy = _ref.read(energyLevelProvider);
    if (isNowCompleted) {
      if (task.energyCost <= currentEnergy) {
        await _ref.read(pacingStatsProvider.notifier).addXp(20);
      } else {
        await _ref.read(pacingStatsProvider.notifier).deductXp(30);
      }
    } else {
      if (task.energyCost <= currentEnergy) {
        await _ref.read(pacingStatsProvider.notifier).deductXp(20);
      }
    }
  }

  Future<void> editTask(
    String id,
    String title,
    int energyCost, {
    required int priority,
    required int repeatInterval,
  }) async {
    final db = _ref.read(databaseProvider);
    final syncService = _ref.read(p2pSyncServiceProvider);
    final p = _clampPriority(priority);
    final r = _clampRepeatInterval(repeatInterval);

    await (db.update(db.tasks)..where((t) => t.id.equals(id))).write(
          TasksCompanion(
            title: Value(title),
            energyCost: Value(energyCost),
            priority: Value(p),
            repeatInterval: Value(r),
            nextAllowedCompletionAt: r == 0
                ? const Value(null)
                : const Value.absent(),
            updatedAt: Value(DateTime.now()),
          ),
        );

    final updatedTask = await (db.select(db.tasks)
          ..where((t) => t.id.equals(id)))
        .getSingle();
    syncService.broadcastTaskUpdated(updatedTask);
  }

  Future<void> deleteTask(String id) async {
    final db = _ref.read(databaseProvider);
    final syncService = _ref.read(p2pSyncServiceProvider);

    await (db.delete(db.tasks)..where((t) => t.id.equals(id))).go();

    syncService.broadcastTaskDeleted(id);
  }
}
