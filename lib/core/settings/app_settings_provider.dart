import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io' show Platform;
import 'package:pacey/core/desktop/desktop_startup_manager.dart';
import '../backup/backup_settings_provider.dart';

class AppSettings {
  final bool hideCompletedTasks;
  final bool hideUnavailableTasks;
  final bool minimizeToTray;
  final bool startOnStartup;

  const AppSettings({
    this.hideCompletedTasks = true,
    this.hideUnavailableTasks = true,
    this.minimizeToTray = true,
    this.startOnStartup = false,
  });

  AppSettings copyWith({
    bool? hideCompletedTasks,
    bool? hideUnavailableTasks,
    bool? minimizeToTray,
    bool? startOnStartup,
  }) {
    return AppSettings(
      hideCompletedTasks: hideCompletedTasks ?? this.hideCompletedTasks,
      hideUnavailableTasks: hideUnavailableTasks ?? this.hideUnavailableTasks,
      minimizeToTray: minimizeToTray ?? this.minimizeToTray,
      startOnStartup: startOnStartup ?? this.startOnStartup,
    );
  }
}

class AppSettingsNotifier extends Notifier<AppSettings> {
  static const _keyHideCompleted = 'hideCompletedTasks';
  static const _keyHideUnavailable = 'hideUnavailableTasks';
  static const _keyMinimizeToTray = 'minimizeToTray';
  static const _keyStartOnStartup = 'startOnStartup';

  @override
  AppSettings build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return AppSettings(
      hideCompletedTasks: prefs.getBool(_keyHideCompleted) ?? true,
      hideUnavailableTasks: prefs.getBool(_keyHideUnavailable) ?? true,
      minimizeToTray: prefs.getBool(_keyMinimizeToTray) ?? true,
      startOnStartup: prefs.getBool(_keyStartOnStartup) ?? false,
    );
  }

  Future<void> setHideCompletedTasks(bool value) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_keyHideCompleted, value);
    state = state.copyWith(hideCompletedTasks: value);
  }

  Future<void> setHideUnavailableTasks(bool value) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_keyHideUnavailable, value);
    state = state.copyWith(hideUnavailableTasks: value);
  }

  Future<void> setMinimizeToTray(bool value) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_keyMinimizeToTray, value);
    state = state.copyWith(minimizeToTray: value);
  }

  Future<void> setStartOnStartup(bool value) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_keyStartOnStartup, value);
    state = state.copyWith(startOnStartup: value);

    final isDesktop = (Platform.isWindows || Platform.isLinux || Platform.isMacOS);
    if (isDesktop) {
      await DesktopStartupManager.setEnabled(value);
    }
  }
}

final appSettingsProvider = NotifierProvider<AppSettingsNotifier, AppSettings>(
  () => AppSettingsNotifier(),
);
