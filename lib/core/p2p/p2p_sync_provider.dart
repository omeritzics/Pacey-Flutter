import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database_provider.dart';
import 'p2p_sync_service.dart';
import 'p2p_service.dart';

final p2pSyncServiceProvider = Provider<P2PSyncService>((ref) {
  final database = ref.watch(databaseProvider);
  final syncService = P2PSyncService();

  // Initialize the sync service with the database
  syncService.initialize(database);

  // Dispose when the provider is disposed
  ref.onDispose(() => syncService.dispose());

  return syncService;
});

final p2pConnectionStateProvider = StreamProvider<P2PConnectionState>((ref) {
  final syncService = ref.watch(p2pSyncServiceProvider);

  return syncService.events.map((event) {
    switch (event.type) {
      case P2PEventType.connected:
        return const P2PConnectionState.connected(peerId: '');
      case P2PEventType.disconnected:
        return const P2PConnectionState.disconnected();
      case P2PEventType.peerConnected:
        return P2PConnectionState.peerConnected(
          peerId: event.data['peerId'] as String,
        );
      case P2PEventType.peerDisconnected:
        return P2PConnectionState.peerDisconnected(
          peerId: event.data['peerId'] as String,
        );
      case P2PEventType.dataReceived:
        return P2PConnectionState.dataReceived(
          peerId: event.data['peerId'] as String,
          data: event.data['message'],
        );
      case P2PEventType.connectionRequest:
        return P2PConnectionState.connectionRequest(
          peerId: event.data['peerId'] as String,
        );
      case P2PEventType.connectionAccepted:
        return P2PConnectionState.connectionAccepted(
          peerId: event.data['peerId'] as String,
        );
      case P2PEventType.connectionRejected:
        return P2PConnectionState.connectionRejected(
          peerId: event.data['peerId'] as String,
        );
    }
  });
});

final connectedPeersProvider = Provider<List<String>>((ref) {
  final syncService = ref.watch(p2pSyncServiceProvider);
  return syncService.connectedPeers;
});

final localPeerIdProvider = Provider<String?>((ref) {
  final syncService = ref.watch(p2pSyncServiceProvider);
  return syncService.localPeerId;
});

final connectedDevicesProvider = Provider<Map<String, DeviceInfo>>((ref) {
  final syncService = ref.watch(p2pSyncServiceProvider);
  return syncService.connectedDevices;
});

final localDeviceInfoProvider = Provider<DeviceInfo?>((ref) {
  final syncService = ref.watch(p2pSyncServiceProvider);
  return syncService.localDeviceInfo;
});

enum P2PConnectionStatus {
  disconnected,
  connecting,
  connected,
  peerConnected,
  peerDisconnected,
  dataReceived,
  connectionRequest,
  connectionAccepted,
  connectionRejected,
}

class P2PConnectionState {
  final P2PConnectionStatus status;
  final String? peerId;
  final dynamic data;

  const P2PConnectionState._({required this.status, this.peerId, this.data});

  const P2PConnectionState.disconnected()
    : this._(status: P2PConnectionStatus.disconnected);

  const P2PConnectionState.connected({required String peerId})
    : this._(status: P2PConnectionStatus.connected, peerId: peerId);

  const P2PConnectionState.peerConnected({required String peerId})
    : this._(status: P2PConnectionStatus.peerConnected, peerId: peerId);

  const P2PConnectionState.peerDisconnected({required String peerId})
    : this._(status: P2PConnectionStatus.peerDisconnected, peerId: peerId);

  const P2PConnectionState.dataReceived({
    required String peerId,
    required dynamic data,
  }) : this._(
         status: P2PConnectionStatus.dataReceived,
         peerId: peerId,
         data: data,
       );

  const P2PConnectionState.connectionRequest({required String peerId})
    : this._(status: P2PConnectionStatus.connectionRequest, peerId: peerId);

  const P2PConnectionState.connectionAccepted({required String peerId})
    : this._(status: P2PConnectionStatus.connectionAccepted, peerId: peerId);

  const P2PConnectionState.connectionRejected({required String peerId})
    : this._(status: P2PConnectionStatus.connectionRejected, peerId: peerId);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is P2PConnectionState &&
        other.status == status &&
        other.peerId == peerId &&
        other.data == data;
  }

  @override
  int get hashCode => status.hashCode ^ peerId.hashCode ^ data.hashCode;

  @override
  String toString() {
    return 'P2PConnectionState(status: $status, peerId: $peerId, data: $data)';
  }
}
