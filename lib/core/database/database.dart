import 'dart:async';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

// ---------------------------------------------------------------------------
// Schema version – increment whenever the on-disk schema changes.
// ---------------------------------------------------------------------------
const kCurrentSchemaVersion = 7;

// ---------------------------------------------------------------------------
// Model classes
// ---------------------------------------------------------------------------

class Task {
  final String id;
  final String title;
  final int requiredEnergy;
  final int priority;
  final int repeatInterval;
  final DateTime? nextAllowedCompletionAt;
  final bool isCompleted;
  final DateTime? updatedAt;
  final DateTime createdAt;

  const Task({
    required this.id,
    required this.title,
    required this.requiredEnergy,
    this.priority = 4,
    this.repeatInterval = 0,
    this.nextAllowedCompletionAt,
    this.isCompleted = false,
    this.updatedAt,
    required this.createdAt,
  });

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String,
      title: map['title'] as String,
      requiredEnergy: (map['required_energy'] ?? map['energy_cost'] ?? 0) as int,
      priority: (map['priority'] as int?) ?? 4,
      repeatInterval: (map['repeat_interval'] as int?) ?? 0,
      nextAllowedCompletionAt: map['next_allowed_completion_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              map['next_allowed_completion_at'] as int)
          : null,
      isCompleted: (map['is_completed'] as int) == 1,
      updatedAt: map['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int)
          : null,
      createdAt:
          DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'required_energy': requiredEnergy,
      'priority': priority,
      'repeat_interval': repeatInterval,
      'next_allowed_completion_at':
          nextAllowedCompletionAt?.millisecondsSinceEpoch,
      'is_completed': isCompleted ? 1 : 0,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  Task copyWith({
    String? id,
    String? title,
    int? requiredEnergy,
    int? priority,
    int? repeatInterval,
    DateTime? nextAllowedCompletionAt,
    bool clearNextAllowedCompletionAt = false,
    bool? isCompleted,
    DateTime? updatedAt,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      requiredEnergy: requiredEnergy ?? this.requiredEnergy,
      priority: priority ?? this.priority,
      repeatInterval: repeatInterval ?? this.repeatInterval,
      nextAllowedCompletionAt: clearNextAllowedCompletionAt
          ? null
          : (nextAllowedCompletionAt ?? this.nextAllowedCompletionAt),
      isCompleted: isCompleted ?? this.isCompleted,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class EnergyLog {
  final int id;
  final String? syncId;
  final int level;
  final DateTime timestamp;
  final DateTime? updatedAt;

  const EnergyLog({
    required this.id,
    this.syncId,
    required this.level,
    required this.timestamp,
    this.updatedAt,
  });

  factory EnergyLog.fromMap(Map<String, dynamic> map) {
    return EnergyLog(
      id: map['id'] as int,
      syncId: map['sync_id'] as String?,
      level: map['level'] as int,
      timestamp:
          DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      updatedAt: map['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sync_id': syncId,
      'level': level,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
    };
  }
}

class PacingStats {
  final int id;
  final int xp;
  final int healingLevel;
  final int currentStreak;
  final DateTime? lastLogDate;
  final DateTime? updatedAt;

  const PacingStats({
    required this.id,
    this.xp = 0,
    this.healingLevel = 1,
    this.currentStreak = 0,
    this.lastLogDate,
    this.updatedAt,
  });

  factory PacingStats.fromMap(Map<String, dynamic> map) {
    return PacingStats(
      id: map['id'] as int,
      xp: map['xp'] as int,
      healingLevel: map['healing_level'] as int,
      currentStreak: map['current_streak'] as int,
      lastLogDate: map['last_log_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['last_log_date'] as int)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'xp': xp,
      'healing_level': healingLevel,
      'current_streak': currentStreak,
      'last_log_date': lastLogDate?.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
    };
  }

  PacingStats copyWith({
    int? xp,
    int? healingLevel,
    int? currentStreak,
    DateTime? lastLogDate,
    DateTime? updatedAt,
  }) {
    return PacingStats(
      id: id,
      xp: xp ?? this.xp,
      healingLevel: healingLevel ?? this.healingLevel,
      currentStreak: currentStreak ?? this.currentStreak,
      lastLogDate: lastLogDate ?? this.lastLogDate,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// ---------------------------------------------------------------------------
// Database
// ---------------------------------------------------------------------------

class AppDatabase {
  static AppDatabase? _instance;
  Database? _db;

  AppDatabase._();

  static AppDatabase get instance {
    _instance ??= AppDatabase._();
    return _instance!;
  }

  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'db.sqlite');

    return openDatabase(
      path,
      version: kCurrentSchemaVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tasks (
            id TEXT NOT NULL PRIMARY KEY,
            title TEXT NOT NULL,
            required_energy INTEGER NOT NULL,
            priority INTEGER NOT NULL DEFAULT 4,
            repeat_interval INTEGER NOT NULL DEFAULT 0,
            next_allowed_completion_at INTEGER,
            is_completed INTEGER NOT NULL DEFAULT 0,
            updated_at INTEGER,
            created_at INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE energy_logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            sync_id TEXT,
            level INTEGER NOT NULL,
            timestamp INTEGER NOT NULL,
            updated_at INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE pacing_stats (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            xp INTEGER NOT NULL DEFAULT 0,
            healing_level INTEGER NOT NULL DEFAULT 1,
            current_streak INTEGER NOT NULL DEFAULT 0,
            last_log_date INTEGER,
            updated_at INTEGER
          )
        ''');
      },
      onUpgrade: (db, from, to) async {
        if (from < 3) {
          // Columns added in schema v3
          await _addColumnIfMissing(db, 'tasks', 'updated_at', 'INTEGER');
          await _addColumnIfMissing(db, 'energy_logs', 'sync_id', 'TEXT');
          await _addColumnIfMissing(db, 'energy_logs', 'updated_at', 'INTEGER');
        }
        if (from < 4) {
          await _addColumnIfMissing(
              db, 'tasks', 'priority', 'INTEGER NOT NULL DEFAULT 4');
        }
        if (from < 5) {
          await _addColumnIfMissing(
              db, 'tasks', 'repeat_interval', 'INTEGER NOT NULL DEFAULT 0');
          await _addColumnIfMissing(
              db, 'tasks', 'next_allowed_completion_at', 'INTEGER');
        }
        if (from < 6) {
          // v6: Dropped PacingStats table (gamification removed) - but we restore it in v7!
          await db.execute('DROP TABLE IF EXISTS pacing_stats');
        }
        if (from < 7) {
          // v7: Restored PacingStats table!
          await db.execute('''
            CREATE TABLE IF NOT EXISTS pacing_stats (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              xp INTEGER NOT NULL DEFAULT 0,
              healing_level INTEGER NOT NULL DEFAULT 1,
              current_streak INTEGER NOT NULL DEFAULT 0,
              last_log_date INTEGER,
              updated_at INTEGER
            )
          ''');
        }
      },
      onOpen: (db) async {
        // Fix potential schema mismatches from broken Drift migrations
        try {
          final info = await db.rawQuery('PRAGMA table_info(tasks)');
          final hasEnergyCost = info.any((row) => row['name'] == 'energy_cost');
          final hasRequiredEnergy = info.any((row) => row['name'] == 'required_energy');
          
          if (hasEnergyCost && !hasRequiredEnergy) {
            await db.execute('ALTER TABLE tasks RENAME COLUMN energy_cost TO required_energy');
          }
        } catch (_) {}
      },
    );
  }

  /// Safely add a column only if it doesn't already exist.
  Future<void> _addColumnIfMissing(
    Database db,
    String table,
    String column,
    String type,
  ) async {
    final info = await db.rawQuery('PRAGMA table_info($table)');
    final exists = info.any((row) => row['name'] == column);
    if (!exists) {
      await db.execute('ALTER TABLE $table ADD COLUMN $column $type');
    }
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
