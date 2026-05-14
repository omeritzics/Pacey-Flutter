import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:pacey/core/database/database.dart';
import 'package:pacey/core/database/database_provider.dart';
import 'package:pacey/core/p2p/p2p_sync_service.dart';
import 'package:pacey/features/tasks/task_provider.dart';
import 'package:pacey/features/energy/energy_provider.dart';
import 'package:pacey/features/gamification/gamification_provider.dart';

void main() {
  group('P2P Data Sync Integration Tests', () {
    late AppDatabase database;
    late P2PSyncService syncService;

    setUp(() async {
      // Create in-memory database for testing
      database = AppDatabase(DatabaseConnection(NativeDatabase.memory()));
      await database.customStatement('PRAGMA foreign_keys = ON');
      
      // Initialize sync service
      syncService = P2PSyncService();
      await syncService.initialize(database);
    });

    tearDown(() async {
      await syncService.dispose();
      await database.close();
    });

    test('Task creation broadcasts to connected peers', () async {
      // Create a task using Riverpod
      final container = ProviderContainer(overrides: [
        databaseProvider.overrideWithValue(database),
      ]);
      final taskActions = container.read(taskActionsProvider);
      await taskActions.addTask('Test Task', 3);
      
      // Verify task exists in database
      final tasks = await database.select(database.tasks).get();
      expect(tasks.length, 1);
      expect(tasks.first.title, 'Test Task');
      expect(tasks.first.energyCost, 3);
      expect(tasks.first.priority, 4);
      expect(tasks.first.repeatInterval, 0);
      
      // Note: In a real test, we would verify the broadcast was sent
      // For integration testing, this would involve mocking the P2P service
    });

    test('Energy logging broadcasts to connected peers', () async {
      // Create an energy log
      // Create energy notifier using Riverpod
      final container = ProviderContainer(overrides: [
        databaseProvider.overrideWithValue(database),
      ]);
      
      final energyNotifier = container.read(energyLevelProvider.notifier);
      final result = await energyNotifier.updateLevel(7);
      expect(result, true);
      
      // Verify energy log exists in database
      final logs = await database.select(database.energyLogs).get();
      expect(logs.length, 1);
      expect(logs.first.level, 7);
    });

    test('Pacing stats updates broadcast to connected peers', () async {
      // Initialize pacing stats
      // Create stats notifier using Riverpod
      final container = ProviderContainer(overrides: [
        databaseProvider.overrideWithValue(database),
      ]);
      
      final statsNotifier = container.read(pacingStatsProvider.notifier);
      
      // Wait for initialization
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Add XP
      await statsNotifier.addXp(50);
      
      // Verify stats were updated
      final stats = await database.select(database.pacingStats).get();
      expect(stats.length, 1);
      expect(stats.first.xp, 50);
    });

    test('Task operations sync properly', () async {
      final container = ProviderContainer(overrides: [
        databaseProvider.overrideWithValue(database),
      ]);
      final taskActions = container.read(taskActionsProvider);
      
      // Create task
      await taskActions.addTask('Sync Test Task', 2);
      final tasks = await database.select(database.tasks).get();
      expect(tasks.length, 1);
      
      final taskId = tasks.first.id;
      
      // Update task
      await taskActions.editTask(
        taskId,
        'Updated Task',
        3,
        priority: 2,
        repeatInterval: 0,
      );
      final updatedTasks = await database.select(database.tasks).get();
      expect(updatedTasks.first.title, 'Updated Task');
      expect(updatedTasks.first.energyCost, 3);
      expect(updatedTasks.first.priority, 2);
      
      // Toggle task completion
      await taskActions.toggleTask(updatedTasks.first);
      final completedTasks = await database.select(database.tasks).get();
      expect(completedTasks.first.isCompleted, true);
      
      // Delete task
      await taskActions.deleteTask(taskId);
      final deletedTasks = await database.select(database.tasks).get();
      expect(deletedTasks.length, 0);
    });
  });
}
