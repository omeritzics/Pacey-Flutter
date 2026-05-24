import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pacey/l10n/app_localizations.dart';

import '../../core/sync/crdt_database_provider.dart';
import '../../core/sync/device_pairing_provider.dart';

import 'package:mobile_scanner/mobile_scanner.dart';

class CrdtSyncScreen extends ConsumerStatefulWidget {
  const CrdtSyncScreen({super.key});

  @override
  ConsumerState<CrdtSyncScreen> createState() => _CrdtSyncScreenState();
}

class _CrdtSyncScreenState extends ConsumerState<CrdtSyncScreen> {
  bool _isScanning = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Initialization is handled in build method using addPostFrameCallback
  }




  void _handleQRCodeScan(String qrCode, dynamic pairingService) async {
    setState(() => _isScanning = false);

    final success = await pairingService.pairDevice(qrCode);
    
    if (!mounted) return;

    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? l10n.pairingSuccess : l10n.pairingFailed),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _connectToDevice(dynamic device, dynamic pairingService) async {
    await pairingService.connectToDevice(device);
  }

  Future<void> _removeDevice(String deviceId, dynamic pairingService) async {
    await pairingService.removePairedDevice(deviceId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final crdtDbAsync = ref.watch(crdtDatabaseProvider);
    final pairingService = ref.watch(devicePairingServiceProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.syncData)),
      body: crdtDbAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (crdtDb) {
          if (!_isInitialized) {
            // Initialize pairing service if not already initialized
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              await pairingService.initialize(crdtDb);
              if (mounted) setState(() => _isInitialized = true);
            });
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Real-time sync status
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        pairingService.isConnected
                            ? Icons.cloud_done
                            : Icons.cloud_off,
                        color: pairingService.isConnected
                            ? Colors.green
                            : Colors.grey,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.realTimeSync,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              pairingService.isConnected
                                  ? l10n.connected
                                  : l10n.disconnected,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: pairingService.isConnected
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      if (pairingService.connectedDevice != null)
                        Text(
                          pairingService.connectedDevice!.deviceName,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              
              // Device Pairing Section
              Text(
                l10n.devicePairing,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              
              // Device Info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.thisDevice,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ID: ${pairingService.deviceId ?? 'Loading...'}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        'Name: ${pairingService.deviceName ?? 'Loading...'}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // QR Code
              if (pairingService.deviceId != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          l10n.shareDeviceId,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: QrImageView(
                            data: pairingService.generatePairingCode(),
                            version: QrVersions.auto,
                            size: 150.0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.scanToPair,
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              if (pairingService.deviceId != null) const SizedBox(height: 16),
              
              // Scan QR Code
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        l10n.scanDevice,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 16),
                      if (!Platform.isWindows && !Platform.isLinux)
                        if (_isScanning)
                          SizedBox(
                            height: 200,
                            child: MobileScanner(
                              onDetect: (capture) {
                                final barcode = capture.barcodes.first;
                                if (barcode.rawValue != null) {
                                  _handleQRCodeScan(barcode.rawValue!, pairingService);
                                }
                              },
                            ),
                          )
                        else
                          FilledButton.icon(
                            onPressed: () {
                              setState(() => _isScanning = true);
                            },
                            icon: const Icon(Icons.qr_code_scanner),
                            label: Text(l10n.startScanning),
                          )
                      else
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'QR scanning is not supported on this platform.\nPlease use the manual import/export feature instead.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      if (!Platform.isWindows && !Platform.isLinux && _isScanning)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: OutlinedButton.icon(
                            onPressed: () {
                              setState(() => _isScanning = false);
                            },
                            icon: const Icon(Icons.close),
                            label: Text(l10n.cancel),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Paired Devices
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.pairedDevices,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 16),
                      if (pairingService.pairedDevices.isEmpty)
                        Text(
                          l10n.noPairedDevices,
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      else
                        ...pairingService.pairedDevices.map((device) {
                          return ListTile(
                            title: Text(device.deviceName),
                            subtitle: Text('ID: ${device.deviceId}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (pairingService.connectedDevice?.deviceId ==
                                    device.deviceId)
                                  const Icon(Icons.check_circle,
                                      color: Colors.green),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () =>
                                      _removeDevice(device.deviceId, pairingService),
                                ),
                              ],
                            ),
                            onTap: () => _connectToDevice(device, pairingService),
                          );
                        }),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
