import 'dart:async';
import 'package:drift/drift.dart';
import '../database/database.dart';
import '../p2p/p2p_service.dart';

class P2PSyncService {
  static final P2PSyncService _instance = P2PSyncService._internal();
  factory P2PSyncService() => _instance;
  P2PSyncService._internal();

  final P2PService _p2pService = P2PService();
  AppDatabase? _database;
  StreamSubscription<P2PEvent>? _p2pSubscription;

  Stream<P2PEvent> get events => _p2pService.events;

  Future<void> initialize(AppDatabase database) async {
    if (_database != null) return;
    _database = database;
    await _p2pService.initialize();

    _p2pSubscription = _p2pService.events.listen(_handleP2PEvent);
  }

  void _handleP2PEvent(P2PEvent event) {
    switch (event.type) {
      case P2PEventType.dataReceived:
        _handleSyncData(event.data);
        break;
      case P2PEventType.peerConnected:
        _onPeerConnected(event.data['peerId']);
        break;
      case P2PEventType.peerDisconnected:
        _onPeerDisconnected(event.data['peerId']);
        break;
      case P2PEventType.connectionRequest:
        _handleConnectionRequest(event.data['peerId']);
        break;
      default:
        break;
    }
  }

  void _handleSyncData(Map<String, dynamic> data) {
    if (_database == null) return;

    final type = data['type'] as String?;
    final payload = data['payload'] as Map<String, dynamic>?;

    if (type == null || payload == null) return;

    switch (type) {
      case 'task_created':
      case 'task_updated':
        _syncTask(payload);
        break;
      case 'task_deleted':
        _deleteTask(payload['id'] as String);
        break;
      case 'energy_log_created':
      case 'energy_log_updated':
        _syncEnergyLog(payload);
        break;
      case 'pacing_stats_updated':
        _syncPacingStats(payload);
        break;
    }
  }

  Future<void> _syncTask(Map<String, dynamic> taskData) async {
    if (_database == null) return;

    final incomingUpdatedAt = DateTime.parse(taskData['updatedAt'] as String);
    final taskId = taskData['id'] as String;

    final existingTask = await (_database!.select(_database!.tasks)
          ..where((t) => t.id.equals(taskId)))
        .getSingleOrNull();

    if (existingTask != null &&
        existingTask.updatedAt.isAfter(incomingUpdatedAt)) {
      // Local version is newer, ignore incoming
      return;
    }

    final task = TasksCompanion.insert(
      id: taskId,
      title: taskData['title'] as String,
      energyCost: taskData['energyCost'] as int,
      isCompleted: Value(taskData['isCompleted'] as bool),
      createdAt: Value(DateTime.parse(taskData['createdAt'] as String)),
      updatedAt: Value(incomingUpdatedAt),
    );

    if (existingTask == null) {
      await _database!.into(_database!.tasks).insert(task);
    } else {
      await _database!.update(_database!.tasks).replace(task);
    }
  }

  Future<void> _deleteTask(String taskId) async {
    if (_database == null) return;

    await (_database!.delete(
      _database!.tasks,
    )..where((t) => t.id.equals(taskId))).go();
  }

  Future<void> _syncEnergyLog(Map<String, dynamic> logData) async {
    if (_database == null) return;

    final syncId = logData['syncId'] as String;
    final incomingUpdatedAt = DateTime.parse(logData['updatedAt'] as String);

    final existingLog = await (_database!.select(_database!.energyLogs)
          ..where((t) => t.syncId.equals(syncId)))
        .getSingleOrNull();

    if (existingLog != null &&
        existingLog.updatedAt.isAfter(incomingUpdatedAt)) {
      return;
    }

    final log = EnergyLogsCompanion.insert(
      syncId: syncId,
      level: logData['level'] as int,
      timestamp: Value(DateTime.parse(logData['timestamp'] as String)),
      updatedAt: Value(incomingUpdatedAt),
    );

    if (existingLog == null) {
      await _database!.into(_database!.energyLogs).insert(log);
    } else {
      final updatedLog = log.copyWith(id: Value(existingLog.id));
      await _database!.update(_database!.energyLogs).replace(updatedLog);
    }
  }

