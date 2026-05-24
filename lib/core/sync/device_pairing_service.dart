import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:math' show Random;
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../../data/crdt_database.dart';

enum ConnectionStatus { disconnected, connecting, connected, error }

class DeviceInfo {
  final String deviceId;
  final String deviceName;
  final String? ipAddress;
  final DateTime lastSeen;

  DeviceInfo({
    required this.deviceId,
    required this.deviceName,
    this.ipAddress,
    required this.lastSeen,
  });

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'deviceName': deviceName,
      'ipAddress': ipAddress,
      'lastSeen': lastSeen.toIso8601String(),
    };
  }

  factory DeviceInfo.fromJson(Map<String, dynamic> json) {
    return DeviceInfo(
      deviceId: json['deviceId'] as String,
      deviceName: json['deviceName'] as String,
      ipAddress: json['ipAddress'] as String?,
      lastSeen: DateTime.parse(json['lastSeen'] as String),
    );
  }
}

class SyncMessage {
  final String type; // 'changeset', 'ping', 'ack'
  final String? deviceId;
  final String? data;
  final DateTime timestamp;

  SyncMessage({
    required this.type,
    this.deviceId,
    this.data,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'deviceId': deviceId,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory SyncMessage.fromJson(Map<String, dynamic> json) {
    return SyncMessage(
      type: json['type'] as String,
      deviceId: json['deviceId'] as String?,
      data: json['data'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  String toJsonString() => jsonEncode(toJson());
  static SyncMessage fromJsonString(String jsonString) =>
      SyncMessage.fromJson(jsonDecode(jsonString));
}

class DevicePairingService extends ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final Uuid uuid = const Uuid();

  String? _deviceId;
  String? _deviceName;
  WebSocketChannel? _channel;
  ConnectionStatus _connectionStatus = ConnectionStatus.disconnected;
  DeviceInfo? _connectedDevice;
  CrdtDatabase? _crdtDatabase;
  enc.Encrypter? _encrypter;

  final List<DeviceInfo> _pairedDevices = [];

  String? get deviceId => _deviceId;
  String? get deviceName => _deviceName;
  ConnectionStatus get connectionStatus => _connectionStatus;
  DeviceInfo? get connectedDevice => _connectedDevice;
  List<DeviceInfo> get pairedDevices => List.unmodifiable(_pairedDevices);
  bool get isConnected => _connectionStatus == ConnectionStatus.connected;

  Future<void> initialize(CrdtDatabase crdtDatabase) async {
    _crdtDatabase = crdtDatabase;
    await _loadDeviceInfo();
    await _loadPairedDevices();
    await _setupEncrypter();

    // Set up callback to broadcast changesets when data changes
    _crdtDatabase!.onDataChange = () {
      if (isConnected) {
        broadcastChangeset();
      }
    };
  }

  Future<void> _loadDeviceInfo() async {
    try {
      _deviceId = await _storage.read(key: 'device_id');
      _deviceName = await _storage.read(key: 'device_name');
    } catch (e) {
      // Storage not available, will use in-memory values
    }

    if (_deviceId == null || _deviceName == null) {
      String model = 'Device';
      String name = 'Pacey User';

      try {
        final deviceInfo = DeviceInfoPlugin();
        if (kIsWeb) {
          final webInfo = await deviceInfo.webBrowserInfo;
          model = webInfo.browserName.name;
          name = 'Web User';
        } else if (Platform.isAndroid) {
          final androidInfo = await deviceInfo.androidInfo;
          model = androidInfo.model;
          name = androidInfo.device;
        } else if (Platform.isIOS) {
          final iosInfo = await deviceInfo.iosInfo;
          model = iosInfo.model;
          name = iosInfo.name;
        } else if (Platform.isMacOS) {
          final macInfo = await deviceInfo.macOsInfo;
          model = macInfo.model;
          name = macInfo.computerName;
        } else if (Platform.isWindows) {
          final windowsInfo = await deviceInfo.windowsInfo;
          model = 'Windows';
          name = windowsInfo.computerName;
        } else if (Platform.isLinux) {
          final linuxInfo = await deviceInfo.linuxInfo;
          model = linuxInfo.name;
          name = linuxInfo.prettyName;
        }
      } catch (e) {
        // Fallback to basic Platform values if device_info fails
        if (!kIsWeb) {
          model = Platform.operatingSystem;
          name = Platform.localHostname;
        }
      }

      // Generate the suffix (5 random alphanumeric characters)
      const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
      final random = Random();
      final suffix = List.generate(
        5,
        (index) => chars[random.nextInt(chars.length)],
      ).join();

      // Sanitize model and name to be a clean slug (lowercase, alphanumeric, hyphens)
      String sanitize(String value) {
        return value
            .toLowerCase()
            .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
            .replaceAll(RegExp(r'^-+|-+$'), '');
      }

      final cleanModel = sanitize(model);
      final cleanName = sanitize(name);

      if (_deviceId == null) {
        _deviceId = '$cleanModel-$cleanName-$suffix';
        try {
          await _storage.write(key: 'device_id', value: _deviceId!);
        } catch (e) {
          // Storage not available
        }
      }

      if (_deviceName == null) {
        _deviceName = '$model ($name)';
        try {
          await _storage.write(key: 'device_name', value: _deviceName!);
        } catch (e) {
          // Storage not available
        }
      }
    }
  }

  Future<void> _loadPairedDevices() async {
    try {
      final pairedDevicesJson = await _storage.read(key: 'paired_devices');
      if (pairedDevicesJson != null) {
        final List<dynamic> devicesList = jsonDecode(pairedDevicesJson);
        _pairedDevices.clear();
        for (var deviceJson in devicesList) {
          _pairedDevices.add(DeviceInfo.fromJson(deviceJson));
        }
      }
    } catch (e) {
      // Storage not available, using in-memory values
    }
  }

  Future<void> _savePairedDevices() async {
    final devicesJson = jsonEncode(
      _pairedDevices.map((d) => d.toJson()).toList(),
    );
    try {
      await _storage.write(key: 'paired_devices', value: devicesJson);
    } catch (e) {
      // Storage not available, using in-memory values
    }
  }

  Future<void> _setupEncrypter() async {
    final key = await _getEncryptionKey();
    _encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
  }

  Future<enc.Key> _getEncryptionKey() async {
    const keyName = 'sync_encryption_key';
    String? storedKey;
    try {
      storedKey = await _storage.read(key: keyName);
    } catch (e) {
      // Storage not available, will generate new key
    }

    if (storedKey != null) {
      try {
        return enc.Key.fromBase16(storedKey);
      } catch (_) {
        // If stored key is invalid, generate a new one
      }
    }
    final key = enc.Key.fromSecureRandom(32);
    try {
      await _storage.write(key: keyName, value: key.base16);
    } catch (e) {
      // Storage not available, using in-memory key
    }
    return key;
  }

  String generatePairingCode() {
    final pairingData = {
      'deviceId': _deviceId,
      'deviceName': _deviceName,
      'timestamp': DateTime.now().toIso8601String(),
    };
    return jsonEncode(pairingData);
  }

  Future<bool> pairDevice(String pairingCode) async {
    try {
      final pairingData = jsonDecode(pairingCode) as Map<String, dynamic>;
      final deviceId = pairingData['deviceId'] as String;
      final deviceName = pairingData['deviceName'] as String;

      // Check if already paired
      if (_pairedDevices.any((d) => d.deviceId == deviceId)) {
        return true;
      }

      final deviceInfo = DeviceInfo(
        deviceId: deviceId,
        deviceName: deviceName,
        lastSeen: DateTime.now(),
      );

      _pairedDevices.add(deviceInfo);
      await _savePairedDevices();
      notifyListeners();

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> connectToDevice(DeviceInfo device) async {
    if (_connectionStatus == ConnectionStatus.connected) {
      await disconnect();
    }

    _connectionStatus = ConnectionStatus.connecting;
    notifyListeners();

    try {
      // For local network, we'd use the device's IP address
      // For now, we'll use a placeholder WebSocket URL
      // In a real implementation, this would be the device's actual WebSocket server
      final wsUrl = 'ws://${device.ipAddress ?? 'localhost'}:8080/sync';
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      _channel!.stream.listen(
        _handleMessage,
        onError: (error) {
          _connectionStatus = ConnectionStatus.error;
          notifyListeners();
        },
        onDone: () {
          _connectionStatus = ConnectionStatus.disconnected;
          _connectedDevice = null;
          notifyListeners();
        },
      );

      _connectionStatus = ConnectionStatus.connected;
      _connectedDevice = device;
      notifyListeners();

      // Send initial ping
      _sendMessage(
        SyncMessage(
          type: 'ping',
          deviceId: _deviceId,
          timestamp: DateTime.now(),
        ),
      );
    } catch (e) {
      _connectionStatus = ConnectionStatus.error;
      notifyListeners();
    }
  }

  Future<void> disconnect() async {
    await _channel?.sink.close();
    _channel = null;
    _connectionStatus = ConnectionStatus.disconnected;
    _connectedDevice = null;
    notifyListeners();
  }

  void _handleMessage(dynamic message) {
    try {
      final syncMessage = SyncMessage.fromJsonString(message as String);

      switch (syncMessage.type) {
        case 'changeset':
          if (_crdtDatabase != null && syncMessage.data != null) {
            _handleIncomingChangeset(syncMessage.data!);
          }
          break;
        case 'ping':
          // Respond with ack
          _sendMessage(
            SyncMessage(
              type: 'ack',
              deviceId: _deviceId,
              timestamp: DateTime.now(),
            ),
          );
          break;
        case 'ack':
          // Connection acknowledged
          break;
      }
    } catch (e) {
      // Handle parsing error
    }
  }

  Future<void> _handleIncomingChangeset(String encryptedChangeset) async {
    if (_crdtDatabase == null || _encrypter == null) return;

    try {
      await _crdtDatabase!.importChangeset(encryptedChangeset);
    } catch (e) {
      // Handle import error
    }
  }

  Future<void> broadcastChangeset() async {
    if (_crdtDatabase == null || _encrypter == null || !isConnected) return;

    try {
      final encryptedChangeset = await _crdtDatabase!.exportChangeset();

      _sendMessage(
        SyncMessage(
          type: 'changeset',
          deviceId: _deviceId,
          data: encryptedChangeset,
          timestamp: DateTime.now(),
        ),
      );
    } catch (e) {
      // Handle export error
    }
  }

  void _sendMessage(SyncMessage message) {
    if (_channel != null) {
      _channel!.sink.add(message.toJsonString());
    }
  }

  Future<void> removePairedDevice(String deviceId) async {
    _pairedDevices.removeWhere((d) => d.deviceId == deviceId);
    await _savePairedDevices();

    if (_connectedDevice?.deviceId == deviceId) {
      await disconnect();
    }

    notifyListeners();
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
