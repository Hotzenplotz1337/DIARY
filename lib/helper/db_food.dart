import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqlite_api.dart';

class DBFood {
  static Future<Database> databaseFood() async {
    final dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(path.join(dbPath, 'foods.db'),
        onCreate: (db1, version) {
      return db1.execute(
          'CREATE TABLE user_foods(id TEXT PRIMARY KEY, image TEXT, name TEXT, carbohydrates NUMBER, category TEXT, description TEXT)');
    }, version: 1);
  }

  static Future<void> insertFood(String table, Map<String, Object> data) async {
    final db1 = await DBFood.databaseFood();
    db1.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Map<String, dynamic>>> getFood(
      String table, search, bool isSearched) async {
    final db1 = await DBFood.databaseFood();
    // print(db1.query(table));
    return (isSearched)
        ? db1.query(
            table,
            where: "name LIKE '%$search%'",
            orderBy: 'name DESC',
          )
        : db1.query(
            table,
            orderBy: 'name DESC',
          );
  }

  static Future<List<Map<String, dynamic>>> getSearchedFood(
      String table, search, bool isSearched) async {
    final db1 = await DBFood.databaseFood();
    print(db1.query(table));
    return db1.query(table, where: "name LIKE '%$search%'");
  }

  static Future<void> updateFood(
      String table, id, Map<String, Object> data) async {
    final db = await DBFood.databaseFood();
    db.update(
      table,
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> removeFood(String table, id) async {
    final db1 = await DBFood.databaseFood();
    db1.delete(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
