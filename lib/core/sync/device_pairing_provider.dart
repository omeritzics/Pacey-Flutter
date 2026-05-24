import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'device_pairing_service.dart';

final devicePairingServiceProvider = Provider<DevicePairingService>((ref) {
  final service = DevicePairingService();
  ref.onDispose(() => service.dispose());
  return service;
});
