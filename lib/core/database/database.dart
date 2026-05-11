import 'package:drift/drift.dart';
import 'connection/connection.dart' as impl;

part 'database.g.dart';

class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get title => text().withLength(min: 1, max: 100)();
  IntColumn get energyCost => integer()(); // 1-10 Lightnings
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class EnergyLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get level => integer()(); // 1-10 Lightnings
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();
}

class PacingStats extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get xp => integer().withDefault(const Constant(0))();
  IntColumn get healingLevel => integer().withDefault(const Constant(1))();
  IntColumn get currentStreak => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastLogDate => dateTime().nullable()();
}

@DriftDatabase(tables: [Tasks, EnergyLogs, PacingStats])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(impl.openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          // In development, we can just create the new table
          await m.createTable(pacingStats);
        }
      },
    );
  }
}
