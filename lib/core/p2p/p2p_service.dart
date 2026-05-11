import 'dart:async';
import 'package:peer_rtc/peer_rtc.dart';
import 'package:uuid/uuid.dart';

class P2PService {
  static final P2PService _instance = P2PService._internal();
  factory P2PService() => _instance;
  P2PService._internal();

  Peer? _peer;
  final Map<String, DataConnection> _connections = {};
  final _uuid = const Uuid();

  final StreamController<P2PEvent> _eventController =
      StreamController<P2PEvent>.broadcast();
  Stream<P2PEvent> get events => _eventController.stream;

  bool _isInitialized = false;
  String? _peerId;

  Future<void> initialize({String? peerId}) async {
    if (_isInitialized) return;

    _peerId = peerId ?? _uuid.v4();
    _peer = Peer(
      options: PeerOptions(autoReconnect: true, debug: LogLevel.All),
    );

    _peer!.onOpen.listen((id) {
      _eventController.add(
        P2PEvent(type: P2PEventType.connected, data: {'peerId': id}),
      );
    });

    _peer!.onConnection.listen((conn) {
      _handleConnection(conn);
    });

    _peer!.onDisconnected.listen((_) {
      _eventController.add(
        P2PEvent(type: P2PEventType.disconnected, data: {'peerId': _peerId}),
      );
    });

    _isInitialized = true;
  }

  void _handleConnection(DataConnection conn) {
    final peerId = conn.peer;
    _connections[peerId] = conn;

    conn.onOpen.listen((_) {
      _eventController.add(
        P2PEvent(type: P2PEventType.peerConnected, data: {'peerId': peerId}),
      );
    });

    conn.onData.listen((data) {
      _eventController.add(
        P2PEvent(
          type: P2PEventType.dataReceived,
          data: {'peerId': peerId, 'message': data},
        ),
      );
    });

    conn.onClose.listen((_) {
      _connections.remove(peerId);
      _eventController.add(
        P2PEvent(type: P2PEventType.peerDisconnected, data: {'peerId': peerId}),
      );
    });
  }

  Future<DataConnection> connectToPeer(String peerId) async {
    if (!_isInitialized) {
      throw StateError('P2P service not initialized');
    }

    final conn = _peer!.connect(peerId);
    _handleConnection(conn);
    return conn;
  }

  void broadcastData(Map<String, dynamic> data) {
    for (final conn in _connections.values) {
      conn.send(data);
    }
  }

  void sendDataToPeer(String peerId, Map<String, dynamic> data) {
    final conn = _connections[peerId];
    if (conn != null) {
      conn.send(data);
    }
  }

  List<String> get connectedPeers => _connections.keys.toList();

  String? get localPeerId => _peerId;

  bool get isInitialized => _isInitialized;

  Future<void> dispose() async {
    for (final conn in _connections.values) {
      conn.close();
    }
    _connections.clear();

    if (_peer != null) {
      _peer!.dispose();
      _peer = null;
    }

    await _eventController.close();
    _isInitialized = false;
  }
}

enum P2PEventType {
  connected,
  disconnected,
  peerConnected,
  peerDisconnected,
  dataReceived,
}

class P2PEvent {
  final P2PEventType type;
  final Map<String, dynamic> data;

  P2PEvent({required this.type, required this.data});
}
