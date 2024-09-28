import 'dart:convert';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../../log/log.dart';

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

  Future _onCreate(Database db, int version) async {
    await createTable(db, 'category');
    await createTable(db, 'customer');
    await createTable(db, 'product');
    await createTable(db, 'enquiry');
    await createTable(db, 'estimate');
  }

  Future createTable(Database db, String tableName) async {
    if (tableName == "category") {
      await db.execute('''
      CREATE TABLE category (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id TEXT,
        category_name TEXT,
        company_id TEXT,
        delete_at INTEGER,
        discount TEXT,
        name TEXT,
        postion TEXT
      )
      ''');
      saveLog('''
      CREATE TABLE category (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id TEXT,
        category_name TEXT,
        company_id TEXT,
        delete_at INTEGER,
        discount TEXT,
        name TEXT,
        postion TEXT
      )
      ''');
    }

    if (tableName == "product") {
      await db.execute('''
      CREATE TABLE product (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id TEXT,
        active INTEGER,
        category_id TEXT,
        category_name TEXT,
        company_id TEXT,
        created_date_time TEXT,
        delete_at INTEGER,
        discount_lock INTEGER,
        name TEXT,
        postion TEXT,
        price TEXT,
        product_code TEXT,
        product_content TEXT,
        product_img TEXT,
        product_name TEXT,
        qr_code TEXT,
        video_url TEXT
      )
      ''');
      saveLog('''
      CREATE TABLE product (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id TEXT,
        active INTEGER,
        category_id TEXT,
        category_name TEXT,
        company_id TEXT,
        created_date_time TEXT,
        delete_at INTEGER,
        discount_lock INTEGER,
        name TEXT,
        postion TEXT,
        price TEXT,
        product_code TEXT,
        product_content TEXT,
        product_img TEXT,
        product_name TEXT,
        qr_code TEXT,
        video_url TEXT
      )
      ''');
    }

    if (tableName == "customer") {
      await db.execute('''
      CREATE TABLE customer (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id TEXT,
        address TEXT,
        city TEXT,
        company_id TEXT,
        customer_name TEXT,
        email TEXT,
        mobile_no TEXT,
        state TEXT
      )
      ''');
      saveLog('''
      CREATE TABLE customer (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id TEXT,
        address TEXT,
        city TEXT,
        company_id TEXT,
        customer_name TEXT,
        email TEXT,
        mobile_no TEXT,
        state TEXT
      )
      ''');
    }

    if (tableName == "enquiry") {
      await db.execute('''
      CREATE TABLE enquiry (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer TEXT,
        price TEXT,
        reference_id TEXT,
        enquiry_id TEXT,
        estimate_id TEXT,
        company_id TEXT,
        created_date TEXT,
        delete_at INTEGER,
        products TEXT
      )
      ''');
      saveLog('''
      CREATE TABLE enquiry (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer TEXT,
        price TEXT,
        reference_id TEXT,
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
        reference_id TEXT,
        company_id TEXT,
        created_date TEXT,
        delete_at INTEGER,
        products TEXT
      )
      ''');
      saveLog('''
      CREATE TABLE estimate (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer TEXT,
        price TEXT,
        estimate_id TEXT,
        reference_id TEXT,
        company_id TEXT,
        created_date TEXT,
        delete_at INTEGER,
        products TEXT
      )
      ''');
    }
  }

  Future checkAndCreateTable(String tableName) async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT name FROM sqlite_master WHERE type="table" AND name="$tableName";');
    if (result.isEmpty) {
      await createTable(db, tableName);
    }
  }

  Future insertEnquiry({
    required Map<String, dynamic> orderData,
  }) async {
    final db = await database;

    // Construct SQL query manually
    const tableName = 'enquiry';
    final columns = orderData.keys.join(', ');
    final values = orderData.values.map((value) {
      // Safely escape single quotes in string values
      return "'${value.toString().replaceAll("'", "''")}'";
    }).join(', ');

    final query = 'INSERT INTO $tableName ($columns) VALUES ($values);';

    // Execute the SQL query
    await db.insert(
      tableName,
      orderData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Save the query to a log file
    await saveLog(query);
  }

  Future updateEnquiry({
    required Map<String, dynamic> orderData,
    required String referenceId,
  }) async {
    final db = await database;

    await db.update(
      'enquiry',
      orderData,
      where: 'reference_id = ?',
      whereArgs: [referenceId],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> countEnquiries() async {
    final db = await database;

    try {
      final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT COUNT(*) as count FROM enquiry
    ''');

      // Return the count from the query result
      return result.isNotEmpty ? (result.first['count'] as int) : 0;
    } catch (e) {
      // Log the error (optional)
      Log.addLog("${DateTime.now()} : Error counting enquiries: $e");

      // Return 0 if there is an error (e.g., table does not exist)
      return 0;
    }
  }

  Future<Map<String, dynamic>> getEnquiryWithId(String referenceId) async {
    final db = await database;

    print(referenceId);

    try {
      final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT * FROM enquiry WHERE reference_id = ?
    ''', [referenceId]);
      // Return the count from the query result
      print(result.first);
      return result.isNotEmpty ? result.first : {};
    } catch (e) {
      // Log the error (optional)
      Log.addLog("${DateTime.now()} : Error counting enquiries: $e");
      return {};
    }
  }

  Future<Map<String, dynamic>> getEstimateWithId(String referenceId) async {
    final db = await database;

    try {
      final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT * FROM estimate WHERE reference_id = ?
    ''', [referenceId]);

      // Return the count from the query result
      return result.isNotEmpty ? result.first : {};
    } catch (e) {
      // Log the error (optional)
      Log.addLog("${DateTime.now()} : Error counting enquiries: $e");
      return {};
    }
  }

  Future updateEnquiryCustomer(String referenceId, String customerInfo) async {
    final db = await database;

    try {
      await db.rawUpdate('''
      UPDATE enquiry
      SET customer = ?
      WHERE reference_id = ?
    ''', [customerInfo, referenceId]);
    } catch (e) {
      // Log the error (optional)
      Log.addLog("${DateTime.now()} : Error updating enquiry customer: $e");
    }
  }

  Future updateEstimate({
    required Map<String, dynamic> orderData,
    required String referenceId,
  }) async {
    final db = await database;

    await db.update(
      'estimate',
      orderData,
      where: 'reference_id = ?',
      whereArgs: [referenceId],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future removeEnquiry(String referenceId) async {
    final db = await database;

    try {
      final result = await db.rawQuery('''
      DELETE FROM enquiry WHERE reference_id = ?
    ''', [referenceId]);
    } catch (e) {
      Log.addLog("${DateTime.now()} : ${e.toString()}");
    }
  }

  Future removeEstimate(String referenceId) async {
    final db = await database;

    try {
      final result = await db.rawQuery('''
      DELETE FROM estimate WHERE reference_id = ?
    ''', [referenceId]);
    } catch (e) {
      Log.addLog("${DateTime.now()} : ${e.toString()}");
    }
  }

  Future<int> countEstimate() async {
    final db = await database;

    try {
      final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT COUNT(*) as count FROM estimate
    ''');

      // Return the count from the query result
      return result.isNotEmpty ? (result.first['count'] as int) : 0;
    } catch (e) {
      // Log the error (optional)
      Log.addLog("${DateTime.now()} : Error counting estimate: $e");

      // Return 0 if there is an error (e.g., table does not exist)
      return 0;
    }
  }

  Future insertEstimate({
    required Map<String, dynamic> orderData,
  }) async {
    final db = await database;

    // Construct SQL query manually
    const tableName = 'estimate';
    final columns = orderData.keys.join(', ');
    final values = orderData.values.map((value) {
      // Safely escape single quotes in string values
      return "'${value.toString().replaceAll("'", "''")}'";
    }).join(', ');

    final query = 'INSERT INTO $tableName ($columns) VALUES ($values);';

    await db.insert(
      tableName,
      orderData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await saveLog(query);
  }

  Future insertProduct({
    required Map<String, dynamic> data,
  }) async {
    final db = await database;

    const tableName = 'product';
    final columns = data.keys.join(', ');
    final values = data.values.map((value) {
      // Safely escape single quotes in string values
      return "'${value.toString().replaceAll("'", "''")}'";
    }).join(', ');

    final query = 'INSERT INTO $tableName ($columns) VALUES ($values);';

    await db.insert(
      tableName,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await saveLog(query);
  }

  Future insertCategory({
    required Map<String, dynamic> data,
  }) async {
    final db = await database;

    const tableName = 'category';
    final columns = data.keys.join(', ');
    final values = data.values.map((value) {
      // Safely escape single quotes in string values
      return "'${value.toString().replaceAll("'", "''")}'";
    }).join(', ');

    final query = 'INSERT INTO $tableName ($columns) VALUES ($values);';

    await db.insert(
      'category',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await saveLog(query);
  }

  Future insertCustomer({
    required Map<String, dynamic> data,
  }) async {
    final db = await database;

    const tableName = 'customer';
    final columns = data.keys.join(', ');
    final values = data.values.map((value) {
      // Safely escape single quotes in string values
      return "'${value.toString().replaceAll("'", "''")}'";
    }).join(', ');

    final query = 'INSERT INTO $tableName ($columns) VALUES ($values);';

    await db.insert(
      'customer',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await saveLog(query);
  }

  Future<List<Map<String, dynamic>>> getEnquiry({
    required int start,
    required int end,
    required bool limitApplied,
  }) async {
    final db = await database;

    if (limitApplied) {
      int limit = end - start;

      var result = await db.query(
        'enquiry',
        limit: limit,
        offset: start,
      );
      return result;
    } else {
      return await db.query('enquiry');
    }
  }

  Future<Map<String, dynamic>> getEnquiryTotal() async {
    final db = await database;
    var enquiry = await db.query('enquiry');

    double overallTotal = 0.0;
    for (var data in enquiry) {
      try {
        var price =
            jsonDecode(data['price'].toString()) as Map<String, dynamic>;
        if (price["total"] != null && price["total"] is num) {
          overallTotal += price["total"].toDouble();
        }
      } catch (e) {
        print('Error parsing price: $e');
      }
    }

    return {
      "total": overallTotal.toString(),
      "no_of_enquiry": enquiry.length,
    };
  }

  Future<Map<String, dynamic>> getEstimateTotal() async {
    final db = await database;
    var estimate = await db.query('estimate');

    double overallTotal = 0.0;
    for (var data in estimate) {
      try {
        var price =
            jsonDecode(data['price'].toString()) as Map<String, dynamic>;
        if (price["total"] != null && price["total"] is num) {
          overallTotal += price["total"].toDouble();
        }
      } catch (e) {
        print('Error parsing price: $e');
      }
    }

    return {
      "total": overallTotal.toString(),
      "no_of_estimate": estimate.length,
    };
  }

  Future<List<Map<String, dynamic>>> getEstimate({
    required int start,
    required int end,
    required bool limitApplied,
  }) async {
    final db = await database;

    if (limitApplied) {
      int limit = end - start;

      var result = await db.query(
        'estimate',
        limit: limit,
        offset: start,
      );
      return result;
    } else {
      return await db.query('estimate');
    }
  }

  Future clearBillRecords() async {
    final db = await database;
    await db.delete('enquiry');
    await db.delete('estimate');
  }

  Future<List<Map<String, dynamic>>> getProducts() async {
    final db = await database;
    var result = await db.query('product');

    return result
        .toList()
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
  }

  Future<List<Map<String, dynamic>>> getCategory() async {
    final db = await database;
    var result = await db.query('category');
    return result
        .toList()
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
  }

  Future<List<Map<String, dynamic>>> getCustomer() async {
    final db = await database;
    return await db.query('customer');
  }

  Future clearProducts() async {
    final db = await database;
    await db.delete('product');
  }

  Future clearCategory() async {
    final db = await database;
    await db.delete('category');
  }

  Future clearCustomer() async {
    final db = await database;
    await db.delete('customer');
  }

  Future dropTable(String table) async {
    final db = await database;
    await db.execute('DROP TABLE IF EXISTS $table');
  }

  Future importQuery(File file) async {
    try {
      // Read the SQL file content
      final sqlContent = await readSqlFile(file);

      // Split the content into individual queries
      final queries =
          sqlContent.split(';').where((query) => query.trim().isNotEmpty);

      // Get the database instance
      final db = await database;

      // Execute each query
      for (var query in queries) {
        await db.execute(query);
      }

      print('SQL queries executed successfully.');
    } catch (e) {
      Log.addLog("${DateTime.now()} : Error importing queries: $e");
    }
  }

  Future<String> readSqlFile(File file) async {
    return await file.readAsString();
  }

  Future saveLog(String query) async {
    try {
      // const downloadsDirectoryPath =
      //     '/storage/emulated/0/Download/Srisoftwarez/';
      // final downloadsDirectory = Directory(downloadsDirectoryPath);

      // if (!await downloadsDirectory.exists()) {
      //   await downloadsDirectory.create(recursive: true);
      // }

      // const filePath = '$downloadsDirectoryPath/backup.txt';
      // final file = File(filePath);
      // final sink = file.openWrite(mode: FileMode.append);

      // sink.writeln(query);
      // await sink.flush();
      // await sink.close();

      // print('Query saved to $filePath');
    } catch (e) {
      Log.addLog("${DateTime.now()} : Error saving query: $e");
    }
  }
}
