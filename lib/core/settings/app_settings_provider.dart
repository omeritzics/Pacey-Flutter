import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../backup/backup_settings_provider.dart';

class AppSettings {
  final bool hideCompletedTasks;
  final bool hideUnavailableTasks;

  const AppSettings({
    this.hideCompletedTasks = true,
    this.hideUnavailableTasks = true,
  });

  AppSettings copyWith({
    bool? hideCompletedTasks,
    bool? hideUnavailableTasks,
  }) {
    return AppSettings(
      hideCompletedTasks: hideCompletedTasks ?? this.hideCompletedTasks,
      hideUnavailableTasks: hideUnavailableTasks ?? this.hideUnavailableTasks,
    );
  }
}

class AppSettingsNotifier extends Notifier<AppSettings> {
  static const _keyHideCompleted = 'hideCompletedTasks';
  static const _keyHideUnavailable = 'hideUnavailableTasks';

  @override
  AppSettings build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return AppSettings(
      hideCompletedTasks: prefs.getBool(_keyHideCompleted) ?? true,
      hideUnavailableTasks: prefs.getBool(_keyHideUnavailable) ?? true,
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
}

final appSettingsProvider = NotifierProvider<AppSettingsNotifier, AppSettings>(
  () => AppSettingsNotifier(),
);
