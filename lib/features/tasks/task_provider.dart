import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import '../../core/database/database_provider.dart';
import '../../core/database/database.dart';
import '../energy/energy_provider.dart';

import '../gamification/gamification_provider.dart';

final tasksProvider = StreamProvider<List<Task>>((ref) {
  final db = ref.read(databaseProvider);
  return db.select(db.tasks).watch();
});

final filteredTasksProvider = Provider<List<Task>>((ref) {
  final allTasks = ref.watch(tasksProvider).value ?? [];
  final energyLevel = ref.watch(energyLevelProvider);

  // Filter: Only show tasks that cost <= current energy level
  // Also keep completed tasks visible for history/satisfaction
  return allTasks.where((task) {
    return task.isCompleted || task.energyCost <= energyLevel;
  }).toList();
});

final taskActionsProvider = Provider((ref) => TaskActions(ref));

class TaskActions {
  final Ref _ref;
  final _uuid = const Uuid();

  TaskActions(this._ref);

  Future<void> addTask(String title, int energyCost) async {
    final db = _ref.read(databaseProvider);
    await db
        .into(db.tasks)
        .insert(
          TasksCompanion.insert(
            id: _uuid.v4(),
            title: title,
            energyCost: energyCost,
          ),
        );
  }

  Future<void> toggleTask(Task task) async {
    final db = _ref.read(databaseProvider);
    final isNowCompleted = !task.isCompleted;

    await (db.update(db.tasks)..where((t) => t.id.equals(task.id))).write(
      TasksCompanion(isCompleted: Value(isNowCompleted)),
    );

    final currentEnergy = _ref.read(energyLevelProvider);
    if (isNowCompleted) {
      if (task.energyCost <= currentEnergy) {
        await _ref.read(pacingStatsProvider.notifier).addXp(20);
      } else {
        // Penalty for overexertion
        await _ref.read(pacingStatsProvider.notifier).deductXp(30);
      }
    } else {
      // Anti-Cheat: Reverse the XP gain if a task is unchecked.
      // We only reverse "Safe Pacing" rewards.
      // Overexertion penalties are permanent to discourage risky behavior.
      if (task.energyCost <= currentEnergy) {
        await _ref.read(pacingStatsProvider.notifier).deductXp(20);
      }
    }
  }

  Future<void> editTask(String id, String title, int energyCost) async {
    final db = _ref.read(databaseProvider);
    await (db.update(db.tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        title: Value(title),
        energyCost: Value(energyCost),
      ),
    );
  }

  Future<void> deleteTask(String id) async {
    final db = _ref.read(databaseProvider);
    await (db.delete(db.tasks)..where((t) => t.id.equals(id))).go();
  }
}
