// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $TasksTable extends Tasks with TableInfo<$TasksTable, Task> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _energyCostMeta = const VerificationMeta(
    'energyCost',
  );
  @override
  late final GeneratedColumn<int> energyCost = GeneratedColumn<int>(
    'energy_cost',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    energyCost,
    isCompleted,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Task> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('energy_cost')) {
      context.handle(
        _energyCostMeta,
        energyCost.isAcceptableOrUnknown(data['energy_cost']!, _energyCostMeta),
      );
    } else if (isInserting) {
      context.missing(_energyCostMeta);
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Task map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Task(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      energyCost: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}energy_cost'],
      )!,
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class Task extends DataClass implements Insertable<Task> {
  final String id;
  final String title;
  final int energyCost;
  final bool isCompleted;
  final DateTime createdAt;
  const Task({
    required this.id,
    required this.title,
    required this.energyCost,
    required this.isCompleted,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['energy_cost'] = Variable<int>(energyCost);
    map['is_completed'] = Variable<bool>(isCompleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      title: Value(title),
      energyCost: Value(energyCost),
      isCompleted: Value(isCompleted),
      createdAt: Value(createdAt),
    );
  }

  factory Task.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Task(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      energyCost: serializer.fromJson<int>(json['energyCost']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'energyCost': serializer.toJson<int>(energyCost),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Task copyWith({
    String? id,
    String? title,
    int? energyCost,
    bool? isCompleted,
    DateTime? createdAt,
  }) => Task(
    id: id ?? this.id,
    title: title ?? this.title,
    energyCost: energyCost ?? this.energyCost,
    isCompleted: isCompleted ?? this.isCompleted,
    createdAt: createdAt ?? this.createdAt,
  );
  Task copyWithCompanion(TasksCompanion data) {
    return Task(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      energyCost: data.energyCost.present
          ? data.energyCost.value
          : this.energyCost,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Task(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('energyCost: $energyCost, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, energyCost, isCompleted, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          other.id == this.id &&
          other.title == this.title &&
          other.energyCost == this.energyCost &&
          other.isCompleted == this.isCompleted &&
          other.createdAt == this.createdAt);
}

class TasksCompanion extends UpdateCompanion<Task> {
  final Value<String> id;
  final Value<String> title;
  final Value<int> energyCost;
  final Value<bool> isCompleted;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.energyCost = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TasksCompanion.insert({
    required String id,
    required String title,
    required int energyCost,
    this.isCompleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       energyCost = Value(energyCost);
  static Insertable<Task> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<int>? energyCost,
    Expression<bool>? isCompleted,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (energyCost != null) 'energy_cost': energyCost,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TasksCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<int>? energyCost,
    Value<bool>? isCompleted,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return TasksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      energyCost: energyCost ?? this.energyCost,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (energyCost.present) {
      map['energy_cost'] = Variable<int>(energyCost.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('energyCost: $energyCost, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EnergyLogsTable extends EnergyLogs
    with TableInfo<$EnergyLogsTable, EnergyLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EnergyLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, level, timestamp];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'energy_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<EnergyLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EnergyLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EnergyLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
    );
  }

  @override
  $EnergyLogsTable createAlias(String alias) {
    return $EnergyLogsTable(attachedDatabase, alias);
  }
}

class EnergyLog extends DataClass implements Insertable<EnergyLog> {
  final int id;
  final int level;
  final DateTime timestamp;
  const EnergyLog({
    required this.id,
    required this.level,
    required this.timestamp,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['level'] = Variable<int>(level);
    map['timestamp'] = Variable<DateTime>(timestamp);
    return map;
  }

  EnergyLogsCompanion toCompanion(bool nullToAbsent) {
    return EnergyLogsCompanion(
      id: Value(id),
      level: Value(level),
      timestamp: Value(timestamp),
    );
  }

  factory EnergyLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EnergyLog(
      id: serializer.fromJson<int>(json['id']),
      level: serializer.fromJson<int>(json['level']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'level': serializer.toJson<int>(level),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  EnergyLog copyWith({int? id, int? level, DateTime? timestamp}) => EnergyLog(
    id: id ?? this.id,
    level: level ?? this.level,
    timestamp: timestamp ?? this.timestamp,
  );
  EnergyLog copyWithCompanion(EnergyLogsCompanion data) {
    return EnergyLog(
      id: data.id.present ? data.id.value : this.id,
      level: data.level.present ? data.level.value : this.level,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EnergyLog(')
          ..write('id: $id, ')
          ..write('level: $level, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, level, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EnergyLog &&
          other.id == this.id &&
          other.level == this.level &&
          other.timestamp == this.timestamp);
}

class EnergyLogsCompanion extends UpdateCompanion<EnergyLog> {
  final Value<int> id;
  final Value<int> level;
  final Value<DateTime> timestamp;
  const EnergyLogsCompanion({
    this.id = const Value.absent(),
    this.level = const Value.absent(),
    this.timestamp = const Value.absent(),
  });
  EnergyLogsCompanion.insert({
    this.id = const Value.absent(),
    required int level,
    this.timestamp = const Value.absent(),
  }) : level = Value(level);
  static Insertable<EnergyLog> custom({
    Expression<int>? id,
    Expression<int>? level,
    Expression<DateTime>? timestamp,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (level != null) 'level': level,
      if (timestamp != null) 'timestamp': timestamp,
    });
  }

  EnergyLogsCompanion copyWith({
    Value<int>? id,
    Value<int>? level,
    Value<DateTime>? timestamp,
  }) {
    return EnergyLogsCompanion(
      id: id ?? this.id,
      level: level ?? this.level,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EnergyLogsCompanion(')
          ..write('id: $id, ')
          ..write('level: $level, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }
}

class $PacingStatsTable extends PacingStats
    with TableInfo<$PacingStatsTable, PacingStat> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PacingStatsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _xpMeta = const VerificationMeta('xp');
  @override
  late final GeneratedColumn<int> xp = GeneratedColumn<int>(
    'xp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _healingLevelMeta = const VerificationMeta(
    'healingLevel',
  );
  @override
  late final GeneratedColumn<int> healingLevel = GeneratedColumn<int>(
    'healing_level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _currentStreakMeta = const VerificationMeta(
    'currentStreak',
  );
  @override
  late final GeneratedColumn<int> currentStreak = GeneratedColumn<int>(
    'current_streak',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastLogDateMeta = const VerificationMeta(
    'lastLogDate',
  );
  @override
  late final GeneratedColumn<DateTime> lastLogDate = GeneratedColumn<DateTime>(
    'last_log_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    xp,
    healingLevel,
    currentStreak,
    lastLogDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pacing_stats';
  @override
  VerificationContext validateIntegrity(
    Insertable<PacingStat> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('xp')) {
      context.handle(_xpMeta, xp.isAcceptableOrUnknown(data['xp']!, _xpMeta));
    }
    if (data.containsKey('healing_level')) {
      context.handle(
        _healingLevelMeta,
        healingLevel.isAcceptableOrUnknown(
          data['healing_level']!,
          _healingLevelMeta,
        ),
      );
    }
    if (data.containsKey('current_streak')) {
      context.handle(
        _currentStreakMeta,
        currentStreak.isAcceptableOrUnknown(
          data['current_streak']!,
          _currentStreakMeta,
        ),
      );
    }
    if (data.containsKey('last_log_date')) {
      context.handle(
        _lastLogDateMeta,
        lastLogDate.isAcceptableOrUnknown(
          data['last_log_date']!,
          _lastLogDateMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PacingStat map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PacingStat(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      xp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}xp'],
      )!,
      healingLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}healing_level'],
      )!,
      currentStreak: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_streak'],
      )!,
      lastLogDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_log_date'],
      ),
    );
  }

  @override
  $PacingStatsTable createAlias(String alias) {
    return $PacingStatsTable(attachedDatabase, alias);
  }
}

class PacingStat extends DataClass implements Insertable<PacingStat> {
  final int id;
  final int xp;
  final int healingLevel;
  final int currentStreak;
  final DateTime? lastLogDate;
  const PacingStat({
    required this.id,
    required this.xp,
    required this.healingLevel,
    required this.currentStreak,
    this.lastLogDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['xp'] = Variable<int>(xp);
    map['healing_level'] = Variable<int>(healingLevel);
    map['current_streak'] = Variable<int>(currentStreak);
    if (!nullToAbsent || lastLogDate != null) {
      map['last_log_date'] = Variable<DateTime>(lastLogDate);
    }
    return map;
  }

  PacingStatsCompanion toCompanion(bool nullToAbsent) {
    return PacingStatsCompanion(
      id: Value(id),
      xp: Value(xp),
      healingLevel: Value(healingLevel),
      currentStreak: Value(currentStreak),
      lastLogDate: lastLogDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastLogDate),
    );
  }

  factory PacingStat.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PacingStat(
      id: serializer.fromJson<int>(json['id']),
      xp: serializer.fromJson<int>(json['xp']),
      healingLevel: serializer.fromJson<int>(json['healingLevel']),
      currentStreak: serializer.fromJson<int>(json['currentStreak']),
      lastLogDate: serializer.fromJson<DateTime?>(json['lastLogDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'xp': serializer.toJson<int>(xp),
      'healingLevel': serializer.toJson<int>(healingLevel),
      'currentStreak': serializer.toJson<int>(currentStreak),
      'lastLogDate': serializer.toJson<DateTime?>(lastLogDate),
    };
  }

  PacingStat copyWith({
    int? id,
    int? xp,
    int? healingLevel,
    int? currentStreak,
    Value<DateTime?> lastLogDate = const Value.absent(),
  }) => PacingStat(
    id: id ?? this.id,
    xp: xp ?? this.xp,
    healingLevel: healingLevel ?? this.healingLevel,
    currentStreak: currentStreak ?? this.currentStreak,
    lastLogDate: lastLogDate.present ? lastLogDate.value : this.lastLogDate,
  );
  PacingStat copyWithCompanion(PacingStatsCompanion data) {
    return PacingStat(
      id: data.id.present ? data.id.value : this.id,
      xp: data.xp.present ? data.xp.value : this.xp,
      healingLevel: data.healingLevel.present
          ? data.healingLevel.value
          : this.healingLevel,
      currentStreak: data.currentStreak.present
          ? data.currentStreak.value
          : this.currentStreak,
      lastLogDate: data.lastLogDate.present
          ? data.lastLogDate.value
          : this.lastLogDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PacingStat(')
          ..write('id: $id, ')
          ..write('xp: $xp, ')
          ..write('healingLevel: $healingLevel, ')
          ..write('currentStreak: $currentStreak, ')
          ..write('lastLogDate: $lastLogDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, xp, healingLevel, currentStreak, lastLogDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PacingStat &&
          other.id == this.id &&
          other.xp == this.xp &&
          other.healingLevel == this.healingLevel &&
          other.currentStreak == this.currentStreak &&
          other.lastLogDate == this.lastLogDate);
}

class PacingStatsCompanion extends UpdateCompanion<PacingStat> {
  final Value<int> id;
  final Value<int> xp;
  final Value<int> healingLevel;
  final Value<int> currentStreak;
  final Value<DateTime?> lastLogDate;
  const PacingStatsCompanion({
    this.id = const Value.absent(),
    this.xp = const Value.absent(),
    this.healingLevel = const Value.absent(),
    this.currentStreak = const Value.absent(),
    this.lastLogDate = const Value.absent(),
  });
  PacingStatsCompanion.insert({
    this.id = const Value.absent(),
    this.xp = const Value.absent(),
    this.healingLevel = const Value.absent(),
    this.currentStreak = const Value.absent(),
    this.lastLogDate = const Value.absent(),
  });
  static Insertable<PacingStat> custom({
    Expression<int>? id,
    Expression<int>? xp,
    Expression<int>? healingLevel,
    Expression<int>? currentStreak,
    Expression<DateTime>? lastLogDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (xp != null) 'xp': xp,
      if (healingLevel != null) 'healing_level': healingLevel,
      if (currentStreak != null) 'current_streak': currentStreak,
      if (lastLogDate != null) 'last_log_date': lastLogDate,
    });
  }

  PacingStatsCompanion copyWith({
    Value<int>? id,
    Value<int>? xp,
    Value<int>? healingLevel,
    Value<int>? currentStreak,
    Value<DateTime?>? lastLogDate,
  }) {
    return PacingStatsCompanion(
      id: id ?? this.id,
      xp: xp ?? this.xp,
      healingLevel: healingLevel ?? this.healingLevel,
      currentStreak: currentStreak ?? this.currentStreak,
      lastLogDate: lastLogDate ?? this.lastLogDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (xp.present) {
      map['xp'] = Variable<int>(xp.value);
    }
    if (healingLevel.present) {
      map['healing_level'] = Variable<int>(healingLevel.value);
    }
    if (currentStreak.present) {
      map['current_streak'] = Variable<int>(currentStreak.value);
    }
    if (lastLogDate.present) {
      map['last_log_date'] = Variable<DateTime>(lastLogDate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PacingStatsCompanion(')
          ..write('id: $id, ')
          ..write('xp: $xp, ')
          ..write('healingLevel: $healingLevel, ')
          ..write('currentStreak: $currentStreak, ')
          ..write('lastLogDate: $lastLogDate')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $EnergyLogsTable energyLogs = $EnergyLogsTable(this);
  late final $PacingStatsTable pacingStats = $PacingStatsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    tasks,
    energyLogs,
    pacingStats,
  ];
}

typedef $$TasksTableCreateCompanionBuilder =
    TasksCompanion Function({
      required String id,
      required String title,
      required int energyCost,
      Value<bool> isCompleted,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$TasksTableUpdateCompanionBuilder =
    TasksCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<int> energyCost,
      Value<bool> isCompleted,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get energyCost => $composableBuilder(
    column: $table.energyCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get energyCost => $composableBuilder(
    column: $table.energyCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get energyCost => $composableBuilder(
    column: $table.energyCost,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$TasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasksTable,
          Task,
          $$TasksTableFilterComposer,
          $$TasksTableOrderingComposer,
          $$TasksTableAnnotationComposer,
          $$TasksTableCreateCompanionBuilder,
          $$TasksTableUpdateCompanionBuilder,
          (Task, BaseReferences<_$AppDatabase, $TasksTable, Task>),
          Task,
          PrefetchHooks Function()
        > {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> energyCost = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion(
                id: id,
                title: title,
                energyCost: energyCost,
                isCompleted: isCompleted,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required int energyCost,
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion.insert(
                id: id,
                title: title,
                energyCost: energyCost,
                isCompleted: isCompleted,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasksTable,
      Task,
      $$TasksTableFilterComposer,
      $$TasksTableOrderingComposer,
      $$TasksTableAnnotationComposer,
      $$TasksTableCreateCompanionBuilder,
      $$TasksTableUpdateCompanionBuilder,
      (Task, BaseReferences<_$AppDatabase, $TasksTable, Task>),
      Task,
      PrefetchHooks Function()
    >;
typedef $$EnergyLogsTableCreateCompanionBuilder =
    EnergyLogsCompanion Function({
      Value<int> id,
      required int level,
      Value<DateTime> timestamp,
    });
typedef $$EnergyLogsTableUpdateCompanionBuilder =
    EnergyLogsCompanion Function({
      Value<int> id,
      Value<int> level,
      Value<DateTime> timestamp,
    });

class $$EnergyLogsTableFilterComposer
    extends Composer<_$AppDatabase, $EnergyLogsTable> {
  $$EnergyLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EnergyLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $EnergyLogsTable> {
  $$EnergyLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EnergyLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EnergyLogsTable> {
  $$EnergyLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);
}

class $$EnergyLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EnergyLogsTable,
          EnergyLog,
          $$EnergyLogsTableFilterComposer,
          $$EnergyLogsTableOrderingComposer,
          $$EnergyLogsTableAnnotationComposer,
          $$EnergyLogsTableCreateCompanionBuilder,
          $$EnergyLogsTableUpdateCompanionBuilder,
          (
            EnergyLog,
            BaseReferences<_$AppDatabase, $EnergyLogsTable, EnergyLog>,
          ),
          EnergyLog,
          PrefetchHooks Function()
        > {
  $$EnergyLogsTableTableManager(_$AppDatabase db, $EnergyLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EnergyLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EnergyLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EnergyLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> level = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
              }) => EnergyLogsCompanion(
                id: id,
                level: level,
                timestamp: timestamp,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int level,
                Value<DateTime> timestamp = const Value.absent(),
              }) => EnergyLogsCompanion.insert(
                id: id,
                level: level,
                timestamp: timestamp,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EnergyLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EnergyLogsTable,
      EnergyLog,
      $$EnergyLogsTableFilterComposer,
      $$EnergyLogsTableOrderingComposer,
      $$EnergyLogsTableAnnotationComposer,
      $$EnergyLogsTableCreateCompanionBuilder,
      $$EnergyLogsTableUpdateCompanionBuilder,
      (EnergyLog, BaseReferences<_$AppDatabase, $EnergyLogsTable, EnergyLog>),
      EnergyLog,
      PrefetchHooks Function()
    >;
typedef $$PacingStatsTableCreateCompanionBuilder =
    PacingStatsCompanion Function({
      Value<int> id,
      Value<int> xp,
      Value<int> healingLevel,
      Value<int> currentStreak,
      Value<DateTime?> lastLogDate,
    });
typedef $$PacingStatsTableUpdateCompanionBuilder =
    PacingStatsCompanion Function({
      Value<int> id,
      Value<int> xp,
      Value<int> healingLevel,
      Value<int> currentStreak,
      Value<DateTime?> lastLogDate,
    });

class $$PacingStatsTableFilterComposer
    extends Composer<_$AppDatabase, $PacingStatsTable> {
  $$PacingStatsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get xp => $composableBuilder(
    column: $table.xp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get healingLevel => $composableBuilder(
    column: $table.healingLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentStreak => $composableBuilder(
    column: $table.currentStreak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastLogDate => $composableBuilder(
    column: $table.lastLogDate,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PacingStatsTableOrderingComposer
    extends Composer<_$AppDatabase, $PacingStatsTable> {
  $$PacingStatsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get xp => $composableBuilder(
    column: $table.xp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get healingLevel => $composableBuilder(
    column: $table.healingLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentStreak => $composableBuilder(
    column: $table.currentStreak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastLogDate => $composableBuilder(
    column: $table.lastLogDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PacingStatsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PacingStatsTable> {
  $$PacingStatsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get xp =>
      $composableBuilder(column: $table.xp, builder: (column) => column);

  GeneratedColumn<int> get healingLevel => $composableBuilder(
    column: $table.healingLevel,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentStreak => $composableBuilder(
    column: $table.currentStreak,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastLogDate => $composableBuilder(
    column: $table.lastLogDate,
    builder: (column) => column,
  );
}

class $$PacingStatsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PacingStatsTable,
          PacingStat,
          $$PacingStatsTableFilterComposer,
          $$PacingStatsTableOrderingComposer,
          $$PacingStatsTableAnnotationComposer,
          $$PacingStatsTableCreateCompanionBuilder,
          $$PacingStatsTableUpdateCompanionBuilder,
          (
            PacingStat,
            BaseReferences<_$AppDatabase, $PacingStatsTable, PacingStat>,
          ),
          PacingStat,
          PrefetchHooks Function()
        > {
  $$PacingStatsTableTableManager(_$AppDatabase db, $PacingStatsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PacingStatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PacingStatsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PacingStatsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> xp = const Value.absent(),
                Value<int> healingLevel = const Value.absent(),
                Value<int> currentStreak = const Value.absent(),
                Value<DateTime?> lastLogDate = const Value.absent(),
              }) => PacingStatsCompanion(
                id: id,
                xp: xp,
                healingLevel: healingLevel,
                currentStreak: currentStreak,
                lastLogDate: lastLogDate,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> xp = const Value.absent(),
                Value<int> healingLevel = const Value.absent(),
                Value<int> currentStreak = const Value.absent(),
                Value<DateTime?> lastLogDate = const Value.absent(),
              }) => PacingStatsCompanion.insert(
                id: id,
                xp: xp,
                healingLevel: healingLevel,
                currentStreak: currentStreak,
                lastLogDate: lastLogDate,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PacingStatsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PacingStatsTable,
      PacingStat,
      $$PacingStatsTableFilterComposer,
      $$PacingStatsTableOrderingComposer,
      $$PacingStatsTableAnnotationComposer,
      $$PacingStatsTableCreateCompanionBuilder,
      $$PacingStatsTableUpdateCompanionBuilder,
      (
        PacingStat,
        BaseReferences<_$AppDatabase, $PacingStatsTable, PacingStat>,
      ),
      PacingStat,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$EnergyLogsTableTableManager get energyLogs =>
      $$EnergyLogsTableTableManager(_db, _db.energyLogs);
  $$PacingStatsTableTableManager get pacingStats =>
      $$PacingStatsTableTableManager(_db, _db.pacingStats);
}
