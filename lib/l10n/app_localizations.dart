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
