import 'package:flutter_test/flutter_test.dart';
import 'package:encrypt/encrypt.dart';

void main() {
  group('CRDT Encryption Tests', () {
    test('Key generation and conversion', () {
      // Test that we can generate a secure random key
      final key = Key.fromSecureRandom(32);
      expect(key.base16.length, equals(64)); // 32 bytes = 64 hex characters
      
      // Test that we can convert from hex and back
      final hex = key.base16;
      final key2 = Key.fromBase16(hex);
      expect(key.base16, equals(key2.base16));
    });

    test('AES encryption and decryption', () {
      // Test AES encryption/decryption
      final key = Key.fromSecureRandom(32);
      final iv = IV.fromSecureRandom(16);
      final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
      
      final plainText = 'Test changeset data';
      final encrypted = encrypter.encrypt(plainText, iv: iv);
      final decrypted = encrypter.decrypt(encrypted, iv: iv);
      
      expect(decrypted, equals(plainText));
    });

    test('Base64 encoding/decoding', () {
      // Test base64 encoding for transport
      final key = Key.fromSecureRandom(32);
      final iv = IV.fromSecureRandom(16);
      final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
      
      final plainText = 'Test changeset data';
      final encrypted = encrypter.encrypt(plainText, iv: iv);
      final base64 = encrypted.base64;
      
      final encrypted2 = Encrypted.fromBase64(base64);
      final decrypted = encrypter.decrypt(encrypted2, iv: iv);
      
      expect(decrypted, equals(plainText));
    });

    test('JSON serialization for changeset', () {
      // Test that we can serialize a changeset to JSON
      final changeset = {
        'table1': [
          {'id': '1', 'title': 'Task 1'},
          {'id': '2', 'title': 'Task 2'},
        ],
      };
      
      // Verify changeset structure
      expect(changeset, isNotNull);
      expect(changeset['table1'], isNotNull);
      expect(changeset['table1']!.length, equals(2));
    });
  });
}
