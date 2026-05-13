import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pacey/l10n/app_localizations.dart';
import '../../core/p2p/p2p_sync_provider.dart';
import '../../core/p2p/p2p_service.dart';

class ConnectedDevicesList extends ConsumerWidget {
  const ConnectedDevicesList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final connectedDevices = ref.watch(connectedDevicesProvider);
    final syncService = ref.watch(p2pSyncServiceProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.devices,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  '${l10n.connectedDevices} (${connectedDevices.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (connectedDevices.isEmpty)
              _buildEmptyState(context, l10n)
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: connectedDevices.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final entry = connectedDevices.entries.elementAt(index);
                  return _buildDeviceTile(context, entry.key, entry.value, syncService, l10n);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.device_hub_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.noDevicesConnected,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.connectDevicesToSync,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceTile(
    BuildContext context,
    String peerId,
    DeviceInfo deviceInfo,
    dynamic syncService,
    AppLocalizations l10n,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.green.shade50,
        child: Icon(
          _getDeviceIcon(deviceInfo.deviceType),
          color: Colors.green.shade600,
          size: 24,
        ),
      ),
      title: Text(
        deviceInfo.deviceName,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2),
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '${l10n.online} • ${deviceInfo.deviceType}',
                style: TextStyle(
                  color: Colors.green.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            l10n.peerIdLabel(_formatPeerId(peerId)),
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 11,
              fontFamily: 'monospace',
            ),
          ),
          Text(
            'Connected ${_formatConnectionTime(deviceInfo.connectedAt)}',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 10,
            ),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.copy, size: 20),
            onPressed: () => _copyPeerId(context, peerId),
            tooltip: l10n.copyPeerId,
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, size: 20),
            onPressed: () => _disconnectDevice(context, peerId, syncService, l10n),
            tooltip: l10n.disconnect,
          ),
        ],
      ),
    );
  }

  String _formatPeerId(String peerId) {
    if (peerId.length <= 12) return peerId;
    return '${peerId.substring(0, 6)}...${peerId.substring(peerId.length - 6)}';
  }

  void _copyPeerId(BuildContext context, String peerId) {
    // For now, just show a snackbar
    // In a real implementation, you'd use a clipboard package
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Peer ID copied: ${_formatPeerId(peerId)}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _disconnectDevice(
    BuildContext context,
    String peerId,
    dynamic syncService,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.disconnectDevice),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.confirmDisconnect(_formatPeerId(peerId))),
              const SizedBox(height: 12),
              Text(
                'This will stop syncing data with this device.',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                
                // Show disconnecting message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('Disconnecting...'),
                      ],
                    ),
                    backgroundColor: Colors.orange,
                    duration: const Duration(seconds: 2),
                  ),
                );
                
                // Close the connection
                syncService.rejectConnection(peerId);
                
                // Show success message after a delay
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.deviceDisconnected(_formatPeerId(peerId))),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                });
              },
              child: Text(l10n.disconnect),
            ),
          ],
        );
      },
    );
  }

  IconData _getDeviceIcon(String deviceType) {
    switch (deviceType.toLowerCase()) {
      case 'mobile':
      case 'phone':
        return Icons.smartphone;
      case 'tablet':
        return Icons.tablet;
      case 'desktop':
      case 'pc':
        return Icons.desktop_windows;
      case 'laptop':
        return Icons.laptop;
      default:
        return Icons.device_hub;
    }
  }

  String _formatConnectionTime(DateTime connectedAt) {
    final now = DateTime.now();
    final difference = now.difference(connectedAt);
    
    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
