import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pacey/l10n/app_localizations.dart';
import 'package:pacey/core/localization/locale_provider.dart';
import 'package:pacey/core/theme/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/backup/backup_settings_provider.dart';
import 'features/dashboard/dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const EnergyPacingApp(),
    ),
  );
}

class EnergyPacingApp extends ConsumerWidget {
  const EnergyPacingApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final localeNotifier = ref.read(localeProvider.notifier);
    final locale = localeNotifier.getEffectiveLocale();
    final themeMode = ref.watch(themeProvider);

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        ColorScheme lightColorScheme;
        ColorScheme darkColorScheme;

        if (lightDynamic != null && darkDynamic != null) {
          lightColorScheme = lightDynamic.harmonized();
          darkColorScheme = darkDynamic.harmonized();
        } else {
          // Fallback colors - Soothing Indigo/Lavender
          lightColorScheme = ColorScheme.fromSeed(
            seedColor: const Color(0xFF6750A4),
          );
          darkColorScheme = ColorScheme.fromSeed(
            seedColor: const Color(0xFF6750A4),
            brightness: Brightness.dark,
          );
        }

        return MaterialApp(
          key: ValueKey(locale),
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          locale: locale,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkColorScheme,
          ),
          themeMode: themeMode.themeMode,
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('he')],
          home: const DashboardPage(),
        );
      },
    );
  }
}
