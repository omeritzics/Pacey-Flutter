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
    return 'משימות עבור $energy ⚡';
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
  String get energyCost => 'עלות אנרגיה';

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
    return 'זמין לאחר $date';
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
  String get energyTrend => 'מגמת אנרגיה';

  @override
  String get energyLogs => 'יומן אנרגיה';

  @override
  String get tasks => 'משימות';

  @override
  String get noHistory => 'אין עדיין היסטוריה מתועדת.';

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
      'Copyright © 2026 The Pacey authors\n\nLicensed under the Apache License, Version 2.0. You may obtain a copy of the License at https://www.apache.org/licenses/LICENSE-2.0';

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
  String get p2pSync => 'סנכרון P2P';

  @override
  String get syncSettings => 'הגדרות סנכרון';

  @override
  String get connectionStatus => 'מצב חיבור';

  @override
  String get connectedPeers => 'מכשירים מחוברים';

  @override
  String get connectToPeer => 'התחברות למכשיר';

  @override
  String get yourPeerId => 'מזהה המכשיר שלך';

  @override
  String get shareQrCode =>
      'אפשר לשתף קוד QR זה או מזהה עם מכשירים אחרים כדי להתחבר';

  @override
  String get enterPeerId => 'נא להכניס מזהה מכשיר';

  @override
  String get pastePeerId => 'נא להדביק את מזהה המכשיר כאן';

  @override
  String get connect => 'התחברות';

  @override
  String get scanQr => 'סריקת קוד QR';

  @override
  String get noPeersConnected => 'אין מכשירים מחוברים';

  @override
  String get disconnected => 'מנותק';

  @override
  String get connectedToP2P => 'מחובר לרשת P2P';

  @override
  String get peerConnected => 'המכשיר התחבר';

  @override
  String get peerDisconnected => 'המכשיר התנתק';

  @override
  String get syncingData => 'הנתונים מסתנכרנים...';

  @override
  String get connectionRequest => 'בקשת חיבור';

  @override
  String deviceWantsToConnect(Object peerId) {
    return 'המכשיר $peerId רוצה להתחבר למכשירך. האם ברצונך לאשר חיבור זה?';
  }

  @override
  String get accept => 'אישור';

  @override
  String get reject => 'דחייה';

  @override
  String connectionRejected(Object peerId) {
    return 'החיבור מהמכשיר $peerId נדחה';
  }

  @override
  String connectedTo(Object peerId) {
    return 'מחובר אל $peerId';
  }

  @override
  String get cameraPermissionRequired => 'נדרשת הרשאת מצלמה כדי לסרוק קודי QR';

  @override
  String get initializing => 'בתהליך אתחול...';

  @override
  String get connectedDevices => 'התקנים מחוברים';

  @override
  String get noDevicesConnected => 'אין מכשירים מחוברים';

  @override
  String get connectDevicesToSync => 'חבר מכשירים כדי להתחיל לסנכרן נתונים';

  @override
  String get online => 'באינטרנט';

  @override
  String peerIdLabel(String peerId) {
    return 'מזהה עמית: $peerId';
  }

  @override
  String get copyPeerId => 'העתק את מזהה עמיתים';

  @override
  String get disconnect => 'לְנַתֵק';

  @override
  String get disconnectDevice => 'נתק מכשיר';

  @override
  String confirmDisconnect(String peerId) {
    return 'האם אתה בטוח שברצונך להתנתק מ-$peerId?';
  }

  @override
  String deviceDisconnected(String peerId) {
    return 'מנותק מ-$peerId';
  }

  @override
  String get confirmConnect => 'התחבר למכשיר';

  @override
  String confirmConnectMessage(String peerId) {
    return 'האם אתה בטוח שברצונך להתחבר למכשיר $peerId?';
  }

  @override
  String get connecting => 'מתחבר...';

  @override
  String connectionSuccessful(String peerId) {
    return 'התחברת בהצלחה ל-$peerId';
  }

  @override
  String connectionFailed(String peerId) {
    return 'ההתחברות ל-$peerId נכשלה';
  }

  @override
  String get dangerZone => 'אזור סכנה';

  @override
  String get resetData => 'איפוס נתונים';

  @override
  String get resetDataDescription => 'מחיקת כל המשימות, היומנים והסטטיסטיקות';

  @override
  String get confirmReset => 'איפוס כל הנתונים?';

  @override
  String get confirmResetMessage =>
      'פעולה זו תמחק לצמיתות את כל הנתונים שלך. לא ניתן לבטל פעולה זו.';

  @override
  String get reset => 'איפוס';

  @override
  String get dataResetSuccessful => 'הנתונים אופסו בהצלחה';
}
