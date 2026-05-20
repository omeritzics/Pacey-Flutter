// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Pacey';

  @override
  String healingLevel(int level) {
    return 'Healing Level $level';
  }

  @override
  String get stabilization => 'Stabilization';

  @override
  String get strengthening => 'Strengthening';

  @override
  String get expansion => 'Expansion';

  @override
  String get currentEnergy => 'Current Energy';

  @override
  String tasksForEnergy(int energy) {
    return 'Tasks for current energy level';
  }

  @override
  String get noTasks => 'No tasks for this energy level.';

  @override
  String get addTask => 'Add Task';

  @override
  String get editTask => 'Edit Task';

  @override
  String get taskTitle => 'Task Title';

  @override
  String get requiredEnergy => 'Required Energy';

  @override
  String get taskPriority => 'Priority';

  @override
  String get priorityHighest => '1 — Highest';

  @override
  String get priorityHigh => '2 — High';

  @override
  String get priorityMedium => '3 — Medium';

  @override
  String get priorityLow => '4 — Lowest';

  @override
  String get repeatCadence => 'Repeat';

  @override
  String get repeatCadenceHint =>
      'How often this task can be completed again after you finish it.';

  @override
  String get repeatOff => 'Does not repeat';

  @override
  String get repeatDaily => 'Daily';

  @override
  String get repeatWeekly => 'Weekly';

  @override
  String get repeatMonthly => 'Monthly';

  @override
  String availableAfter(String date) {
    return 'Available after $date';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get alreadyLogged =>
      'You have already logged your energy for this time block.';

  @override
  String get history => 'History';

  @override
  String get last7Days => 'Last 7 days';

  @override
  String get last30Days => 'Last 30 days';

  @override
  String get allTime => 'All the times';

  @override
  String get energyTrend => 'Energy Trend';

  @override
  String get energyLogs => 'Energy Logs';

  @override
  String get tasks => 'Tasks';

  @override
  String get noHistory => 'No history recorded yet.';

  @override
  String get energyUpdate => 'Energy Level Update';

  @override
  String get settings => 'Settings';

  @override
  String get about => 'About';

  @override
  String get aboutSubtitle => 'Licenses and open source notices';

  @override
  String get aboutApplicationLegalese =>
      'Copyright © 2026 Omer I.S. (@omeritzics)';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get followSystem => 'Follow System';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get importExport => 'Import / Export';

  @override
  String get importExportDescription =>
      'Back up your tasks, energy logs, and progress to a JSON file, or restore from a backup.';

  @override
  String get hideCompletedTasks => 'Hide completed tasks';

  @override
  String get hideCompletedTasksDescription =>
      'Do not show completed tasks on the dashboard';

  @override
  String get hideUnavailableTasks => 'Hide unavailable tasks';

  @override
  String get hideUnavailableTasksDescription =>
      'Do not show repeating tasks of another day';

  @override
  String get repeatDays => 'Repeat Days';

  @override
  String get selectWeekDays => 'Select weekdays';

  @override
  String get autoExport => 'Auto-Export';

  @override
  String get autoExportDescription =>
      'Automatically export a backup file when data changes';

  @override
  String get autoImport => 'Auto-Import';

  @override
  String get autoImportDescription =>
      'Automatically import data from a backup file when the app is opened';

  @override
  String get selectDirectory => 'Select Directory';

  @override
  String get exportData => 'Export data';

  @override
  String get exportDataDescription => 'Pacey backup file';

  @override
  String get importData => 'Import data';

  @override
  String get importModeDescription =>
      'Merge keeps your existing data and combines it with the backup. Replace deletes all local data before importing.';

  @override
  String get importMerge => 'Merge';

  @override
  String get importReplace => 'Replace all';

  @override
  String get exportFailed => 'Export failed. Please try again.';

  @override
  String get exportSuccessful => 'Data exported successfully.';

  @override
  String get importFailed =>
      'Import failed. Please check the file and try again.';

  @override
  String importSuccessful(int tasks, int logs) {
    return 'Imported $tasks tasks and $logs energy logs.';
  }

  @override
  String get dangerZone => 'Danger Zone';

  @override
  String get resetData => 'Reset Data';

  @override
  String get resetDataDescription =>
      'Delete all your tasks, logs, and statistics';

  @override
  String get confirmReset => 'Reset All Data?';

  @override
  String get confirmResetMessage =>
      'This will permanently delete all your data. This action cannot be undone.';

  @override
  String get reset => 'Reset';

  @override
  String get dataResetSuccessful => 'Data has been reset successfully';

  @override
  String get reminders => 'Reminders';

  @override
  String get remindersDescription =>
      'Manage reminders to log your energy amounts';

  @override
  String get morningReminder => 'Morning Reminder';

  @override
  String get morningReminderDescription =>
      'Reminder to log morning energy level';

  @override
  String get afternoonReminder => 'Afternoon Reminder';

  @override
  String get afternoonReminderDescription =>
      'Reminder to log afternoon energy level';

  @override
  String get eveningReminder => 'Evening Reminder';

  @override
  String get eveningReminderDescription =>
      'Reminder to log evening energy level';

  @override
  String get reminderTime => 'Time';

  @override
  String get desktopSettings => 'Desktop Settings';

  @override
  String get minimizeToTray => 'Minimize to Tray';

  @override
  String get minimizeToTrayDescription =>
      'Close window to system tray instead of exiting';

  @override
  String get startOnStartup => 'Start Pacey on Startup';

  @override
  String get startOnStartupDescription =>
      'Automatically launch Pacey when you log into your system';
}
