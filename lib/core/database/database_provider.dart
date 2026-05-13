import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database.dart';
import 'connection/connection.dart' as impl;

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase(impl.openConnection());
  ref.onDispose(() => db.close());
  return db;
});