  Future<void> _syncPacingStats(Map<String, dynamic> statsData) async {
    if (_database == null) return;

    final incomingUpdatedAt = DateTime.parse(statsData['updatedAt'] as String);

    final stats = PacingStatsCompanion.insert(
      xp: Value(statsData['xp'] as int),
      healingLevel: Value(statsData['healingLevel'] as int),
      currentStreak: Value(statsData['currentStreak'] as int),
      lastLogDate: statsData['lastLogDate'] != null
          ? Value(DateTime.parse(statsData['lastLogDate'] as String))
          : const Value.absent(),
      updatedAt: Value(incomingUpdatedAt),
    );

    final existingStats =
        await (_database!.select(_database!.pacingStats)).get();
    if (existingStats.isEmpty) {
      await _database!.into(_database!.pacingStats).insert(stats);
    } else {
      if (existingStats.first.updatedAt.isAfter(incomingUpdatedAt)) {
        return;
      }
      final updatedStats = stats.copyWith(id: Value(existingStats.first.id));
      await _database!.update(_database!.pacingStats).replace(updatedStats);
    }
  }

  void _onPeerConnected(String peerId) {
    // Send current data to newly connected peer
    _broadcastAllData();
  }

  void _onPeerDisconnected(String peerId) {
    // Handle peer disconnection if needed
  }

  void _handleConnectionRequest(String peerId) {
    // This will be handled by the UI layer for confirmation
    // The event is already being broadcast by P2P service
  }

  Future<void> _broadcastAllData() async {
    if (_database == null) return;

    // Broadcast all tasks
    final tasks = await _database!.select(_database!.tasks).get();
    for (final task in tasks) {
      _broadcastTaskUpdate(task);
    }

    // Broadcast energy logs
    final logs = await _database!.select(_database!.energyLogs).get();
    for (final log in logs) {
      _broadcastEnergyLogUpdate(log);
    }

    // Broadcast pacing stats
    final stats = await _database!.select(_database!.pacingStats).get();
    for (final stat in stats) {
      _broadcastPacingStatsUpdate(stat);
    }
  }

  void broadcastTaskCreated(Task task) {
    _broadcastTaskUpdate(task, 'task_created');
  }

  void broadcastTaskUpdated(Task task) {
    _broadcastTaskUpdate(task, 'task_updated');
  }

  void broadcastTaskDeleted(String taskId) {
    _p2pService.broadcastData({
      'type': 'task_deleted',
      'payload': {'id': taskId},
    });
  }

  void _broadcastTaskUpdate(Task task, [String type = 'task_updated']) {
    _p2pService.broadcastData({
      'type': type,
      'payload': {
        'id': task.id,
        'title': task.title,
        'energyCost': task.energyCost,
        'isCompleted': task.isCompleted,
        'createdAt': task.createdAt.toIso8601String(),
        'updatedAt': task.updatedAt.toIso8601String(),
      },
    });
  }

  void broadcastEnergyLogCreated(EnergyLog log) {
    _broadcastEnergyLogUpdate(log, 'energy_log_created');
  }

  void _broadcastEnergyLogUpdate(
    EnergyLog log, [
    String type = 'energy_log_updated',
  ]) {
    _p2pService.broadcastData({
      'type': type,
      'payload': {
        'syncId': log.syncId,
        'level': log.level,
        'timestamp': log.timestamp.toIso8601String(),
        'updatedAt': log.updatedAt.toIso8601String(),
      },
    });
  }

  void broadcastPacingStatsUpdated(PacingStat stat) {
    _broadcastPacingStatsUpdate(stat);
  }

  void _broadcastPacingStatsUpdate(
    PacingStat stat, [
    String type = 'pacing_stats_updated',
  ]) {
    _p2pService.broadcastData({
      'type': type,
      'payload': {
        'xp': stat.xp,
        'healingLevel': stat.healingLevel,
        'currentStreak': stat.currentStreak,
        'lastLogDate': stat.lastLogDate?.toIso8601String(),
        'updatedAt': stat.updatedAt.toIso8601String(),
      },
    });
  }

  Future<void> connectToPeer(String peerId) async {
    await _p2pService.connectToPeer(peerId);
  }

  void acceptConnection(String peerId) {
    _p2pService.acceptConnection(peerId);
  }

  void rejectConnection(String peerId) {
    _p2pService.rejectConnection(peerId);
  }

  List<String> get connectedPeers => _p2pService.connectedPeers;

  String? get localPeerId => _p2pService.localPeerId;

  Map<String, DeviceInfo> get connectedDevices => _p2pService.connectedDevices;

  DeviceInfo? get localDeviceInfo => _p2pService.localDeviceInfo;

  Future<void> dispose() async {
    await _p2pSubscription?.cancel();
    await _p2pService.dispose();
  }
}
