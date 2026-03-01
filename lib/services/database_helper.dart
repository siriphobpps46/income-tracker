import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/income_entry.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'income_tracker.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE incomes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL,
        note TEXT,
        date TEXT,
        isPaid INTEGER
      )
    ''');
  }

  Future<int> insertIncome(IncomeEntry entry) async {
    Database db = await database;
    return await db.insert('incomes', entry.toMap());
  }

  Future<List<IncomeEntry>> getIncomes({DateTime? start, DateTime? end}) async {
    Database db = await database;
    String? where;
    List<dynamic>? whereArgs;

    if (start != null && end != null) {
      where = 'date BETWEEN ? AND ?';
      whereArgs = [start.toIso8601String(), end.toIso8601String()];
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'incomes',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return IncomeEntry.fromMap(maps[i]);
    });
  }

  Future<int> updateIncome(IncomeEntry entry) async {
    Database db = await database;
    return await db.update(
      'incomes',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> deleteIncome(int id) async {
    Database db = await database;
    return await db.delete('incomes', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> markAsPaid(List<int> ids) async {
    Database db = await database;
    await db.transaction((txn) async {
      for (var id in ids) {
        await txn.update(
          'incomes',
          {'isPaid': 1},
          where: 'id = ?',
          whereArgs: [id],
        );
      }
    });
  }
}
