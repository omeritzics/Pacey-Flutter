import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:pacey/core/database/database.dart';

void main() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  final appDb = AppDatabase.instance;
  final db = await appDb.database;

  // Insert a dummy task
  await db.insert('tasks', {
    'id': 'test_id',
    'title': 'Test Task',
    'energy_cost': 2,
    'priority': 1,
    'repeat_interval': 0,
    'is_completed': 0,
    'updated_at': DateTime.now().millisecondsSinceEpoch,
    'created_at': DateTime.now().millisecondsSinceEpoch,
  });

  await db.query('tasks');

  // Reset
  await db.transaction((txn) async {
    await txn.delete('tasks');
    await txn.delete('energy_logs');
  });

}
