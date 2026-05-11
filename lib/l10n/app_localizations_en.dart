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
    return 'Tasks for $energy ⚡';
  }

  @override
  String get noTasks => 'No tasks for this energy level.';

  @override
  String get addTask => 'Add Task';

  @override
  String get taskTitle => 'Task Title';

  @override
  String get energyCost => 'Energy Cost';

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
  String get energyTrend => 'Energy Trend';

  @override
  String get energyLogs => 'Energy Logs';

  @override
  String get tasks => 'Tasks';

  @override
  String get noHistory => 'No history recorded yet.';

  @override
  String get energyUpdate => 'Energy Level Update';
}
