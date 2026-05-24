import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sqlite_crdt/sqlite_crdt.dart';

/// A CRDT-based local database for offline-first, privacy-focused Flutter applications.
///
/// This class encapsulates the initialization of a SqliteCrdt instance, provides
/// CRUD operations for an `items` table, and handles synchronization via changeset
/// export/import for peer-to-peer data exchange.
///
/// Note: Encryption (AES-256) is applied to the changeset JSON string
/// before transmission over the network and after reception to ensure privacy.
class CrdtDatabase {
  /// The underlying CRDT instance managing the local SQLite database.
  SqliteCrdt? _crdt;

  /// The database path.
  final String _databasePath;

  /// Flutter Secure Storage instance for storing encryption keys.
  final FlutterSecureStorage _storage;

  /// Encrypter instance for AES encryption/decryption.
  Encrypter? _encrypter;

  /// Whether the database has been initialized.
  bool _isInitialized = false;

  /// Callback function called when data changes.
  Function()? onDataChange;

  /// Initializes the CRDT database with the specified [databasePath].
  ///
  /// Sets up the `items` table with columns: id (TEXT, PK), title (TEXT),
  /// description (TEXT), updated_at (TEXT).
  ///
  /// Returns true if initialization was successful.
  CrdtDatabase(this._databasePath)
      : _storage = const FlutterSecureStorage();

  /// Initializes the database tables and encryption.
  /// Must be called before using any other methods.
  ///
  /// Returns true if initialization was successful.
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _crdt = await SqliteCrdt.open(
        _databasePath,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS items (
              id TEXT PRIMARY KEY,
              title TEXT,
              description TEXT,
              updated_at TEXT
            )
          ''');
        },
      );
      _isInitialized = true;
      await _setupEncrypter();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Sets up the AES-256 encrypter using a key stored in Flutter Secure Storage.
  /// If no key exists, generates a new 32-byte key and stores it.
  Future<void> _setupEncrypter() async {
    final key = await _getEncryptionKey();
    _encrypter = Encrypter(AES(key, mode: AESMode.cbc));
  }

  /// Retrieves the encryption key from secure storage, or generates and stores a new one.
  Future<Key> _getEncryptionKey() async {
    const keyName = 'encryption_key';
    final storedKey = await _storage.read(key: keyName);
    if (storedKey != null) {
      try {
        return Key.fromBase16(storedKey);
      } catch (_) {
        // If stored key is invalid, generate a new one
      }
    }
    // Generate a new 32-byte key
    final key = Key.fromSecureRandom(32);
    await _storage.write(key: keyName, value: key.base16);
    return key;
  }

  /// Inserts a new item into the database.
  ///
  /// Returns the ID of the inserted item.
  Future<String> insertItem({
    required String id,
    required String title,
    required String description,
    required String updatedAt,
  }) async {
    if (_crdt == null) throw StateError('Database not initialized');
    
    await _crdt!.execute(
      'INSERT INTO items (id, title, description, updated_at) VALUES (?, ?, ?, ?)',
      [id, title, description, updatedAt],
    );
    onDataChange?.call();
    return id;
  }

  /// Updates an existing item in the database.
  ///
  /// Returns true if the item was updated, false if no item matched the ID.
  Future<bool> updateItem({
    required String id,
    String? title,
    String? description,
    String? updatedAt,
  }) async {
    if (_crdt == null) return false;
    
    final Set<String> columns = {};
    final List<Object?> values = [];

    if (title != null) {
      columns.add('title = ?');
      values.add(title);
    }
    if (description != null) {
      columns.add('description = ?');
      values.add(description);
    }
    if (updatedAt != null) {
      columns.add('updated_at = ?');
      values.add(updatedAt);
    }

    if (columns.isEmpty) return false;

    values.add(id);
    final query =
        '''
      UPDATE items
      SET ${columns.join(', ')}
      WHERE id = ?
    ''';

    await _crdt!.execute(query, values);
    onDataChange?.call();
    return true;
  }

  /// Reads all items from the database.
  ///
  /// Returns a list of maps, each representing an item.
  Future<List<Map<String, dynamic>>> getAllItems() async {
    if (_crdt == null) return [];
    
    final result = await _crdt!.query(
      'SELECT id, title, description, updated_at FROM items WHERE is_deleted = 0',
    );
    return result;
  }

  /// Reads a single item by its ID.
  ///
  /// Returns a map representing the item, or null if not found.
  Future<Map<String, dynamic>?> getItemById(String id) async {
    if (_crdt == null) return null;
    
    final result = await _crdt!.query(
      'SELECT id, title, description, updated_at FROM items WHERE id = ? AND is_deleted = 0',
      [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  /// Deletes an item from the database by its ID.
  ///
  /// Returns true if the item was deleted, false if no item matched the ID.
  Future<bool> deleteItem(String id) async {
    if (_crdt == null) return false;
    
    await _crdt!.execute('UPDATE items SET is_deleted = 1 WHERE id = ?', [id]);
    onDataChange?.call();
    return true;
  }

  /// Deletes all items from the database.
  ///
  /// Returns the number of items deleted.
  Future<int> deleteAllItems() async {
    if (_crdt == null) return 0;
    
    await _crdt!.execute('UPDATE items SET is_deleted = 1');
    onDataChange?.call();
    return -1; // Cannot get exact count with soft delete
  }

  /// Exports the current changeset as an encrypted JSON string.
  ///
  /// This changeset represents the local changes since the last sync.
  /// The returned string is encrypted with AES-256 and ready for transmission.
  Future<String> exportChangeset() async {
    if (!_isInitialized || _encrypter == null || _crdt == null) {
      throw StateError('Database not initialized or encrypter not set up.');
    }

    final changeset = await _crdt!.getChangeset();
    // Convert the changeset (Map) to a JSON string for safe transport.
    final jsonString = jsonEncode({'changeset': changeset});
    final encrypted = _encrypter!.encrypt(jsonString);
    return encrypted.base64;
  }

  /// Imports an encrypted changeset from a peer, decrypts it, and merges it into the local database.
  ///
  /// [encryptedData] is the encrypted changeset string produced by [exportChangeset] from another device.
  /// Decrypts the data using the shared encryption key before merging.
  /// Throws an exception if decryption fails (e.g., due to incorrect key).
  Future<void> importChangeset(String encryptedData) async {
    if (!_isInitialized || _encrypter == null || _crdt == null) {
      throw StateError('Database not initialized or encrypter not set up.');
    }

    try {
      final decrypted = _encrypter!.decrypt64(encryptedData);
      final jsonMap = jsonDecode(decrypted) as Map<String, dynamic>;
      final changeset = jsonMap['changeset'] as CrdtChangeset;
      await _crdt!.merge(changeset);
    } catch (e) {
      throw Exception('Failed to decrypt and import changeset: $e');
    }
  }
}
