// I want to make this demo create a table that has all the features that I want in my app.
// Once all of the features are present, I will work on integrating it into my actual app.
// My table needs to have
// [DONE] An ID column
// A date column
// A shot type column
// A Distance column
// A Throws column
// A Makes column
// A putter stack size column
// This video shows how to access the databases on the emulator https://www.youtube.com/watch?v=GZfFRv9VWtU&t=396s

import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DataBaseHelper {
  static const _dbName = "version3.db";
  static const _dbVersion = 2;
  static const _tableName = "myTable";

  static const columnId = "_id";
  static const columnName = "name";
  static const columnDate = "date";
  static const columnShotType = "shotType";
  static const columnDistance = "distance";
  static const columnThrows = 'throws';
  static const columnMakes = 'makes';
  static const columnStackSize = 'stackSize';
  static const columnStance = 'stance';
  static const columnNotes = 'notes';

  // Making it a singleton class
  DataBaseHelper._privateConstructor();
  static final DataBaseHelper instance = DataBaseHelper._privateConstructor();

  static Database? _database;
  Future<Database?> get database async {
    if (_database != null) return _database;

    _database = await _initiateDatabase();
    return _database;
  }

  _initiateDatabase() async {
    Directory? directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, _dbName);
    print(directory.path);
    print(_dbName);
    return await openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) => db.execute('''
    CREATE TABLE $_tableName (
    $columnId INTEGER PRIMARY KEY,
    $columnName TEXT,
    $columnDate TEXT,
    $columnShotType TEXT,
    $columnDistance INTEGER,
    $columnThrows INTEGER,
    $columnMakes INTEGER,
    $columnStackSize INTEGER,
    $columnStance TEXT,
    $columnNotes TEXT)
    ''');

  Future<int> insert(Map<String, dynamic> row) async {
    Database? db = await instance.database;
    return await db!.insert(_tableName, row);
  }

  Future<List<Map<String, dynamic>>> queryAll() async {
    Database? db = await instance.database;
    return db!.query(_tableName);
  }

  Future<int> update(Map<String, dynamic> row) async {
    Database? db = await instance.database;
    int id = row[columnId];
    return await db!.update(
      _tableName,
      row,
      where: "$columnId = ?",
      whereArgs: [id],
    );
  }

  Future<int> delete(int id) async {
    Database? db = await instance.database;
    return await db!
        .delete(_tableName, where: "$columnId = ?", whereArgs: [id]);
  }
}

// structure of the table returned by SQFLITE!
// {
//   "_id" : 12,
// "name" : "name"
// }
