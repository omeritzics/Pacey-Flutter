import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pacey/l10n/app_localizations.dart';
import '../../core/localization/locale_provider.dart';
import '../p2p/p2p_screen.dart';

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
