import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/p2p/p2p_sync_provider.dart';
import 'qr_scanner_screen.dart';

class P2PScreen extends ConsumerStatefulWidget {
  const P2PScreen({super.key});

  @override
  ConsumerState<P2PScreen> createState() => _P2PScreenState();
}

class _P2PScreenState extends ConsumerState<P2PScreen> {
  final TextEditingController _peerIdController = TextEditingController();

  @override
  void dispose() {
    _peerIdController.dispose();
    super.dispose();
  }

  Future<void> _scanQRCode() async {
    // Request camera permission
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Camera permission is required to scan QR codes'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (!mounted) return;

    // Navigate to QR scanner
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (context) => const QRScannerScreen()),
    );

    // If a QR code was scanned, it will be returned as result
    if (result != null && result.isNotEmpty) {
      _peerIdController.text = result;
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectionState = ref.watch(p2pConnectionStateProvider);
    final connectedPeers = ref.watch(connectedPeersProvider);
    final localPeerId = ref.watch(localPeerIdProvider);
    final syncService = ref.watch(p2pSyncServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('P2P Sync')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Local Peer ID
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Peer ID',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (localPeerId != null)
                      Column(
                        children: [
                          // QR Code
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: QrImageView(
                                data: localPeerId,
                                version: QrVersions.auto,
                                size: 200.0,
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Text ID
                          SelectableText(
                            localPeerId,
                            style: const TextStyle(
                              fontSize: 16,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      )
                    else
                      const Text('Initializing...'),
                    const SizedBox(height: 8),
                    const Text(
                      'Share this QR code or ID with other devices to connect',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Connection Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Connection Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    connectionState.when(
                      data: (state) => _buildConnectionStatus(state),
                      loading: () => const CircularProgressIndicator(),
                      error: (error, stack) => Text(
                        'Error: $error',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Connect to Peer
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Connect to Peer',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _peerIdController,
                      decoration: const InputDecoration(
                        labelText: 'Enter Peer ID',
                        border: OutlineInputBorder(),
                        hintText: 'Paste the peer ID here',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              final peerId = _peerIdController.text.trim();
                              if (peerId.isNotEmpty) {
                                syncService.connectToPeer(peerId);
                                _peerIdController.clear();
                              }
                            },
                            icon: const Icon(Icons.link),
                            label: const Text('Connect'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _scanQRCode,
                          icon: const Icon(Icons.qr_code_scanner),
                          label: const Text('Scan QR'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Connected Peers
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connected Peers (${connectedPeers.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (connectedPeers.isEmpty)
                      const Text('No peers connected')
                    else
                      ...connectedPeers.map(
                        (peerId) => ListTile(
                          leading: const Icon(Icons.device_hub),
                          title: Text(
                            peerId,
                            style: const TextStyle(fontFamily: 'monospace'),
                          ),
                          subtitle: const Text('Connected'),
                          trailing: IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed: () {
                              // Copy peer ID to clipboard
                              // You might want to add a clipboard package
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionStatus(P2PConnectionState state) {
    IconData icon;
    Color color;
    String text;

    switch (state.status) {
      case P2PConnectionStatus.disconnected:
        icon = Icons.link_off;
        color = Colors.red;
        text = 'Disconnected';
        break;
      case P2PConnectionStatus.connected:
        icon = Icons.link;
        color = Colors.green;
        text = 'Connected to P2P network';
        break;
      case P2PConnectionStatus.peerConnected:
        icon = Icons.device_hub;
        color = Colors.blue;
        text = 'Peer connected: ${state.peerId}';
        break;
      case P2PConnectionStatus.peerDisconnected:
        icon = Icons.device_hub_outlined;
        color = Colors.orange;
        text = 'Peer disconnected: ${state.peerId}';
        break;
      case P2PConnectionStatus.dataReceived:
        icon = Icons.sync;
        color = Colors.purple;
        text = 'Syncing data...';
        break;
      default:
        icon = Icons.help;
        color = Colors.grey;
        text = 'Unknown status';
    }

    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: TextStyle(color: color)),
        ),
      ],
    );
  }
}
