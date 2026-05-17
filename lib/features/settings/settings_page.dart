import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pacey/l10n/app_localizations.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/database/database_provider.dart';
import '../../core/theme/theme_provider.dart';
import '../backup/data_backup_screen.dart';
import '../gamification/gamification_provider.dart';

import '../energy/energy_provider.dart';
import '../tasks/task_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final localeNotifier = ref.watch(localeProvider.notifier);
    final currentLocale = ref.watch(localeProvider);
    final effectiveLocale = localeNotifier.getEffectiveLocale();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          // Language Section
          ListTile(
            title: Text(l10n.language),
            subtitle: Text(
              _getLanguageDisplayText(currentLocale, effectiveLocale, l10n),
            ),
            leading: const Icon(Icons.language),
            trailing: DropdownButton<Locale>(
              value: currentLocale.languageCode == "system"
                  ? const Locale("system")
                  : currentLocale,
              items: [
                DropdownMenuItem(
                  value: const Locale("system"),
                  child: Text(l10n.followSystem),
                ),
                DropdownMenuItem(
                  value: const Locale("en"),
                  child: Text("English"),
                ),
                DropdownMenuItem(
                  value: const Locale("he"),
                  child: Text("עברית"),
                ),
              ],
              onChanged: (Locale? newLocale) {
                if (newLocale != null) {
                  ref.read(localeProvider.notifier).setLocale(newLocale);
                }
              },
            ),
          ),
          const Divider(),

          // Theme Section
          ListTile(
            title: Text(l10n.darkMode),
            subtitle: Text(l10n.lightMode),
            leading: const Icon(Icons.dark_mode),
            trailing: DropdownButton<AppThemeMode>(
              value: ref.watch(themeProvider),
              items: [
                DropdownMenuItem(
                  value: AppThemeMode.system,
                  child: Text(l10n.followSystem),
                ),
                DropdownMenuItem(
                  value: AppThemeMode.light,
                  child: Text(l10n.lightMode),
                ),
                DropdownMenuItem(
                  value: AppThemeMode.dark,
                  child: Text(l10n.darkMode),
                ),
              ],
              onChanged: (AppThemeMode? newMode) {
                if (newMode != null) {
                  ref.read(themeProvider.notifier).setThemeMode(newMode);
                }
              },
            ),
          ),
          const Divider(),

          // Data backup
          ListTile(
            title: Text(l10n.importExport),
            subtitle: Text(l10n.importExportDescription),
            leading: const Icon(Icons.swap_vert),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DataBackupScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            title: Text(l10n.about),
            subtitle: Text(l10n.aboutSubtitle),
            leading: const Icon(Icons.info_outline),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: l10n.appTitle,
                applicationVersion: '1.0.0',
              );
            },
          ),
          const Divider(),

          // Danger Zone
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.dangerZone,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            title: Text(
              l10n.resetData,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            subtitle: Text(l10n.resetDataDescription),
            leading: Icon(
              Icons.delete_forever,
              color: Theme.of(context).colorScheme.error,
            ),
            onTap: () => _showResetConfirmation(context, ref, l10n),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmation(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmReset),
        content: Text(l10n.confirmResetMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              final appDb = ref.read(databaseProvider);
              final db = await appDb.database;
              await db.transaction((txn) async {
                await txn.delete('tasks');
                await txn.delete('energy_logs');
                await txn.delete('pacing_stats');
              });

              // Invalidate providers to refresh UI
              ref.invalidate(pacingStatsProvider);
              ref.invalidate(energyLevelProvider);
              ref.invalidate(tasksProvider);

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.dataResetSuccessful)),
                );
              }
            },
            child: Text(
              l10n.reset,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  String _getLanguageDisplayText(
    Locale currentLocale,
    Locale effectiveLocale,
    AppLocalizations l10n,
  ) {
    if (currentLocale.languageCode == 'system') {
      final effectiveLang = effectiveLocale.languageCode == 'en'
          ? 'English'
          : 'עברית';
      return '${l10n.followSystem} ($effectiveLang)';
    } else {
      return currentLocale.languageCode == 'en' ? 'English' : 'עברית';
    }
  }
}
