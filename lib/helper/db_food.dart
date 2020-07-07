import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqlite_api.dart';

class DBFood {

  // method to create the Food Entry database 

  static Future<Database> databaseFood() async {
    final dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(path.join(dbPath, 'foods.db'),
        onCreate: (db1, version) {
      return db1.execute(
          'CREATE TABLE user_foods(id TEXT PRIMARY KEY, image TEXT, name TEXT, carbohydrates NUMBER, category TEXT, description TEXT)');
    }, version: 1);
  }

  // method to insert a new Food Entry to the database

  static Future<void> insertFood(String table, Map<String, Object> data) async {
    final db1 = await DBFood.databaseFood();
    db1.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // method to get all Food Entrys from database

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

  // method to get a specific Food Entry from database, searched for name

  static Future<List<Map<String, dynamic>>> getSearchedFood(
      String table, search, bool isSearched) async {
    final db1 = await DBFood.databaseFood();
    print(db1.query(table));
    return db1.query(table, where: "name LIKE '%$search%'");
  }

  // method to update a Food Entry from database

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

  // method to remove a Food Entry from database

  static Future<void> removeFood(String table, id) async {
    final db1 = await DBFood.databaseFood();
    db1.delete(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
