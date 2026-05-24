import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pacey/l10n/app_localizations.dart';

import '../../core/sync/crdt_database_provider.dart';
import '../../core/sync/device_pairing_provider.dart';

class CrdtSyncScreen extends ConsumerStatefulWidget {
  const CrdtSyncScreen({super.key});

  @override
  ConsumerState<CrdtSyncScreen> createState() => _CrdtSyncScreenState();
}

class _CrdtSyncScreenState extends ConsumerState<CrdtSyncScreen> {
  bool _isWorking = false;
  bool _isScanning = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Initialization is handled in build method using addPostFrameCallback
  }

  Future<void> _exportChangeset() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isWorking = true);

    try {
      final crdtDbAsync = ref.read(crdtDatabaseProvider);
      final crdtDb = crdtDbAsync.value;
      if (crdtDb == null) {
        if (mounted) _showError(l10n.exportSyncFailed);
        return;
      }
      final encryptedData = await crdtDb.exportChangeset();

      final timestamp = DateTime.now().toUtc().toIso8601String().replaceAll(
        ':',
        '-',
      );
      final fileName = 'pacey-sync-$timestamp.enc';

      final bytes = Uint8List.fromList(encryptedData.codeUnits);
      final outputFile = await FilePicker.saveFile(
        dialogTitle: l10n.exportSyncData,
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['enc'],
        bytes: bytes,
      );

      if (outputFile == null) return;

      if (!Platform.isAndroid && !Platform.isIOS) {
        final file = File(outputFile);
        await file.writeAsBytes(bytes);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.exportSyncSuccessful)),
      );
    } catch (e) {
      if (mounted) _showError(l10n.exportSyncFailed);
    } finally {
      if (mounted) setState(() => _isWorking = false);
    }
  }

  Future<void> _importChangeset() async {
    final l10n = AppLocalizations.of(context)!;

    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['enc'],
      withData: true,
    );
    if (result == null || result.files.isEmpty || !mounted) return;

    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null && file.path == null) {
      _showError(l10n.importSyncFailed);
      return;
    }

    setState(() => _isWorking = true);
    try {
      final encryptedData = bytes != null
          ? String.fromCharCodes(bytes)
          : await File(file.path!).readAsString();

      final crdtDbAsync = ref.read(crdtDatabaseProvider);
      final crdtDb = crdtDbAsync.value;
      if (crdtDb == null) {
        if (mounted) _showError(l10n.importSyncFailed);
        return;
      }
      await crdtDb.importChangeset(encryptedData);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.importSyncSuccessful)),
      );
    } catch (e) {
      if (mounted) _showError(l10n.importSyncFailed);
    } finally {
      if (mounted) setState(() => _isWorking = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
              const SizedBox(height: 24),
              const Divider(),
              
              // Manual Export/Import
              Text(
                l10n.syncDataDescription,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _isWorking ? null : _exportChangeset,
                icon: const Icon(Icons.upload_file),
                label: Text(l10n.exportSyncData),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _isWorking ? null : _importChangeset,
                icon: const Icon(Icons.download),
                label: Text(l10n.importSyncData),
              ),
              if (_isWorking) ...[
                const SizedBox(height: 24),
                const Center(child: CircularProgressIndicator()),
              ],
              const SizedBox(height: 32),
              const Divider(),
              Text(
                l10n.syncDataInfo,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          );
        },
      ),
    );
  }
}
