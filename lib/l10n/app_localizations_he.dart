// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hebrew (`he`).
class AppLocalizationsHe extends AppLocalizations {
  AppLocalizationsHe([String locale = 'he']) : super(locale);

  @override
  String get appTitle => 'פייסי';

  @override
  String healingLevel(int level) {
    return 'רמת החלמה $level';
  }

  @override
  String get stabilization => 'התייצבות';

  @override
  String get strengthening => 'התחזקות';

  @override
  String get expansion => 'הרחבת היכולות';

  @override
  String get currentEnergy => 'רמת אנרגיה נוכחית';

  @override
  String tasksForEnergy(int energy) {
    return 'משימות עבור $energy ⚡';
  }

  @override
  String get noTasks => 'אין משימות לרמת האנרגיה הזו.';

  @override
  String get addTask => 'הוספת משימה';

  @override
  String get taskTitle => 'שם המשימה';

  @override
  String get energyCost => 'עלות אנרגיה';

  @override
  String get cancel => 'ביטול';

  @override
  String get save => 'שמירה';

  @override
  String get alreadyLogged => 'כבר תיעדת את רמת האנרגיה לפרק הזמן הזה.';

  @override
  String get history => 'היסטוריה';

  @override
  String get energyTrend => 'מגמת אנרגיה';

  @override
  String get energyLogs => 'יומן אנרגיה';

  @override
  String get tasks => 'משימות';

  @override
  String get noHistory => 'אין עדיין היסטוריה מתועדת.';

  @override
  String get energyUpdate => 'עדכון רמת אנרגיה';
}
