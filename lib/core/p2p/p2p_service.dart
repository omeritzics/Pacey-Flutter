import 'dart:async';
import 'package:peer_rtc/peer_rtc.dart';
import 'package:uuid/uuid.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class P2PService {
  static final P2PService _instance = P2PService._internal();
  factory P2PService() => _instance;
  P2PService._internal();

  Peer? _peer;
  final Map<String, DataConnection> _connections = {};
  final Map<String, DataConnection> _pendingConnections = {};
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
    final deviceName = await _getDeviceName();
    final deviceType = _getDeviceType();

    _localDeviceInfo = DeviceInfo(
      peerId: _peerId!,
      deviceName: deviceName,
      deviceType: deviceType,
      connectedAt: DateTime.now(),
    );

    _peer!.onOpen.listen((id) {
      _eventController.add(
        P2PEvent(type: P2PEventType.connected, data: {'peerId': id}),
      );
    });

    _peer!.onConnection.listen((conn) {
      _handleIncomingConnection(conn);
    });

    _peer!.onDisconnected.listen((_) {
      _eventController.add(
        P2PEvent(type: P2PEventType.disconnected, data: {'peerId': _peerId}),
      );
    });

    _isInitialized = true;
  }

  void _handleIncomingConnection(DataConnection conn) {
    final peerId = conn.peer;

    // Store as pending until accepted
    _pendingConnections[peerId] = conn;

    // Emit connection request event for the UI to accept/reject
    _eventController.add(
      P2PEvent(type: P2PEventType.connectionRequest, data: {'peerId': peerId}),
    );

    conn.onOpen.listen((_) {
      // Connection opened - only add if still pending (not rejected)
      if (_pendingConnections.containsKey(peerId)) {
        // Share local device info when connection opens
        if (_localDeviceInfo != null) {
          sendDataToPeer(peerId, {
            'type': 'device_info',
            'payload': _localDeviceInfo!.toJson(),
          });
        }

        _connections[peerId] = conn;
        _pendingConnections.remove(peerId);
        _eventController.add(
          P2PEvent(type: P2PEventType.peerConnected, data: {'peerId': peerId}),
        );
      }
    });

    conn.onData.listen((data) {
      if (!_connections.containsKey(peerId)) return;
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
      _pendingConnections.remove(peerId);
      _deviceInfo.remove(peerId);
      _eventController.add(
        P2PEvent(type: P2PEventType.peerDisconnected, data: {'peerId': peerId}),
      );
    });
  }

  void acceptConnection(String peerId) {
    final conn = _pendingConnections[peerId];
    if (conn != null) {
      _eventController.add(
        P2PEvent(type: P2PEventType.connectionAccepted, data: {'peerId': peerId}),
      );
      // Connection stays in pending; will be moved to connections on onOpen
    }
  }

  void rejectConnection(String peerId) {
    final conn = _pendingConnections.remove(peerId);
    if (conn != null) {
      conn.close();
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
    
    // For outgoing connections, automatically accept - user already confirmed
    conn.onOpen.listen((_) {
      if (_localDeviceInfo != null) {
        sendDataToPeer(peerId, {
          'type': 'device_info',
          'payload': _localDeviceInfo!.toJson(),
        });
      }
      
      _connections[peerId] = conn;
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
    for (final conn in _pendingConnections.values) {
      conn.close();
    }
    _connections.clear();
    _pendingConnections.clear();
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

  Future<String> _getDeviceName() async {
    final deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return '${androidInfo.manufacturer} ${androidInfo.model}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.name;
      } else if (Platform.isWindows) {
        final windowsInfo = await deviceInfo.windowsInfo;
        return windowsInfo.computerName;
      } else if (Platform.isMacOS) {
        final macosInfo = await deviceInfo.macOsInfo;
        return macosInfo.computerName;
      } else if (Platform.isLinux) {
        final linuxInfo = await deviceInfo.linuxInfo;
        return linuxInfo.name;
      }
    } catch (e) {
      // Fallback
    }
    return 'Pacey Device';
  }

  String _getDeviceType() {
    if (Platform.isAndroid || Platform.isIOS) return 'Mobile';
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) return 'Desktop';
    return 'Unknown';
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
