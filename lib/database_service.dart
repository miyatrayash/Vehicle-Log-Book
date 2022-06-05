import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'model_log.dart';

class DatabaseService {
  static Database? _db;

  Future<Database> get db async => _db ??= await initDb();

  initDb() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "test.db");
    print(path);
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }

  void _onCreate(Database db, int version) async {

    await db.execute(
        '''CREATE TABLE 
            Auth(
              id INTEGER PRIMARY KEY,
              isLogged INTEGER
            )
        ''');

    await db.insert('Auth', {'id': 1,'isLogged': 0});

    await db.execute(
        '''CREATE TABLE 
            Log(
              id TEXT PRIMARY KEY,
              vehicleDetail TEXT NOT NULL,
              month TEXT NOT NULL,
              startingKM INTEGER NOT NULL,
              endingKM INTEGER NOT NULL,
              dailyKM TEXT NOT NULL,
              dailyDetail TEXT NOT NULL,
              fuelDetail TEXT NOT NULL
            )
        ''');
  }

  Future<Log?> getLogByMonth(DateTime month)  async {

    Database db = await this.db;
    final List<Map<String,dynamic>> maps = await db.query('Log',where: 'month = ?',whereArgs: [month.toIso8601String()]);

    if(maps.isEmpty) {
      return null;
    }

    return Log.fromJson(maps.first);
  }
  
  Future<bool> isLogged() async {
    Database db = await this.db;

    final List<Map<String,dynamic>> maps = await db.query('Auth');
    
    return maps.first['isLogged'] == 1;

  }
  
  Future<int> updateAuth() async {
    Database db = await this.db;
    
    return await db.update('Auth', {'id': 1,'isLogged': 1},where: 'id = ?',whereArgs: [1]);
  }

  Future<int> updateLog(Log log) async {
    Database db = await this.db;
    return await db.update('Log', log.toJson(),where: 'id = ?',whereArgs: [log.id]);
  }

  Future<int> insertLog(Log log) async {
    Database db = await this.db;

    return await db.insert('Log', log.toJson());
  }
}