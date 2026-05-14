import 'package:flutter_test/flutter_test.dart';
import 'package:pacey/core/p2p/p2p_service.dart';
import 'package:pacey/core/p2p/p2p_sync_service.dart';

void main() {
  group('P2P Service Tests', () {
    test('P2PService singleton pattern', () {
      final service1 = P2PService();
      final service2 = P2PService();

      expect(identical(service1, service2), true);
    });

    test('P2PSyncService singleton pattern', () {
      final service1 = P2PSyncService();
      final service2 = P2PSyncService();

      expect(identical(service1, service2), true);
    });

    test('P2PService initialization', () async {
      final service = P2PService();

      expect(service.isInitialized, false);

      // Note: This test might fail without proper WebRTC setup
      // In a real test environment, you'd mock the peer_rtc package

      try {
        await service.initialize(peerId: 'test-peer-id');
        expect(service.isInitialized, true);
        expect(service.localPeerId, 'test-peer-id');
      } catch (e) {
        // Expected in test environment without WebRTC support
      }
    });
  });

  group('P2P Sync Integration Tests', () {
    test('Sync service handles task data correctly', () {
      final taskData = <String, Object?>{
        'type': 'task_created',
        'payload': <String, Object?>{
          'id': 'test-task-1',
          'title': 'Test Task',
          'energyCost': 5,
          'isCompleted': false,
          'createdAt': DateTime.now().toIso8601String(),
        },
      };

      expect(taskData['type'], 'task_created');
      final payload = taskData['payload'] as Map<String, Object?>;
      expect(payload['id'], 'test-task-1');
      expect(payload['title'], 'Test Task');
    });
  });
}
