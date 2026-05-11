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
  String get noTasks => 'אין משימות עבור רמת האנרגיה הזו.';

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

  @override
  String get settings => 'הגדרות';

  @override
  String get language => 'שפה';

  @override
  String get selectLanguage => 'בחר שפה';

  @override
  String get followSystem => 'עקוב אחר המערכת';

  @override
  String get p2pSync => 'סינכרון P2P';

  @override
  String get syncSettings => 'הגדרות סינכרון';

  @override
  String get connectionStatus => 'סטטוס חיבור';

  @override
  String get connectedPeers => 'מכשירים מחוברים';

  @override
  String get connectToPeer => 'התחבר למכשיר';

  @override
  String get yourPeerId => 'מזהה המכשיר שלך';

  @override
  String get shareQrCode => 'שתף קוד QR זה או מזהה עם מכשירים אחרים כדי להתחבר';

  @override
  String get enterPeerId => 'הכנס מזהה מכשיר';

  @override
  String get pastePeerId => 'הדבק את מזהה המכשיר כאן';

  @override
  String get connect => 'התחבר';

  @override
  String get scanQr => 'סרוק QR';

  @override
  String get noPeersConnected => 'אין מכשירים מחוברים';

  @override
  String get disconnected => 'מנותק';

  @override
  String get connectedToP2P => 'מחובר לרשת P2P';

  @override
  String get peerConnected => 'מכשיר התחבר';

  @override
  String get peerDisconnected => 'מכשיר התנתק';

  @override
  String get syncingData => 'מסנכרן נתונים...';

  @override
  String get connectionRequest => 'בקשת חיבור';

  @override
  String deviceWantsToConnect(Object peerId) {
    return 'מכשיר $peerId רוצה להתחבר אליך. האם ברצונך לאשר חיבור זה?';
  }

  @override
  String get accept => 'אשר';

  @override
  String get reject => 'דחה';

  @override
  String connectionRejected(Object peerId) {
    return 'החיבור מ-$peerId נדחה';
  }

  @override
  String connectedTo(Object peerId) {
    return 'מחובר אל $peerId';
  }

  @override
  String get cameraPermissionRequired => 'נדרשת הרשאת מצלמה כדי לסרוק קודי QR';

  @override
  String get initializing => 'מאתחל...';
}
