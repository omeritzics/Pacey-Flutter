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
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(4),
  );
  static const VerificationMeta _repeatIntervalMeta = const VerificationMeta(
    'repeatInterval',
  );
  @override
  late final GeneratedColumn<int> repeatInterval = GeneratedColumn<int>(
    'repeat_interval',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nextAllowedCompletionAtMeta =
      const VerificationMeta('nextAllowedCompletionAt');
  @override
  late final GeneratedColumn<DateTime> nextAllowedCompletionAt =
      GeneratedColumn<DateTime>(
        'next_allowed_completion_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
    priority,
    repeatInterval,
    nextAllowedCompletionAt,
    isCompleted,
    updatedAt,
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
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('repeat_interval')) {
      context.handle(
        _repeatIntervalMeta,
        repeatInterval.isAcceptableOrUnknown(
          data['repeat_interval']!,
          _repeatIntervalMeta,
        ),
      );
    }
    if (data.containsKey('next_allowed_completion_at')) {
      context.handle(
        _nextAllowedCompletionAtMeta,
        nextAllowedCompletionAt.isAcceptableOrUnknown(
          data['next_allowed_completion_at']!,
          _nextAllowedCompletionAtMeta,
        ),
      );
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
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
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
      repeatInterval: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}repeat_interval'],
      )!,
      nextAllowedCompletionAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_allowed_completion_at'],
      ),
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
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
  final int priority;

  /// 0 = off, 1 = daily, 2 = weekly, 3 = monthly
  final int repeatInterval;
  final DateTime? nextAllowedCompletionAt;
  final bool isCompleted;
  final DateTime? updatedAt;
  final DateTime createdAt;
  const Task({
    required this.id,
    required this.title,
    required this.energyCost,
    required this.priority,
    required this.repeatInterval,
    this.nextAllowedCompletionAt,
    required this.isCompleted,
    this.updatedAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['energy_cost'] = Variable<int>(energyCost);
    map['priority'] = Variable<int>(priority);
    map['repeat_interval'] = Variable<int>(repeatInterval);
    if (!nullToAbsent || nextAllowedCompletionAt != null) {
      map['next_allowed_completion_at'] = Variable<DateTime>(
        nextAllowedCompletionAt,
      );
    }
    map['is_completed'] = Variable<bool>(isCompleted);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      title: Value(title),
      energyCost: Value(energyCost),
      priority: Value(priority),
      repeatInterval: Value(repeatInterval),
      nextAllowedCompletionAt: nextAllowedCompletionAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextAllowedCompletionAt),
      isCompleted: Value(isCompleted),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
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
      priority: serializer.fromJson<int>(json['priority']),
      repeatInterval: serializer.fromJson<int>(json['repeatInterval']),
      nextAllowedCompletionAt: serializer.fromJson<DateTime?>(
        json['nextAllowedCompletionAt'],
      ),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
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
      'priority': serializer.toJson<int>(priority),
      'repeatInterval': serializer.toJson<int>(repeatInterval),
      'nextAllowedCompletionAt': serializer.toJson<DateTime?>(
        nextAllowedCompletionAt,
      ),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Task copyWith({
    String? id,
    String? title,
    int? energyCost,
    int? priority,
    int? repeatInterval,
    Value<DateTime?> nextAllowedCompletionAt = const Value.absent(),
    bool? isCompleted,
    Value<DateTime?> updatedAt = const Value.absent(),
    DateTime? createdAt,
  }) => Task(
    id: id ?? this.id,
    title: title ?? this.title,
    energyCost: energyCost ?? this.energyCost,
    priority: priority ?? this.priority,
    repeatInterval: repeatInterval ?? this.repeatInterval,
    nextAllowedCompletionAt: nextAllowedCompletionAt.present
        ? nextAllowedCompletionAt.value
        : this.nextAllowedCompletionAt,
    isCompleted: isCompleted ?? this.isCompleted,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    createdAt: createdAt ?? this.createdAt,
  );
  Task copyWithCompanion(TasksCompanion data) {
    return Task(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      energyCost: data.energyCost.present
          ? data.energyCost.value
          : this.energyCost,
      priority: data.priority.present ? data.priority.value : this.priority,
      repeatInterval: data.repeatInterval.present
          ? data.repeatInterval.value
          : this.repeatInterval,
      nextAllowedCompletionAt: data.nextAllowedCompletionAt.present
          ? data.nextAllowedCompletionAt.value
          : this.nextAllowedCompletionAt,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Task(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('energyCost: $energyCost, ')
          ..write('priority: $priority, ')
          ..write('repeatInterval: $repeatInterval, ')
          ..write('nextAllowedCompletionAt: $nextAllowedCompletionAt, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    energyCost,
    priority,
    repeatInterval,
    nextAllowedCompletionAt,
    isCompleted,
    updatedAt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          other.id == this.id &&
          other.title == this.title &&
          other.energyCost == this.energyCost &&
          other.priority == this.priority &&
          other.repeatInterval == this.repeatInterval &&
          other.nextAllowedCompletionAt == this.nextAllowedCompletionAt &&
          other.isCompleted == this.isCompleted &&
          other.updatedAt == this.updatedAt &&
          other.createdAt == this.createdAt);
}

class TasksCompanion extends UpdateCompanion<Task> {
  final Value<String> id;
  final Value<String> title;
  final Value<int> energyCost;
  final Value<int> priority;
  final Value<int> repeatInterval;
  final Value<DateTime?> nextAllowedCompletionAt;
  final Value<bool> isCompleted;
  final Value<DateTime?> updatedAt;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.energyCost = const Value.absent(),
    this.priority = const Value.absent(),
    this.repeatInterval = const Value.absent(),
    this.nextAllowedCompletionAt = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TasksCompanion.insert({
    required String id,
    required String title,
    required int energyCost,
    this.priority = const Value.absent(),
    this.repeatInterval = const Value.absent(),
    this.nextAllowedCompletionAt = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       energyCost = Value(energyCost);
  static Insertable<Task> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<int>? energyCost,
    Expression<int>? priority,
    Expression<int>? repeatInterval,
    Expression<DateTime>? nextAllowedCompletionAt,
    Expression<bool>? isCompleted,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (energyCost != null) 'energy_cost': energyCost,
      if (priority != null) 'priority': priority,
      if (repeatInterval != null) 'repeat_interval': repeatInterval,
      if (nextAllowedCompletionAt != null)
        'next_allowed_completion_at': nextAllowedCompletionAt,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TasksCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<int>? energyCost,
    Value<int>? priority,
    Value<int>? repeatInterval,
    Value<DateTime?>? nextAllowedCompletionAt,
    Value<bool>? isCompleted,
    Value<DateTime?>? updatedAt,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return TasksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      energyCost: energyCost ?? this.energyCost,
      priority: priority ?? this.priority,
      repeatInterval: repeatInterval ?? this.repeatInterval,
      nextAllowedCompletionAt:
          nextAllowedCompletionAt ?? this.nextAllowedCompletionAt,
      isCompleted: isCompleted ?? this.isCompleted,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (repeatInterval.present) {
      map['repeat_interval'] = Variable<int>(repeatInterval.value);
    }
    if (nextAllowedCompletionAt.present) {
      map['next_allowed_completion_at'] = Variable<DateTime>(
        nextAllowedCompletionAt.value,
      );
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
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
          ..write('priority: $priority, ')
          ..write('repeatInterval: $repeatInterval, ')
          ..write('nextAllowedCompletionAt: $nextAllowedCompletionAt, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('updatedAt: $updatedAt, ')
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
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'sync_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    syncId,
    level,
    timestamp,
    updatedAt,
  ];
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
    if (data.containsKey('sync_id')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta),
      );
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
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
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_id'],
      ),
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $EnergyLogsTable createAlias(String alias) {
    return $EnergyLogsTable(attachedDatabase, alias);
  }
}

class EnergyLog extends DataClass implements Insertable<EnergyLog> {
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
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || syncId != null) {
      map['sync_id'] = Variable<String>(syncId);
    }
    map['level'] = Variable<int>(level);
    map['timestamp'] = Variable<DateTime>(timestamp);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  EnergyLogsCompanion toCompanion(bool nullToAbsent) {
    return EnergyLogsCompanion(
      id: Value(id),
      syncId: syncId == null && nullToAbsent
          ? const Value.absent()
          : Value(syncId),
      level: Value(level),
      timestamp: Value(timestamp),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory EnergyLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EnergyLog(
      id: serializer.fromJson<int>(json['id']),
      syncId: serializer.fromJson<String?>(json['syncId']),
      level: serializer.fromJson<int>(json['level']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'syncId': serializer.toJson<String?>(syncId),
      'level': serializer.toJson<int>(level),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  EnergyLog copyWith({
    int? id,
    Value<String?> syncId = const Value.absent(),
    int? level,
    DateTime? timestamp,
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => EnergyLog(
    id: id ?? this.id,
    syncId: syncId.present ? syncId.value : this.syncId,
    level: level ?? this.level,
    timestamp: timestamp ?? this.timestamp,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  EnergyLog copyWithCompanion(EnergyLogsCompanion data) {
    return EnergyLog(
      id: data.id.present ? data.id.value : this.id,
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      level: data.level.present ? data.level.value : this.level,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EnergyLog(')
          ..write('id: $id, ')
          ..write('syncId: $syncId, ')
          ..write('level: $level, ')
          ..write('timestamp: $timestamp, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, syncId, level, timestamp, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EnergyLog &&
          other.id == this.id &&
          other.syncId == this.syncId &&
          other.level == this.level &&
          other.timestamp == this.timestamp &&
          other.updatedAt == this.updatedAt);
}

class EnergyLogsCompanion extends UpdateCompanion<EnergyLog> {
  final Value<int> id;
  final Value<String?> syncId;
  final Value<int> level;
  final Value<DateTime> timestamp;
  final Value<DateTime?> updatedAt;
  const EnergyLogsCompanion({
    this.id = const Value.absent(),
    this.syncId = const Value.absent(),
    this.level = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  EnergyLogsCompanion.insert({
    this.id = const Value.absent(),
    this.syncId = const Value.absent(),
    required int level,
    this.timestamp = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : level = Value(level);
  static Insertable<EnergyLog> custom({
    Expression<int>? id,
    Expression<String>? syncId,
    Expression<int>? level,
    Expression<DateTime>? timestamp,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncId != null) 'sync_id': syncId,
      if (level != null) 'level': level,
      if (timestamp != null) 'timestamp': timestamp,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  EnergyLogsCompanion copyWith({
    Value<int>? id,
    Value<String?>? syncId,
    Value<int>? level,
    Value<DateTime>? timestamp,
    Value<DateTime?>? updatedAt,
  }) {
    return EnergyLogsCompanion(
      id: id ?? this.id,
      syncId: syncId ?? this.syncId,
      level: level ?? this.level,
      timestamp: timestamp ?? this.timestamp,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EnergyLogsCompanion(')
          ..write('id: $id, ')
          ..write('syncId: $syncId, ')
          ..write('level: $level, ')
          ..write('timestamp: $timestamp, ')
          ..write('updatedAt: $updatedAt')
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
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
    updatedAt,
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
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
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
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
  final DateTime? updatedAt;
  const PacingStat({
    required this.id,
    required this.xp,
    required this.healingLevel,
    required this.currentStreak,
    this.lastLogDate,
    this.updatedAt,
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
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
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
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
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
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
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
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  PacingStat copyWith({
    int? id,
    int? xp,
    int? healingLevel,
    int? currentStreak,
    Value<DateTime?> lastLogDate = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => PacingStat(
    id: id ?? this.id,
    xp: xp ?? this.xp,
    healingLevel: healingLevel ?? this.healingLevel,
    currentStreak: currentStreak ?? this.currentStreak,
    lastLogDate: lastLogDate.present ? lastLogDate.value : this.lastLogDate,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
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
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PacingStat(')
          ..write('id: $id, ')
          ..write('xp: $xp, ')
          ..write('healingLevel: $healingLevel, ')
          ..write('currentStreak: $currentStreak, ')
          ..write('lastLogDate: $lastLogDate, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, xp, healingLevel, currentStreak, lastLogDate, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PacingStat &&
          other.id == this.id &&
          other.xp == this.xp &&
          other.healingLevel == this.healingLevel &&
          other.currentStreak == this.currentStreak &&
          other.lastLogDate == this.lastLogDate &&
          other.updatedAt == this.updatedAt);
}

class PacingStatsCompanion extends UpdateCompanion<PacingStat> {
  final Value<int> id;
  final Value<int> xp;
  final Value<int> healingLevel;
  final Value<int> currentStreak;
  final Value<DateTime?> lastLogDate;
  final Value<DateTime?> updatedAt;
  const PacingStatsCompanion({
    this.id = const Value.absent(),
    this.xp = const Value.absent(),
    this.healingLevel = const Value.absent(),
    this.currentStreak = const Value.absent(),
    this.lastLogDate = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  PacingStatsCompanion.insert({
    this.id = const Value.absent(),
    this.xp = const Value.absent(),
    this.healingLevel = const Value.absent(),
    this.currentStreak = const Value.absent(),
    this.lastLogDate = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  static Insertable<PacingStat> custom({
    Expression<int>? id,
    Expression<int>? xp,
    Expression<int>? healingLevel,
    Expression<int>? currentStreak,
    Expression<DateTime>? lastLogDate,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (xp != null) 'xp': xp,
      if (healingLevel != null) 'healing_level': healingLevel,
      if (currentStreak != null) 'current_streak': currentStreak,
      if (lastLogDate != null) 'last_log_date': lastLogDate,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  PacingStatsCompanion copyWith({
    Value<int>? id,
    Value<int>? xp,
    Value<int>? healingLevel,
    Value<int>? currentStreak,
    Value<DateTime?>? lastLogDate,
    Value<DateTime?>? updatedAt,
  }) {
    return PacingStatsCompanion(
      id: id ?? this.id,
      xp: xp ?? this.xp,
      healingLevel: healingLevel ?? this.healingLevel,
      currentStreak: currentStreak ?? this.currentStreak,
      lastLogDate: lastLogDate ?? this.lastLogDate,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
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
          ..write('lastLogDate: $lastLogDate, ')
          ..write('updatedAt: $updatedAt')
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
      Value<int> priority,
      Value<int> repeatInterval,
      Value<DateTime?> nextAllowedCompletionAt,
      Value<bool> isCompleted,
      Value<DateTime?> updatedAt,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$TasksTableUpdateCompanionBuilder =
    TasksCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<int> energyCost,
      Value<int> priority,
      Value<int> repeatInterval,
      Value<DateTime?> nextAllowedCompletionAt,
      Value<bool> isCompleted,
      Value<DateTime?> updatedAt,
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

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repeatInterval => $composableBuilder(
    column: $table.repeatInterval,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextAllowedCompletionAt => $composableBuilder(
    column: $table.nextAllowedCompletionAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
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

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repeatInterval => $composableBuilder(
    column: $table.repeatInterval,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextAllowedCompletionAt => $composableBuilder(
    column: $table.nextAllowedCompletionAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
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

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<int> get repeatInterval => $composableBuilder(
    column: $table.repeatInterval,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get nextAllowedCompletionAt => $composableBuilder(
    column: $table.nextAllowedCompletionAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

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
                Value<int> priority = const Value.absent(),
                Value<int> repeatInterval = const Value.absent(),
                Value<DateTime?> nextAllowedCompletionAt = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion(
                id: id,
                title: title,
                energyCost: energyCost,
                priority: priority,
                repeatInterval: repeatInterval,
                nextAllowedCompletionAt: nextAllowedCompletionAt,
                isCompleted: isCompleted,
                updatedAt: updatedAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required int energyCost,
                Value<int> priority = const Value.absent(),
                Value<int> repeatInterval = const Value.absent(),
                Value<DateTime?> nextAllowedCompletionAt = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion.insert(
                id: id,
                title: title,
                energyCost: energyCost,
                priority: priority,
                repeatInterval: repeatInterval,
                nextAllowedCompletionAt: nextAllowedCompletionAt,
                isCompleted: isCompleted,
                updatedAt: updatedAt,
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
      Value<String?> syncId,
      required int level,
      Value<DateTime> timestamp,
      Value<DateTime?> updatedAt,
    });
typedef $$EnergyLogsTableUpdateCompanionBuilder =
    EnergyLogsCompanion Function({
      Value<int> id,
      Value<String?> syncId,
      Value<int> level,
      Value<DateTime> timestamp,
      Value<DateTime?> updatedAt,
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

  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
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

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
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

  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
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

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
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

  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<int> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
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
                Value<String?> syncId = const Value.absent(),
                Value<int> level = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
              }) => EnergyLogsCompanion(
                id: id,
                syncId: syncId,
                level: level,
                timestamp: timestamp,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> syncId = const Value.absent(),
                required int level,
                Value<DateTime> timestamp = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
              }) => EnergyLogsCompanion.insert(
                id: id,
                syncId: syncId,
                level: level,
                timestamp: timestamp,
                updatedAt: updatedAt,
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
      Value<DateTime?> updatedAt,
    });
typedef $$PacingStatsTableUpdateCompanionBuilder =
    PacingStatsCompanion Function({
      Value<int> id,
      Value<int> xp,
      Value<int> healingLevel,
      Value<int> currentStreak,
      Value<DateTime?> lastLogDate,
      Value<DateTime?> updatedAt,
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

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
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

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
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

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
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
                Value<DateTime?> updatedAt = const Value.absent(),
              }) => PacingStatsCompanion(
                id: id,
                xp: xp,
                healingLevel: healingLevel,
                currentStreak: currentStreak,
                lastLogDate: lastLogDate,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> xp = const Value.absent(),
                Value<int> healingLevel = const Value.absent(),
                Value<int> currentStreak = const Value.absent(),
                Value<DateTime?> lastLogDate = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
              }) => PacingStatsCompanion.insert(
                id: id,
                xp: xp,
                healingLevel: healingLevel,
                currentStreak: currentStreak,
                lastLogDate: lastLogDate,
                updatedAt: updatedAt,
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
