import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import '../../core/database/database_provider.dart';
import '../../core/database/database.dart';
import '../energy/energy_provider.dart';
import '../gamification/gamification_provider.dart';
import 'repeat_schedule.dart';

final tasksProvider = StreamProvider<List<Task>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.tasks).watch();
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
    final db = _ref.read(databaseProvider);

    final taskId = _uuid.v4();
    final now = DateTime.now();
    final p = _clampPriority(priority);
    final r = _clampRepeatInterval(repeatInterval);
    await db
        .into(db.tasks)
        .insert(
          TasksCompanion.insert(
            id: taskId,
            title: title,
            requiredEnergy: requiredEnergy,
            priority: Value(p),
            repeatInterval: Value(r),
            updatedAt: Value(now),
          ),
        );

  }

  Future<void> toggleTask(Task task) async {
    final db = _ref.read(databaseProvider);
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
      // Mark original as completed and update its timestamp
      await (db.update(db.tasks)..where((t) => t.id.equals(task.id))).write(
        TasksCompanion(isCompleted: const Value(true), updatedAt: Value(now)),
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
      await db
          .into(db.tasks)
          .insert(
            TasksCompanion.insert(
              id: newId,
              title: task.title,
              requiredEnergy: task.requiredEnergy,
              priority: Value(task.priority),
              repeatInterval: Value(task.repeatInterval),
              nextAllowedCompletionAt: Value(nextAt),
              isCompleted: const Value(false),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );

      return;
    }

    await (db.update(db.tasks)..where((t) => t.id.equals(task.id))).write(
      TasksCompanion(isCompleted: Value(isNowCompleted), updatedAt: Value(now)),
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
  }

  Future<void> editTask(
    String id,
    String title,
    int requiredEnergy, {
    required int priority,
    required int repeatInterval,
  }) async {
    final db = _ref.read(databaseProvider);
    final p = _clampPriority(priority);
    final r = _clampRepeatInterval(repeatInterval);
    final now = DateTime.now();

    await (db.update(db.tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        title: Value(title),
        requiredEnergy: Value(requiredEnergy),
        priority: Value(p),
        repeatInterval: Value(r),
        nextAllowedCompletionAt: r == 0
            ? const Value(null)
            : const Value.absent(),
        updatedAt: Value(now),
      ),
    );

  }

  Future<void> deleteTask(String id) async {
    final db = _ref.read(databaseProvider);

    await (db.delete(db.tasks)..where((t) => t.id.equals(id))).go();
  }
}
