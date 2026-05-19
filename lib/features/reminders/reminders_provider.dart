import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/backup/backup_settings_provider.dart';
import 'notification_service.dart';

class ReminderSetting {
  final bool enabled;
  final int hour;
  final int minute;

  const ReminderSetting({
    required this.enabled,
    required this.hour,
    required this.minute,
  });

  ReminderSetting copyWith({
    bool? enabled,
    int? hour,
    int? minute,
  }) {
    return ReminderSetting(
      enabled: enabled ?? this.enabled,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
    );
  }
}

class RemindersState {
  final ReminderSetting morning;
  final ReminderSetting afternoon;
  final ReminderSetting evening;

  const RemindersState({
    required this.morning,
    required this.afternoon,
    required this.evening,
  });

  RemindersState copyWith({
    ReminderSetting? morning,
    ReminderSetting? afternoon,
    ReminderSetting? evening,
  }) {
    return RemindersState(
      morning: morning ?? this.morning,
      afternoon: afternoon ?? this.afternoon,
      evening: evening ?? this.evening,
    );
  }
}

class RemindersNotifier extends Notifier<RemindersState> {
  static const _keyMorningEnabled = 'reminder_morning_enabled';
  static const _keyMorningHour = 'reminder_morning_hour';
  static const _keyMorningMinute = 'reminder_morning_minute';

  static const _keyAfternoonEnabled = 'reminder_afternoon_enabled';
  static const _keyAfternoonHour = 'reminder_afternoon_hour';
  static const _keyAfternoonMinute = 'reminder_afternoon_minute';

  static const _keyEveningEnabled = 'reminder_evening_enabled';
  static const _keyEveningHour = 'reminder_evening_hour';
  static const _keyEveningMinute = 'reminder_evening_minute';

  @override
  RemindersState build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return RemindersState(
      morning: ReminderSetting(
        enabled: prefs.getBool(_keyMorningEnabled) ?? true,
        hour: prefs.getInt(_keyMorningHour) ?? 9,
        minute: prefs.getInt(_keyMorningMinute) ?? 0,
      ),
      afternoon: ReminderSetting(
        enabled: prefs.getBool(_keyAfternoonEnabled) ?? true,
        hour: prefs.getInt(_keyAfternoonHour) ?? 14,
        minute: prefs.getInt(_keyAfternoonMinute) ?? 0,
      ),
      evening: ReminderSetting(
        enabled: prefs.getBool(_keyEveningEnabled) ?? true,
        hour: prefs.getInt(_keyEveningHour) ?? 20,
        minute: prefs.getInt(_keyEveningMinute) ?? 0,
      ),
    );
  }

  Future<void> updateMorning({bool? enabled, int? hour, int? minute}) async {
    final prefs = ref.read(sharedPreferencesProvider);
    final next = state.morning.copyWith(enabled: enabled, hour: hour, minute: minute);
    if (enabled != null) await prefs.setBool(_keyMorningEnabled, enabled);
    if (hour != null) await prefs.setInt(_keyMorningHour, hour);
    if (minute != null) await prefs.setInt(_keyMorningMinute, minute);
    state = state.copyWith(morning: next);
    await _scheduleNotifications();
  }

  Future<void> updateAfternoon({bool? enabled, int? hour, int? minute}) async {
    final prefs = ref.read(sharedPreferencesProvider);
    final next = state.afternoon.copyWith(enabled: enabled, hour: hour, minute: minute);
    if (enabled != null) await prefs.setBool(_keyAfternoonEnabled, enabled);
    if (hour != null) await prefs.setInt(_keyAfternoonHour, hour);
    if (minute != null) await prefs.setInt(_keyAfternoonMinute, minute);
    state = state.copyWith(afternoon: next);
    await _scheduleNotifications();
  }

  Future<void> updateEvening({bool? enabled, int? hour, int? minute}) async {
    final prefs = ref.read(sharedPreferencesProvider);
    final next = state.evening.copyWith(enabled: enabled, hour: hour, minute: minute);
    if (enabled != null) await prefs.setBool(_keyEveningEnabled, enabled);
    if (hour != null) await prefs.setInt(_keyEveningHour, hour);
    if (minute != null) await prefs.setInt(_keyEveningMinute, minute);
    state = state.copyWith(evening: next);
    await _scheduleNotifications();
  }

  Future<void> _scheduleNotifications() async {
    await ref.read(notificationServiceProvider).scheduleReminders(state);
  }
}

final remindersProvider = NotifierProvider<RemindersNotifier, RemindersState>(
  () => RemindersNotifier(),
);
