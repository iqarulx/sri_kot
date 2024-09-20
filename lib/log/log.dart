import 'package:shared_preferences/shared_preferences.dart';

class Log {
  static Future<SharedPreferences> _connect() async {
    return await SharedPreferences.getInstance();
  }

  static Future addLog(String log) async {
    var db = await _connect();
    var prevLog = await getLog();
    prevLog.add(log);
    await db.setStringList('log', prevLog);
  }

  static Future<List<String>> getLog() async {
    var db = await _connect();
    return db.getStringList('log') ?? [];
  }
}
