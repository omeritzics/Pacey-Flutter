import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pacey/l10n/app_localizations.dart';

import '../../core/backup/backup_provider.dart';
import '../../core/backup/backup_settings_provider.dart';
import '../../core/backup/backup_service.dart';
import '../../core/database/database_provider.dart';
import '../energy/energy_provider.dart';

import '../tasks/task_provider.dart';

class DataBackupScreen extends ConsumerStatefulWidget {
  const DataBackupScreen({super.key});

  @override
  ConsumerState<DataBackupScreen> createState() => _DataBackupScreenState();
}

class _DataBackupScreenState extends ConsumerState<DataBackupScreen> {
  bool _isWorking = false;

  Future<void> _exportData() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isWorking = true);

    try {
      final appDb = ref.read(databaseProvider);
      final backupService = ref.read(backupServiceProvider);
      final json = await backupService.exportData(appDb);

      final timestamp = DateTime.now().toUtc().toIso8601String().replaceAll(':', '-');
      final fileName = 'pacey-backup-$timestamp.json';

      final outputFile = await FilePicker.platform.saveFile(
        dialogTitle: l10n.exportData,
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (outputFile == null) return;

      final file = File(outputFile);
      await file.writeAsString(json);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.exportSuccessful)),
      );
    } on BackupException catch (e) {
      if (mounted) _showError(e.message);
    } catch (_) {
      if (mounted) _showError(l10n.exportFailed);
    } finally {
      if (mounted) setState(() => _isWorking = false);
    }
  }

  Future<void> _importData() async {
    final l10n = AppLocalizations.of(context)!;
    final mode = await _showImportModeDialog();
    if (mode == null || !mounted) return;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );
    if (result == null || result.files.isEmpty || !mounted) return;

    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null && file.path == null) {
      _showError(l10n.importFailed);
      return;
    }

    setState(() => _isWorking = true);
    try {
      final jsonString = bytes != null
          ? String.fromCharCodes(bytes)
          : await File(file.path!).readAsString();

      final appDb = ref.read(databaseProvider);
      final backupService = ref.read(backupServiceProvider);
      final importResult = await backupService.importData(
        appDb,
        jsonString,
        mode: mode,
      );


      ref.invalidate(energyLevelProvider);
      ref.invalidate(tasksProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.importSuccessful(
              importResult.tasksImported,
              importResult.energyLogsImported,
            ),
          ),
        ),
      );
    } on BackupException catch (e) {
      if (mounted) _showError(e.message);
    } catch (_) {
      if (mounted) _showError(l10n.importFailed);
    } finally {
      if (mounted) setState(() => _isWorking = false);
    }
  }

  Future<ImportMode?> _showImportModeDialog() {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<ImportMode>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.importData),
        content: Text(l10n.importModeDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ImportMode.merge),
            child: Text(l10n.importMerge),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ImportMode.replace),
            child: Text(
              l10n.importReplace,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.importExport)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.importExportDescription,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _isWorking ? null : _exportData,
            icon: const Icon(Icons.upload_file),
            label: Text(l10n.exportData),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _isWorking ? null : _importData,
            icon: const Icon(Icons.download),
            label: Text(l10n.importData),
          ),
          if (_isWorking) ...[
            const SizedBox(height: 24),
            const Center(child: CircularProgressIndicator()),
          ],
          const SizedBox(height: 32),
          const Divider(),
          SwitchListTile(
            title: Text(l10n.autoExport),
            subtitle: Text(l10n.autoExportDescription),
            value: ref.watch(backupSettingsProvider).isAutoExportEnabled,
            onChanged: (value) {
              ref.read(backupSettingsProvider.notifier).setAutoExportEnabled(value);
            },
            contentPadding: EdgeInsets.zero,
          ),
          if (ref.watch(backupSettingsProvider).isAutoExportEnabled) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    ref.watch(backupSettingsProvider).autoExportPath ?? 'Default Directory',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final directory = await FilePicker.platform.getDirectoryPath();
                    if (directory != null) {
                      final path = '$directory/pacey_auto_backup.json';
                      await ref.read(backupSettingsProvider.notifier).setAutoExportPath(path);
                      if (context.mounted) {
                        ref.read(backupServiceProvider).autoExport(
                              ref.read(databaseProvider),
                              path: path,
                            );
                      }
                    }
                  },
                  child: Text(l10n.selectDirectory),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
