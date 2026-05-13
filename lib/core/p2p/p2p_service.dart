import 'dart:async';
import 'package:peer_rtc/peer_rtc.dart';
import 'package:uuid/uuid.dart';

class P2PService {
  static final P2PService _instance = P2PService._internal();
  factory P2PService() => _instance;
  P2PService._internal();

  Peer? _peer;
  final Map<String, DataConnection> _connections = {};
  final Map<String, DeviceInfo> _deviceInfo = {};
  final _uuid = const Uuid();

  final StreamController<P2PEvent> _eventController =
      StreamController<P2PEvent>.broadcast();
  Stream<P2PEvent> get events => _eventController.stream;

  bool _isInitialized = false;
  String? _peerId;
  DeviceInfo? _localDeviceInfo;

  Future<void> initialize({String? peerId}) async {
    if (_isInitialized) return;

    _peerId = peerId ?? _uuid.v4();
    _peer = Peer(
      options: PeerOptions(autoReconnect: true, debug: LogLevel.All),
    );

    // Create local device info
    _localDeviceInfo = DeviceInfo(
      peerId: _peerId!,
      deviceName: _getDeviceName(),
      deviceType: _getDeviceType(),
      connectedAt: DateTime.now(),
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
      // Share local device info when connection opens
      if (_localDeviceInfo != null) {
        sendDataToPeer(peerId, {
          'type': 'device_info',
          'payload': _localDeviceInfo!.toJson(),
        });
      }
      
      _eventController.add(
        P2PEvent(type: P2PEventType.peerConnected, data: {'peerId': peerId}),
      );
    });

    conn.onData.listen((data) {
      _handleIncomingData(peerId, data);
      _eventController.add(
        P2PEvent(
          type: P2PEventType.dataReceived,
          data: {'peerId': peerId, 'message': data},
        ),
      );
    });

    conn.onClose.listen((_) {
      _connections.remove(peerId);
      _deviceInfo.remove(peerId);
      _eventController.add(
        P2PEvent(type: P2PEventType.peerDisconnected, data: {'peerId': peerId}),
      );
    });
  }

  void acceptConnection(String peerId) {
    final conn = _connections[peerId];
    if (conn != null) {
      _eventController.add(
        P2PEvent(type: P2PEventType.connectionAccepted, data: {'peerId': peerId}),
      );
    }
  }

  void rejectConnection(String peerId) {
    final conn = _connections[peerId];
    if (conn != null) {
      conn.close();
      _connections.remove(peerId);
      _eventController.add(
        P2PEvent(type: P2PEventType.connectionRejected, data: {'peerId': peerId}),
      );
    }
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

  DeviceInfo? get localDeviceInfo => _localDeviceInfo;

  Map<String, DeviceInfo> get connectedDevices => Map.unmodifiable(_deviceInfo);

  Future<void> dispose() async {
    for (final conn in _connections.values) {
      conn.close();
    }
    _connections.clear();
    _deviceInfo.clear();

    if (_peer != null) {
      _peer!.dispose();
      _peer = null;
    }

    await _eventController.close();
    _isInitialized = false;
  }

  void _handleIncomingData(String peerId, dynamic data) {
    if (data is Map<String, dynamic>) {
      final type = data['type'] as String?;
      final payload = data['payload'] as Map<String, dynamic>?;
      
      if (type == 'device_info' && payload != null) {
        try {
          final deviceInfo = DeviceInfo.fromJson(payload);
          _deviceInfo[peerId] = deviceInfo;
        } catch (e) {
          // Handle malformed device info
        }
      }
    }
  }

  String _getDeviceName() {
    // Try to get a meaningful device name
    try {
      return 'Pacey Device';
    } catch (e) {
      return 'Unknown Device';
    }
  }

  String _getDeviceType() {
    // Determine device type based on platform
    try {
      return 'Mobile';
    } catch (e) {
      return 'Unknown';
    }
  }
}

enum P2PEventType {
  connected,
  disconnected,
  peerConnected,
  peerDisconnected,
  dataReceived,
  connectionRequest,
  connectionAccepted,
  connectionRejected,
}

class P2PEvent {
  final P2PEventType type;
  final Map<String, dynamic> data;

  P2PEvent({required this.type, required this.data});
}

class DeviceInfo {
  final String peerId;
  final String deviceName;
  final String deviceType;
  final DateTime connectedAt;
  final Map<String, dynamic> metadata;

  DeviceInfo({
    required this.peerId,
    required this.deviceName,
    required this.deviceType,
    required this.connectedAt,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'peerId': peerId,
      'deviceName': deviceName,
      'deviceType': deviceType,
      'connectedAt': connectedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory DeviceInfo.fromJson(Map<String, dynamic> json) {
    return DeviceInfo(
      peerId: json['peerId'] as String,
      deviceName: json['deviceName'] as String,
      deviceType: json['deviceType'] as String,
      connectedAt: DateTime.parse(json['connectedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }
}
