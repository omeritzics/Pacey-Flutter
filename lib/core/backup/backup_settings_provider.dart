import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

class BackupSettings {
  final bool isAutoExportEnabled;
  final String? autoExportPath;

  const BackupSettings({
    this.isAutoExportEnabled = false,
    this.autoExportPath,
  });

  BackupSettings copyWith({
    bool? isAutoExportEnabled,
    String? autoExportPath,
    bool clearAutoExportPath = false,
  }) {
    return BackupSettings(
      isAutoExportEnabled: isAutoExportEnabled ?? this.isAutoExportEnabled,
      autoExportPath: clearAutoExportPath
          ? null
          : (autoExportPath ?? this.autoExportPath),
    );
  }
}

class BackupSettingsNotifier extends Notifier<BackupSettings> {
  static const _keyEnabled = 'autoExportEnabled';
  static const _keyPath = 'autoExportPath';

  @override
  BackupSettings build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return BackupSettings(
      isAutoExportEnabled: prefs.getBool(_keyEnabled) ?? false,
      autoExportPath: prefs.getString(_keyPath),
    );
  }

  Future<void> setAutoExportEnabled(bool enabled) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_keyEnabled, enabled);
    state = state.copyWith(isAutoExportEnabled: enabled);
  }

  Future<void> setAutoExportPath(String? path) async {
    final prefs = ref.read(sharedPreferencesProvider);
    if (path == null) {
      await prefs.remove(_keyPath);
      state = state.copyWith(clearAutoExportPath: true);
    } else {
      await prefs.setString(_keyPath, path);
      state = state.copyWith(autoExportPath: path);
    }
  }
}

final backupSettingsProvider =
    NotifierProvider<BackupSettingsNotifier, BackupSettings>(
  () => BackupSettingsNotifier(),
);
