// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hebrew (`he`).
class AppLocalizationsHe extends AppLocalizations {
  AppLocalizationsHe([String locale = 'he']) : super(locale);

  @override
  String get appTitle => 'Pacey';

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
    return 'משימות לרמת האנרגיה הנוכחית';
  }

  @override
  String get noTasks => 'אין משימות עבור רמת האנרגיה הזו.';

  @override
  String get addTask => 'הוספת משימה';

  @override
  String get editTask => 'עריכת משימה';

  @override
  String get taskTitle => 'שם המשימה';

  @override
  String get requiredEnergy => 'רמת אנרגיה נדרשת';

  @override
  String get taskPriority => 'עדיפות';

  @override
  String get priorityHighest => '1 — הגבוהה ביותר';

  @override
  String get priorityHigh => '2 — גבוהה';

  @override
  String get priorityMedium => '3 — בינונית';

  @override
  String get priorityLow => '4 — הנמוכה ביותר';

  @override
  String get repeatCadence => 'חזרה';

  @override
  String get repeatCadenceHint =>
      'באיזו תדירות ניתן לסיים את המשימה שוב לאחר השלמה.';

  @override
  String get repeatOff => 'ללא חזרה';

  @override
  String get repeatDaily => 'יומי';

  @override
  String get repeatWeekly => 'שבועי';

  @override
  String get repeatMonthly => 'חודשי';

  @override
  String availableAfter(String date) {
    return 'זמינה החל מהתאריך $date';
  }

  @override
  String get cancel => 'ביטול';

  @override
  String get save => 'שמירה';

  @override
  String get alreadyLogged => 'כבר תיעדת את רמת האנרגיה לפרק הזמן הזה.';

  @override
  String get history => 'היסטוריה';

  @override
  String get last7Days => '7 הימים האחרונים';

  @override
  String get last30Days => '30 הימים האחרונים';

  @override
  String get allTime => 'כל הזמנים';

  @override
  String get energyTrend => 'מגמת אנרגיה';

  @override
  String get energyLogs => 'יומן אנרגיה';

  @override
  String get tasks => 'משימות';

  @override
  String get noHistory => 'עדיין אין היסטוריה מתועדת.';

  @override
  String get energyUpdate => 'עדכון רמת אנרגיה';

  @override
  String get settings => 'הגדרות';

  @override
  String get about => 'מידע כללי';

  @override
  String get aboutSubtitle => 'רישיונות והצהרות קוד פתוח';

  @override
  String get aboutApplicationLegalese =>
      'כל הזכויות שמורות© 2026 עומר א״ש (‎@omeritzics)';

  @override
  String get language => 'שפה';

  @override
  String get selectLanguage => 'בחירת שפה';

  @override
  String get darkMode => 'מצב כהה';

  @override
  String get followSystem => 'לפי המערכת';

  @override
  String get lightMode => 'מצב בהיר';

  @override
  String get importExport => 'ייבוא / ייצוא';

  @override
  String get importExportDescription =>
      'גיבוי משימות, יומן אנרגיה והתקדמות לקובץ JSON, או שחזור מגיבוי.';

  @override
  String get hideCompletedTasks => 'הסתרת משימות שהושלמו';

  @override
  String get hideCompletedTasksDescription =>
      'הימנעות מהצגת משימות שהושלמו בלוח המחוונים';

  @override
  String get hideUnavailableTasks => 'הסתרת משימות שאינן זמינות';

  @override
  String get hideUnavailableTasksDescription =>
      'הימנעות מהצגת משימות חוזרות של יום אחר';

  @override
  String get repeatDays => 'ימים לחזרה';

  @override
  String get selectWeekDays => 'בחירת ימים בשבוע';

  @override
  String get autoExport => 'ייצוא אוטומטי';

  @override
  String get autoExportDescription =>
      'ייצוא קובץ גיבוי אוטומטי בעת שינוי נתונים';

  @override
  String get autoImport => 'ייבוא אוטומטי';

  @override
  String get autoImportDescription =>
      'ייבוא נתונים מקובץ גיבוי באופן אוטומטי בעת פתיחת היישום';

  @override
  String get selectDirectory => 'בחירת תיקייה';

  @override
  String get exportData => 'ייצוא נתונים';

  @override
  String get exportDataDescription => 'קובץ גיבוי של Pacey';

  @override
  String get importData => 'ייבוא נתונים';

  @override
  String get importModeDescription =>
      'מיזוג שומר על הנתונים המקומיים ומשלב עם הגיבוי. החלפה מוחקת את כל הנתונים המקומיים לפני הייבוא.';

  @override
  String get importMerge => 'מיזוג';

  @override
  String get importReplace => 'החלפת הכל';

  @override
  String get exportFailed => 'הייצוא נכשל. נא לנסות שוב.';

  @override
  String get exportSuccessful => 'הנתונים יוצאו בהצלחה.';

  @override
  String get importFailed => 'הייבוא נכשל. נא לבדוק את הקובץ ולנסות שוב.';

  @override
  String importSuccessful(int tasks, int logs) {
    return 'יובאו $tasks משימות ו־$logs רשומות אנרגיה.';
  }

  @override
  String get dangerZone => 'אזור סכנה';

  @override
  String get resetData => 'איפוס נתונים';

  @override
  String get resetDataDescription => 'מחיקת כל המשימות, היומנים והסטטיסטיקות';

  @override
  String get confirmReset => 'לאפס את כל הנתונים?';

  @override
  String get confirmResetMessage =>
      'פעולה זו תמחק לצמיתות את כל הנתונים שלך. לא ניתן לבטל פעולה זו.';

  @override
  String get reset => 'איפוס';

  @override
  String get dataResetSuccessful => 'הנתונים אופסו בהצלחה';

  @override
  String get reminders => 'תזכורות';

  @override
  String get remindersDescription => 'ניהול תזכורות להזנת רמות האנרגיה שלך';

  @override
  String get morningReminder => 'תזכורת בוקר';

  @override
  String get morningReminderDescription => 'תזכורת לתיעוד רמת האנרגיה בבוקר';

  @override
  String get afternoonReminder => 'תזכורת צהריים';

  @override
  String get afternoonReminderDescription =>
      'תזכורת לתיעוד רמת האנרגיה בצהריים';

  @override
  String get eveningReminder => 'תזכורת ערב';

  @override
  String get eveningReminderDescription => 'תזכורת לתיעוד רמת האנרגיה בערב';

  @override
  String get reminderTime => 'שעה';

  @override
  String get desktopSettings => 'הגדרות שולחן עבודה';

  @override
  String get minimizeToTray => 'מזעור למגש המערכת';

  @override
  String get minimizeToTrayDescription =>
      'סגירת החלון תמזער אותו למגש המערכת במקום לצאת';

  @override
  String get startOnStartup => 'הפעל את Pacey עם הפעלת המחשב';

  @override
  String get startOnStartupDescription =>
      'הפעלה אוטומטית של Pacey בעת כניסה למערכת';

  @override
  String get syncData => 'סנכרון נתונים';

  @override
  String get syncDataDescription =>
      'ייצוא או ייבוא של קבוצות שינויים מוצפנות לסנכרון נתונים בין מכשירים באמצעות טכנולוגיית CRDT.';

  @override
  String get exportSyncData => 'ייצוא נתוני סנכרון';

  @override
  String get importSyncData => 'ייבוא נתוני סנכרון';

  @override
  String get exportSyncSuccessful => 'נתוני הסנכרון יוצאו בהצלחה.';

  @override
  String get exportSyncFailed => 'הייצוא נכשל. נא לנסות שוב.';

  @override
  String get importSyncSuccessful => 'נתוני הסנכרון יובאו בהצלחה.';

  @override
  String get importSyncFailed => 'הייבוא נכשל. נא לבדוק את הקובץ ולנסות שוב.';

  @override
  String get syncDataInfo =>
      'תכונת הסנכרון משתמשת ב-CRDT (סוגי נתונים חסרי סתירות ומשוכפלים) כדי למזג נתונים ממספר מכשירים. ייצא קבוצת שינויים ממכשיר אחד וייבא אותה במכשיר אחר כדי לסנכרן את הנתונים שלך.';

  @override
  String get devicePairing => 'צימוד מכשירים';

  @override
  String get thisDevice => 'מכשיר זה';

  @override
  String get shareDeviceId => 'שיתוף מזהה מכשיר';

  @override
  String get scanToPair => 'סרוק קוד QR זה במכשיר אחר לצימוד';

  @override
  String get scanDevice => 'סריקת קוד QR של מכשיר';

  @override
  String get startScanning => 'התחל סריקה';

  @override
  String get pairedDevices => 'מכשירים מצומדים';

  @override
  String get noPairedDevices => 'אין מכשירים מצומדים עדיין';

  @override
  String get pairingSuccess => 'המכשיר צומד בהצלחה';

  @override
  String get pairingFailed => 'צימוד המכשיר נכשל';

  @override
  String get connectionStatus => 'סטטוס חיבור';

  @override
  String get connected => 'מחובר';

  @override
  String get disconnected => 'מנותק';

  @override
  String get connecting => 'מתחבר';

  @override
  String get realTimeSync => 'סנכרון בזמן אמת';

  @override
  String get realTimeSyncDescription =>
      'סנכרון אוטומטי של נתונים בעת חיבור למכשירים מצומדים';
}
