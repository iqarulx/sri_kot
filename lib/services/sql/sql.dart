import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
    String path = join(await getDatabasesPath(), 'app_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await createTable(db, 'enquiry');
    await createTable(db, 'estimate');
  }

  Future<void> createTable(Database db, String tableName) async {
    if (tableName == "enquiry") {
      await db.execute('''
      CREATE TABLE enquiry (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer TEXT,
        price TEXT,
        enquiry_id TEXT,
        estimate_id TEXT,
        company_id TEXT,
        created_date TEXT,
        delete_at INTEGER,
        products TEXT
      )
      ''');
    }

    if (tableName == "estimate") {
      await db.execute('''
      CREATE TABLE estimate (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer TEXT,
        price TEXT,
        estimate_id TEXT,
        company_id TEXT,
        created_date TEXT,
        delete_at INTEGER,
        products TEXT
      )
      ''');
    }
  }

  Future<void> checkAndCreateTable(String tableName) async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT name FROM sqlite_master WHERE type="table" AND name="$tableName";');

    if (result.isEmpty) {
      await createTable(db, tableName);
    }
  }

  Future<void> insertEnquiry({
    required Map<String, dynamic> orderData,
  }) async {
    final db = await database;
    await db.insert(
      'enquiry',
      orderData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertEstimate({
    required Map<String, dynamic> orderData,
  }) async {
    final db = await database;
    await db.insert(
      'estimate',
      orderData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getEnquiry() async {
    final db = await database;
    return await db.query('enquiry');
  }

  Future<List<Map<String, dynamic>>> getEstimate() async {
    final db = await database;
    return await db.query('estimate');
  }

  Future<void> clearTableRecords() async {
    final db = await database;
    await db.delete('enquiry');
    await db.delete('estimate');
  }
}
