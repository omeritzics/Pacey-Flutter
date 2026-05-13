import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pacey/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    // Request camera permission
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.cameraPermissionRequired),
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

  void _showConnectionDialog(String peerId) {
    final syncService = ref.read(p2pSyncServiceProvider);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l10n.connectionRequest),
          content: Text(
            l10n.deviceWantsToConnect(peerId),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                syncService.rejectConnection(peerId);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.connectionRejected(peerId)),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: Text(l10n.reject),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                syncService.acceptConnection(peerId);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.connectedTo(peerId)),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text(l10n.accept),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final connectionState = ref.watch(p2pConnectionStateProvider);
    final connectedPeers = ref.watch(connectedPeersProvider);
    final localPeerId = ref.watch(localPeerIdProvider);
    final syncService = ref.watch(p2pSyncServiceProvider);

    // Handle connection requests
    ref.listen(p2pConnectionStateProvider, (previous, next) {
      if (next.value?.status == P2PConnectionStatus.connectionRequest) {
        _showConnectionDialog(next.value!.peerId!);
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.p2pSync)),
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
                    Text(
                      l10n.yourPeerId,
                      style: const TextStyle(
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
                                // ignore: deprecated_member_use
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
                      Text(l10n.initializing),
                    const SizedBox(height: 8),
                    Text(
                      l10n.shareQrCode,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
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
                    Text(
                      l10n.connectionStatus,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    connectionState.when(
                      data: (state) => _buildConnectionStatus(state, l10n),
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
                    Text(
                      l10n.connectToPeer,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _peerIdController,
                      decoration: InputDecoration(
                        labelText: l10n.enterPeerId,
                        border: const OutlineInputBorder(),
                        hintText: l10n.pastePeerId,
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
                            label: Text(l10n.connect),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _scanQRCode,
                          icon: const Icon(Icons.qr_code_scanner),
                          label: Text(l10n.scanQr),
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
                      '${l10n.connectedPeers} (${connectedPeers.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (connectedPeers.isEmpty)
                      Text(l10n.noPeersConnected)
                    else
                      ...connectedPeers.map(
                        (peerId) => ListTile(
                          leading: const Icon(Icons.device_hub),
                          title: Text(
                            peerId,
                            style: const TextStyle(fontFamily: 'monospace'),
                          ),
                          subtitle: Text(l10n.connectedToP2P),
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

  Widget _buildConnectionStatus(P2PConnectionState state, AppLocalizations l10n) {
    IconData icon;
    Color color;
    String text;

    switch (state.status) {
      case P2PConnectionStatus.disconnected:
        icon = Icons.link_off;
        color = Colors.red;
        text = l10n.disconnected;
        break;
      case P2PConnectionStatus.connected:
        icon = Icons.link;
        color = Colors.green;
        text = l10n.connectedToP2P;
        break;
      case P2PConnectionStatus.peerConnected:
        icon = Icons.device_hub;
        color = Colors.blue;
        text = '${l10n.peerConnected}: ${state.peerId}';
        break;
      case P2PConnectionStatus.peerDisconnected:
        icon = Icons.device_hub_outlined;
        color = Colors.orange;
        text = '${l10n.peerDisconnected}: ${state.peerId}';
        break;
      case P2PConnectionStatus.dataReceived:
        icon = Icons.sync;
        color = Colors.purple;
        text = l10n.syncingData;
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
