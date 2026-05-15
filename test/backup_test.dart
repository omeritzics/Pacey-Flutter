import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pacey/core/backup/backup_service.dart';
import 'package:pacey/core/database/database.dart';

void main() {
  late AppDatabase db;
  late BackupService backupService;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    backupService = BackupService();
  });

  tearDown(() async {
    await db.close();
  });

  test('export and merge import round-trip', () async {
    final now = DateTime.now();
    await db.into(db.tasks).insert(
      TasksCompanion.insert(
        id: 'task-1',
        title: 'Walk',
        requiredEnergy: 3,
        updatedAt: Value(now),
      ),
    );
    await db.into(db.energyLogs).insert(
      EnergyLogsCompanion.insert(
        syncId: const Value('log-1'),
        level: 5,
        timestamp: Value(now),
        updatedAt: Value(now),
      ),
    );
    await db.into(db.pacingStats).insert(
      PacingStatsCompanion.insert(
        xp: const Value(100),
        healingLevel: const Value(1),
        currentStreak: const Value(2),
        updatedAt: Value(now),
      ),
    );

    final exported = await backupService.exportData(db);
    expect(exported, contains('"app": "pacey"'));

    await db.delete(db.tasks).go();
    await db.delete(db.energyLogs).go();
    await db.delete(db.pacingStats).go();

    final result = await backupService.importData(
      db,
      exported,
      mode: ImportMode.replace,
    );

    expect(result.tasksImported, 1);
    expect(result.energyLogsImported, 1);
    expect(result.pacingStatsImported, isTrue);

    final tasks = await db.select(db.tasks).get();
    expect(tasks, hasLength(1));
    expect(tasks.first.title, 'Walk');
  });

  test('merge keeps newer local task', () async {
    final older = DateTime(2024, 1, 1);
    final newer = DateTime(2025, 1, 1);

    await db.into(db.tasks).insert(
      TasksCompanion.insert(
        id: 'task-1',
        title: 'Local title',
        requiredEnergy: 3,
        updatedAt: Value(newer),
      ),
    );

    final backup = '''
{
  "version": 1,
  "app": "pacey",
  "exportedAt": "2026-01-01T00:00:00.000Z",
  "tasks": [
    {
      "id": "task-1",
      "title": "Remote title",
      "requiredEnergy": 5,
      "priority": 4,
      "repeatInterval": 0,
      "isCompleted": false,
      "createdAt": "${older.toIso8601String()}",
      "updatedAt": "${older.toIso8601String()}"
    }
  ],
  "energyLogs": [],
  "pacingStats": null
}
''';

    final result = await backupService.importData(
      db,
      backup,
      mode: ImportMode.merge,
    );

    expect(result.tasksImported, 0);
    final task = await (db.select(db.tasks)
          ..where((t) => t.id.equals('task-1')))
        .getSingle();
    expect(task.title, 'Local title');
  });

  test('rejects invalid backup', () async {
    expect(
      () => backupService.importData(db, '{}', mode: ImportMode.merge),
      throwsA(isA<BackupException>()),
    );
  });
}
