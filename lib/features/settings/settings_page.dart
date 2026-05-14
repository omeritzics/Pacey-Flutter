import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pacey/l10n/app_localizations.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/database/database_provider.dart';
import '../p2p/p2p_screen.dart';
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
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
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
              value: currentLocale,
              items: [
                DropdownMenuItem(
                  value: const Locale('system'),
                  child: Text(l10n.followSystem),
                ),
                DropdownMenuItem(
                  value: const Locale('en'),
                  child: Text('English'),
                ),
                DropdownMenuItem(
                  value: const Locale('he'),
                  child: Text('עברית'),
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
          
          // Sync Section
          ListTile(
            title: Text(l10n.p2pSync),
            subtitle: Text(l10n.syncSettings),
            leading: const Icon(Icons.sync),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const P2PScreen()),
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
              final db = ref.read(databaseProvider);
              await db.transaction(() async {
                await db.delete(db.tasks).go();
                await db.delete(db.energyLogs).go();
                await db.delete(db.pacingStats).go();
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

  String _getLanguageDisplayText(Locale currentLocale, Locale effectiveLocale, AppLocalizations l10n) {
    if (currentLocale.languageCode == 'system') {
      final effectiveLang = effectiveLocale.languageCode == 'en' ? 'English' : 'עברית';
      return '${l10n.followSystem} ($effectiveLang)';
    } else {
      return currentLocale.languageCode == 'en' ? 'English' : 'עברית';
    }
  }
}
