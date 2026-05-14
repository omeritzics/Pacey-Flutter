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
  String get editTask => 'Edit Task';

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

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get followSystem => 'Follow System';

  @override
  String get p2pSync => 'P2P Sync';

  @override
  String get syncSettings => 'Sync Settings';

  @override
  String get connectionStatus => 'Connection Status';

  @override
  String get connectedPeers => 'Connected Peers';

  @override
  String get connectToPeer => 'Connect to Peer';

  @override
  String get yourPeerId => 'Your Peer ID';

  @override
  String get shareQrCode =>
      'Share this QR code or ID with other devices to connect';

  @override
  String get enterPeerId => 'Enter Peer ID';

  @override
  String get pastePeerId => 'Paste the peer ID here';

  @override
  String get connect => 'Connect';

  @override
  String get scanQr => 'Scan QR';

  @override
  String get noPeersConnected => 'No peers connected';

  @override
  String get disconnected => 'Disconnected';

  @override
  String get connectedToP2P => 'Connected to P2P network';

  @override
  String get peerConnected => 'Peer connected';

  @override
  String get peerDisconnected => 'Peer disconnected';

  @override
  String get syncingData => 'Syncing data...';

  @override
  String get connectionRequest => 'Connection Request';

  @override
  String deviceWantsToConnect(Object peerId) {
    return 'Device $peerId wants to connect with you. Do you want to accept this connection?';
  }

  @override
  String get accept => 'Accept';

  @override
  String get reject => 'Reject';

  @override
  String connectionRejected(Object peerId) {
    return 'Connection from $peerId rejected';
  }

  @override
  String connectedTo(Object peerId) {
    return 'Connected to $peerId';
  }

  @override
  String get cameraPermissionRequired =>
      'Camera permission is required to scan QR codes';

  @override
  String get initializing => 'Initializing...';

  @override
  String get connectedDevices => 'Connected Devices';

  @override
  String get noDevicesConnected => 'No devices connected';

  @override
  String get connectDevicesToSync => 'Connect devices to start syncing data';

  @override
  String get online => 'Online';

  @override
  String peerIdLabel(String peerId) {
    return 'Peer ID: $peerId';
  }

  @override
  String get copyPeerId => 'Copy Peer ID';

  @override
  String get disconnect => 'Disconnect';

  @override
  String get disconnectDevice => 'Disconnect Device';

  @override
  String confirmDisconnect(String peerId) {
    return 'Are you sure you want to disconnect from $peerId?';
  }

  @override
  String deviceDisconnected(String peerId) {
    return 'Disconnected from $peerId';
  }

  @override
  String get confirmConnect => 'Connect to Device';

  @override
  String confirmConnectMessage(String peerId) {
    return 'Are you sure you want to connect to device $peerId?';
  }

  @override
  String get connecting => 'Connecting...';

  @override
  String connectionSuccessful(String peerId) {
    return 'Successfully connected to $peerId';
  }

  @override
  String connectionFailed(String peerId) {
    return 'Failed to connect to $peerId';
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
}
