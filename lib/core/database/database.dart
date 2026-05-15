import 'package:drift/drift.dart';

part 'database.g.dart';

class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get title => text().withLength(min: 1, max: 100)();
  IntColumn get requiredEnergy => integer()(); // 1-10 Lightnings
  IntColumn get priority =>
      integer().withDefault(const Constant(4))(); // 1 (highest) – 4
  /// 0 = off, 1 = daily, 2 = weekly, 3 = monthly
  IntColumn get repeatInterval => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextAllowedCompletionAt => dateTime().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class EnergyLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get syncId => text().nullable()();
  IntColumn get level => integer()(); // 1-10 Lightnings
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
}

class PacingStats extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get xp => integer().withDefault(const Constant(0))();
  IntColumn get healingLevel => integer().withDefault(const Constant(1))();
  IntColumn get currentStreak => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastLogDate => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
}

@DriftDatabase(tables: [Tasks, EnergyLogs, PacingStats])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.createTable(pacingStats);
        }
        if (from < 3) {
          await m.addColumn(tasks, tasks.updatedAt);
          await m.addColumn(energyLogs, energyLogs.syncId);
          await m.addColumn(energyLogs, energyLogs.updatedAt);
          await m.addColumn(pacingStats, pacingStats.updatedAt);
        }
        if (from < 4) {
          await m.addColumn(tasks, tasks.priority);
          await m.database.customStatement(
            'ALTER TABLE tasks ADD COLUMN repeats INTEGER NOT NULL DEFAULT 0 '
            'CHECK (repeats IN (0, 1))',
          );
        }
        if (from < 5) {
          await m.addColumn(tasks, tasks.repeatInterval);
          await m.addColumn(tasks, tasks.nextAllowedCompletionAt);
          await m.database.customStatement(
            'UPDATE tasks SET repeat_interval = CASE WHEN repeats = 1 THEN 1 ELSE 0 END',
          );
          // SQLite doesn't support DROP COLUMN before 3.35.0, recreate table instead
          await _migrateTasksTableDropRepeats(m);
        }
      },
    );
  }

  Future<void> _migrateTasksTableDropRepeats(Migrator m) async {
    // Create new table without the 'repeats' column
    // Using the same column types drift uses: INTEGER for DateTime by default
    // Drift's currentDateAndTime generates (CAST(julianday('now') * 86400000 AS INTEGER))
    await m.database.customStatement('''
      CREATE TABLE tasks_new (
        id TEXT NOT NULL PRIMARY KEY,
        title TEXT NOT NULL CHECK(length(title) >= 1 AND length(title) <= 100),
        energy_cost INTEGER NOT NULL,
        priority INTEGER NOT NULL DEFAULT 4,
        repeat_interval INTEGER NOT NULL DEFAULT 0,
        next_allowed_completion_at INTEGER,
        is_completed INTEGER NOT NULL DEFAULT 0 CHECK (is_completed IN (0, 1)),
        updated_at INTEGER,
        created_at INTEGER NOT NULL DEFAULT (CAST(julianday('now') * 86400000 AS INTEGER))
      )
    ''');
    // Copy data using raw SQL - SQLite will handle type conversion
    await m.database.customStatement('''
      INSERT INTO tasks_new (id, title, energy_cost, priority, repeat_interval, next_allowed_completion_at, is_completed, updated_at, created_at)
      SELECT id, title, energy_cost, priority, repeat_interval, next_allowed_completion_at, is_completed, updated_at, created_at FROM tasks
    ''');
    // Drop old table and rename new one
    await m.database.customStatement('DROP TABLE tasks');
    await m.database.customStatement('ALTER TABLE tasks_new RENAME TO tasks');
  }
}
