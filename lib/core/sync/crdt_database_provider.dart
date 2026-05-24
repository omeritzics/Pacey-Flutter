import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../../../data/crdt_database.dart';

final crdtDatabaseProvider = FutureProvider<CrdtDatabase>((ref) async {
  // Get the application documents directory
  final directory = await getApplicationDocumentsDirectory();
  final db = CrdtDatabase('${directory.path}/pacey_crdt.db');
  await db.initialize();
  return db;
});
