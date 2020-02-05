import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqlite_api.dart';

class DBHelper {

  // method to create the Diary Entry database

  static Future<Database> database() async {
    final dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(path.join(dbPath, 'diary.db'),
        onCreate: (db, version) {
      return db.execute(
          'CREATE TABLE user_diary(id TEXT PRIMARY KEY, day TEXT, month TEXT, year TEXT, hour TEXT, minutes TEXT, currentValue TEXT, unitsInjected TEXT, sort TEXT, notes TEXT, isInjected INTEGER, meal INTEGER, sport INTEGER, bed INTEGER)');
    }, version: 1);
  }

  // method to insert a new Diary Entry to the database

  static Future<void> insertEntry(
      String table, Map<String, Object> data) async {
    final db = await DBHelper.database();
    db.insert(
      table,
      data,
      conflictAlgorithm: sql.ConflictAlgorithm.replace,
    );
  }

  // method to get all Diary Entrys from databse

  static Future<List<Map<String, dynamic>>> getData(
      String table, day, month, year, bool dayPicked) async {
    final db = await DBHelper.database();
    print(db.query(table));
    return (dayPicked)
        ? db.query(
            table,
            orderBy: "year ASC, month ASC, day ASC, hour ASC, minutes ASC",
            where:
                "day LIKE '%$day%'AND month LIKE '%$month%' AND year LIKE '%$year%'",
          )
        : db.query(
            table,
            orderBy: "year ASC, month ASC, day ASC, hour ASC, minutes ASC",
          );
  }

  // method to get specific Diary Entrys from database, searched for specific day

  static Future<List<Map<String, dynamic>>> getTodaysData(
    String table,
    String day,
    String month,
    String year,
  ) async {
    final db = await DBHelper.database();
    print(db.query(table));
    return db.query(
      table,
      orderBy: "hour ASC, minutes ASC",
      where:
          "day LIKE '%$day%'AND month LIKE '%$month%' AND year LIKE '%$year%'",
    );
  }

  // method to update a Diary Entry from database

  static Future<void> updateEntry(
      String table, id, Map<String, Object> data) async {
    final db = await DBHelper.database();
    db.update(
      table,
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // method to delete a Diary Entry from database 

  static Future<void> removeEntry(String table, id) async {
    final db = await DBHelper.database();
    db.delete(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
