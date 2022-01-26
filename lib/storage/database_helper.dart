import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tumiapesa/models/bills.dart';

class DatabaseHandler {
  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'pesa.db'),
      onCreate: (database, version) async {
        await database.execute(
          'CREATE TABLE bills(id INTEGER PRIMARY KEY AUTOINCREMENT, biller_code TEXT, biller_name TEXT, biller_category TEXT, biller_amount TEXT)',
        );
      },
      version: 1,
    );
  }

  Future<int> insertBill(Bill _bill) async {
    int result = 0;
    final Database db = await initializeDB();
    result = await db.insert('bills', _bill.toMap());
    return result;
  }

  Future<List<Bill>> retrieveBill() async {
    final Database db = await initializeDB();
    final List<Map<String, Object>> queryResult = await db.query('bills');
    return queryResult.map((e) => Bill.fromMap(e)).toList();
  }

  Future<List<Bill>> activeBill(String biller_code) async {
    Bill result = Bill();
    final Database db = await initializeDB();
    var queryResult = await db
        .rawQuery("Select * FROM bills where biller_code = '$biller_code'");
    return queryResult.map((e) => Bill.fromMap(e)).toList();
  }

  Future<void> deleteBills() async {
    final db = await initializeDB();
    await db.delete(
      'bills',
    );
  }
}
