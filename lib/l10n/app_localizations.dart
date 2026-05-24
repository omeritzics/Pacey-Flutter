import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_he.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('he'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Pacey'**
  String get appTitle;

  /// No description provided for @healingLevel.
  ///
  /// In en, this message translates to:
  /// **'Healing Level {level}'**
  String healingLevel(int level);

  /// No description provided for @stabilization.
  ///
  /// In en, this message translates to:
  /// **'Stabilization'**
  String get stabilization;

  /// No description provided for @strengthening.
  ///
  /// In en, this message translates to:
  /// **'Strengthening'**
  String get strengthening;

  /// No description provided for @expansion.
  ///
  /// In en, this message translates to:
  /// **'Expansion'**
  String get expansion;

  /// No description provided for @currentEnergy.
  ///
  /// In en, this message translates to:
  /// **'Current Energy'**
  String get currentEnergy;

  /// No description provided for @tasksForEnergy.
  ///
  /// In en, this message translates to:
  /// **'Tasks for current energy level'**
  String tasksForEnergy(int energy);

  /// No description provided for @noTasks.
  ///
  /// In en, this message translates to:
  /// **'No tasks for this energy level.'**
  String get noTasks;

  /// No description provided for @addTask.
  ///
  /// In en, this message translates to:
  /// **'Add Task'**
  String get addTask;

  /// No description provided for @editTask.
  ///
  /// In en, this message translates to:
  /// **'Edit Task'**
  String get editTask;

  /// No description provided for @taskTitle.
  ///
  /// In en, this message translates to:
  /// **'Task Title'**
  String get taskTitle;

  /// No description provided for @requiredEnergy.
  ///
  /// In en, this message translates to:
  /// **'Required Energy'**
  String get requiredEnergy;

  /// No description provided for @taskPriority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get taskPriority;

  /// No description provided for @priorityHighest.
  ///
  /// In en, this message translates to:
  /// **'1 — Highest'**
  String get priorityHighest;

  /// No description provided for @priorityHigh.
  ///
  /// In en, this message translates to:
  /// **'2 — High'**
  String get priorityHigh;

  /// No description provided for @priorityMedium.
  ///
  /// In en, this message translates to:
  /// **'3 — Medium'**
  String get priorityMedium;

  /// No description provided for @priorityLow.
  ///
  /// In en, this message translates to:
  /// **'4 — Lowest'**
  String get priorityLow;

  /// No description provided for @repeatCadence.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeatCadence;

  /// No description provided for @repeatCadenceHint.
  ///
  /// In en, this message translates to:
  /// **'How often this task can be completed again after you finish it.'**
  String get repeatCadenceHint;

  /// No description provided for @repeatOff.
  ///
  /// In en, this message translates to:
  /// **'Does not repeat'**
  String get repeatOff;

  /// No description provided for @repeatDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get repeatDaily;

  /// No description provided for @repeatWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get repeatWeekly;

  /// No description provided for @repeatMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get repeatMonthly;

  /// No description provided for @availableAfter.
  ///
  /// In en, this message translates to:
  /// **'Available after {date}'**
  String availableAfter(String date);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @alreadyLogged.
  ///
  /// In en, this message translates to:
  /// **'You have already logged your energy for this time block.'**
  String get alreadyLogged;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @last7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get last7Days;

  /// No description provided for @last30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get last30Days;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All the times'**
  String get allTime;

  /// No description provided for @energyTrend.
  ///
  /// In en, this message translates to:
  /// **'Energy Trend'**
  String get energyTrend;

  /// No description provided for @energyLogs.
  ///
  /// In en, this message translates to:
  /// **'Energy Logs'**
  String get energyLogs;

  /// No description provided for @tasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// No description provided for @noHistory.
  ///
  /// In en, this message translates to:
  /// **'No history recorded yet.'**
  String get noHistory;

  /// No description provided for @energyUpdate.
  ///
  /// In en, this message translates to:
  /// **'Energy Level Update'**
  String get energyUpdate;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Licenses and open source notices'**
  String get aboutSubtitle;

  /// No description provided for @aboutApplicationLegalese.
  ///
  /// In en, this message translates to:
  /// **'Copyright © 2026 Omer I.S. (@omeritzics)'**
  String get aboutApplicationLegalese;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @followSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow System'**
  String get followSystem;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @importExport.
  ///
  /// In en, this message translates to:
  /// **'Import / Export'**
  String get importExport;

  /// No description provided for @importExportDescription.
  ///
  /// In en, this message translates to:
  /// **'Back up your tasks, energy logs, and progress to a JSON file, or restore from a backup.'**
  String get importExportDescription;

  /// No description provided for @hideCompletedTasks.
  ///
  /// In en, this message translates to:
  /// **'Hide completed tasks'**
  String get hideCompletedTasks;

  /// No description provided for @hideCompletedTasksDescription.
  ///
  /// In en, this message translates to:
  /// **'Do not show completed tasks on the dashboard'**
  String get hideCompletedTasksDescription;

  /// No description provided for @hideUnavailableTasks.
  ///
  /// In en, this message translates to:
  /// **'Hide unavailable tasks'**
  String get hideUnavailableTasks;

  /// No description provided for @hideUnavailableTasksDescription.
  ///
  /// In en, this message translates to:
  /// **'Do not show repeating tasks of another day'**
  String get hideUnavailableTasksDescription;

  /// No description provided for @repeatDays.
  ///
  /// In en, this message translates to:
  /// **'Repeat Days'**
  String get repeatDays;

  /// No description provided for @selectWeekDays.
  ///
  /// In en, this message translates to:
  /// **'Select weekdays'**
  String get selectWeekDays;

  /// No description provided for @autoExport.
  ///
  /// In en, this message translates to:
  /// **'Auto-Export'**
  String get autoExport;

  /// No description provided for @autoExportDescription.
  ///
  /// In en, this message translates to:
  /// **'Automatically export a backup file when data changes'**
  String get autoExportDescription;

  /// No description provided for @autoImport.
  ///
  /// In en, this message translates to:
  /// **'Auto-Import'**
  String get autoImport;

  /// No description provided for @autoImportDescription.
  ///
  /// In en, this message translates to:
  /// **'Automatically import data from a backup file when the app is opened'**
  String get autoImportDescription;

  /// No description provided for @selectDirectory.
  ///
  /// In en, this message translates to:
  /// **'Select Directory'**
  String get selectDirectory;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export data'**
  String get exportData;

  /// No description provided for @exportDataDescription.
  ///
  /// In en, this message translates to:
  /// **'Pacey backup file'**
  String get exportDataDescription;

  /// No description provided for @importData.
  ///
  /// In en, this message translates to:
  /// **'Import data'**
  String get importData;

  /// No description provided for @importModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Merge keeps your existing data and combines it with the backup. Replace deletes all local data before importing.'**
  String get importModeDescription;

  /// No description provided for @importMerge.
  ///
  /// In en, this message translates to:
  /// **'Merge'**
  String get importMerge;

  /// No description provided for @importReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace all'**
  String get importReplace;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed. Please try again.'**
  String get exportFailed;

  /// No description provided for @exportSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Data exported successfully.'**
  String get exportSuccessful;

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed. Please check the file and try again.'**
  String get importFailed;

  /// No description provided for @importSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Imported {tasks} tasks and {logs} energy logs.'**
  String importSuccessful(int tasks, int logs);

  /// No description provided for @dangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get dangerZone;

  /// No description provided for @resetData.
  ///
  /// In en, this message translates to:
  /// **'Reset Data'**
  String get resetData;

  /// No description provided for @resetDataDescription.
  ///
  /// In en, this message translates to:
  /// **'Delete all your tasks, logs, and statistics'**
  String get resetDataDescription;

  /// No description provided for @confirmReset.
  ///
  /// In en, this message translates to:
  /// **'Reset All Data?'**
  String get confirmReset;

  /// No description provided for @confirmResetMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all your data. This action cannot be undone.'**
  String get confirmResetMessage;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @dataResetSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Data has been reset successfully'**
  String get dataResetSuccessful;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @remindersDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage reminders to log your energy amounts'**
  String get remindersDescription;

  /// No description provided for @morningReminder.
  ///
  /// In en, this message translates to:
  /// **'Morning Reminder'**
  String get morningReminder;

  /// No description provided for @morningReminderDescription.
  ///
  /// In en, this message translates to:
  /// **'Reminder to log morning energy level'**
  String get morningReminderDescription;

  /// No description provided for @afternoonReminder.
  ///
  /// In en, this message translates to:
  /// **'Afternoon Reminder'**
  String get afternoonReminder;

  /// No description provided for @afternoonReminderDescription.
  ///
  /// In en, this message translates to:
  /// **'Reminder to log afternoon energy level'**
  String get afternoonReminderDescription;

  /// No description provided for @eveningReminder.
  ///
  /// In en, this message translates to:
  /// **'Evening Reminder'**
  String get eveningReminder;

  /// No description provided for @eveningReminderDescription.
  ///
  /// In en, this message translates to:
  /// **'Reminder to log evening energy level'**
  String get eveningReminderDescription;

  /// No description provided for @reminderTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get reminderTime;

  /// No description provided for @desktopSettings.
  ///
  /// In en, this message translates to:
  /// **'Desktop Settings'**
  String get desktopSettings;

  /// No description provided for @minimizeToTray.
  ///
  /// In en, this message translates to:
  /// **'Minimize to Tray'**
  String get minimizeToTray;

  /// No description provided for @minimizeToTrayDescription.
  ///
  /// In en, this message translates to:
  /// **'Close window to system tray instead of exiting'**
  String get minimizeToTrayDescription;

  /// No description provided for @startOnStartup.
  ///
  /// In en, this message translates to:
  /// **'Start Pacey on Startup'**
  String get startOnStartup;

  /// No description provided for @startOnStartupDescription.
  ///
  /// In en, this message translates to:
  /// **'Automatically launch Pacey when you log into your system'**
  String get startOnStartupDescription;

  /// No description provided for @syncData.
  ///
  /// In en, this message translates to:
  /// **'Sync Data'**
  String get syncData;

  /// No description provided for @syncDataDescription.
  ///
  /// In en, this message translates to:
  /// **'Export or import encrypted changesets to sync data between devices using CRDT technology.'**
  String get syncDataDescription;

  /// No description provided for @exportSyncData.
  ///
  /// In en, this message translates to:
  /// **'Export Sync Data'**
  String get exportSyncData;

  /// No description provided for @importSyncData.
  ///
  /// In en, this message translates to:
  /// **'Import Sync Data'**
  String get importSyncData;

  /// No description provided for @exportSyncSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Sync data exported successfully.'**
  String get exportSyncSuccessful;

  /// No description provided for @exportSyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed. Please try again.'**
  String get exportSyncFailed;

  /// No description provided for @importSyncSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Sync data imported successfully.'**
  String get importSyncSuccessful;

  /// No description provided for @importSyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed. Please check the file and try again.'**
  String get importSyncFailed;

  /// No description provided for @syncDataInfo.
  ///
  /// In en, this message translates to:
  /// **'The sync feature uses CRDT (Conflict-free Replicated Data Types) to merge data from multiple devices. Export a changeset from one device and import it on another to sync your data.'**
  String get syncDataInfo;

  /// No description provided for @devicePairing.
  ///
  /// In en, this message translates to:
  /// **'Device Pairing'**
  String get devicePairing;

  /// No description provided for @thisDevice.
  ///
  /// In en, this message translates to:
  /// **'This Device'**
  String get thisDevice;

  /// No description provided for @shareDeviceId.
  ///
  /// In en, this message translates to:
  /// **'Share Device ID'**
  String get shareDeviceId;

  /// No description provided for @scanToPair.
  ///
  /// In en, this message translates to:
  /// **'Scan this QR code with another device to pair'**
  String get scanToPair;

  /// No description provided for @scanDevice.
  ///
  /// In en, this message translates to:
  /// **'Scan Device QR Code'**
  String get scanDevice;

  /// No description provided for @startScanning.
  ///
  /// In en, this message translates to:
  /// **'Start Scanning'**
  String get startScanning;

  /// No description provided for @pairedDevices.
  ///
  /// In en, this message translates to:
  /// **'Paired Devices'**
  String get pairedDevices;

  /// No description provided for @noPairedDevices.
  ///
  /// In en, this message translates to:
  /// **'No paired devices yet'**
  String get noPairedDevices;

  /// No description provided for @pairingSuccess.
  ///
  /// In en, this message translates to:
  /// **'Device paired successfully'**
  String get pairingSuccess;

  /// No description provided for @pairingFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to pair device'**
  String get pairingFailed;

  /// No description provided for @connectionStatus.
  ///
  /// In en, this message translates to:
  /// **'Connection Status'**
  String get connectionStatus;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @disconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get disconnected;

  /// No description provided for @connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting'**
  String get connecting;

  /// No description provided for @realTimeSync.
  ///
  /// In en, this message translates to:
  /// **'Real-time Sync'**
  String get realTimeSync;

  /// No description provided for @realTimeSyncDescription.
  ///
  /// In en, this message translates to:
  /// **'Automatically sync data when connected to paired devices'**
  String get realTimeSyncDescription;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'he'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'he':
      return AppLocalizationsHe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
