import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pacey/l10n/app_localizations.dart';

import '../../core/sync/device_pairing_service.dart';
import '../../core/sync/device_pairing_provider.dart';
import '../../core/sync/crdt_database_provider.dart';

class DevicePairingScreen extends ConsumerStatefulWidget {
  const DevicePairingScreen({super.key});

  @override
  ConsumerState<DevicePairingScreen> createState() =>
      _DevicePairingScreenState();
}

class _DevicePairingScreenState extends ConsumerState<DevicePairingScreen> {
  bool _isInitialized = false;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    final crdtDbAsync = ref.watch(crdtDatabaseProvider);
    final crdtDb = crdtDbAsync.value;
    final pairingService = ref.read(devicePairingServiceProvider);
    if (crdtDb != null) {
      await pairingService.initialize(crdtDb);
      setState(() => _isInitialized = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pairingService = ref.watch(devicePairingServiceProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.devicePairing)),
      body: _isInitialized
          ? ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Device Info Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.thisDevice,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'ID: ${pairingService.deviceId}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          'Name: ${pairingService.deviceName}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // QR Code Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          l10n.shareDeviceId,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: QrImageView(
                            data: pairingService.generatePairingCode(),
                            version: QrVersions.auto,
                            size: 200.0,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.scanToPair,
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Scan QR Code Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          l10n.scanDevice,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        if (_isScanning)
                          SizedBox(
                            height: 250,
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
                          ),
                        if (_isScanning)
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
                const SizedBox(height: 24),

                // Paired Devices Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.pairedDevices,
                          style: Theme.of(context).textTheme.titleMedium,
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
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  void _handleQRCodeScan(String qrCode, DevicePairingService pairingService) async {
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

  Future<void> _connectToDevice(DeviceInfo device, DevicePairingService pairingService) async {
    await pairingService.connectToDevice(device);
  }

  Future<void> _removeDevice(String deviceId, DevicePairingService pairingService) async {
    await pairingService.removePairedDevice(deviceId);
  }
}
