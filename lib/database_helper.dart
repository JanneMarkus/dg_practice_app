// I want to make this demo create a table that has all the features that I want in my app.
// Once all of the features are present, I will work on integrating it into my actual app.
// My table needs to have
// [DONE] An ID column
// A date column
// A Shot Angle column
// A Distance column
// A Throws column
// A Makes column
// A putter stack size column
// This video shows how to access the databases on the emulator https://www.youtube.com/watch?v=GZfFRv9VWtU&t=396s

// This code is SUPER messy.
// I have it so that if no DB exists, and the user tries to enter data to db, it will create a new db.
// But I had to copy the EXACT same code for the approach table,
// because if the person tried to enter data to that table first, the db wouldn't exist otherwise..
// In a perfect world, I would have the create function reference a higher level function
// that has the SQL command for creating all the tables that I need.

// I could have the create function loop through a list of all the tables that I want in the db and running an execute for each one.

import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

const databaseName = "profileBuild08152022_3.db";

const puttingTableCreate = """
    CREATE TABLE puttingTable (
    _id INTEGER PRIMARY KEY,
    name TEXT,
    date TEXT,
    shotAngle TEXT,
    distance INTEGER,
    throws INTEGER,
    makes INTEGER,
    stackSize INTEGER,
    stance TEXT,
    notes TEXT);""";

const approachTableCreate = """
    CREATE TABLE approachTable (
    _id INTEGER PRIMARY KEY,
    name TEXT,
    date TEXT,
    shotAngle TEXT,
    distance INTEGER,
    targetSize INTEGER,
    throws INTEGER,
    makes INTEGER,
    stackSize INTEGER,
    shotType TEXT,
    notes TEXT);
    """;

class DataBaseHelper {
  // This is for putting data
  static const _dbName = databaseName;
  static const _dbVersion = 1;
  static const _puttingTableName = "puttingTable";
  static const dbName = _dbName;

  static const columnId = "_id";
  static const columnName = "name";
  static const columnDate = "date";
  static const columnShotAngle = "shotAngle";
  static const columnDistance = "distance";
  static const columnTargetSize = "targetSize";
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

  Future _onCreate(Database db, int version) async {
    db.execute(puttingTableCreate);
    db.execute(approachTableCreate);
  }

  Future<int> insert(Map<String, dynamic> row) async {
    Database? db = await instance.database;
    return await db!.insert(_puttingTableName, row);
  }

  Future<List<Map<String, dynamic>>> queryAll() async {
    Database? db = await instance.database;
    return db!.query(_puttingTableName);
  }

  Future<int> update(Map<String, dynamic> row) async {
    Database? db = await instance.database;
    int id = row[columnId];
    return await db!.update(
      _puttingTableName,
      row,
      where: "$columnId = ?",
      whereArgs: [id],
    );
  }

  Future<int> delete(int id) async {
    Database? db = await instance.database;
    return await db!
        .delete(_puttingTableName, where: "$columnId = ?", whereArgs: [id]);
  }
}

class ApproachDataBaseHelper {
  // This is for approach data
  static const _dbName = databaseName;
  static const _dbVersion = 1;
  static const _approachTableName = "approachTable";
  static const dbName = _dbName;

  static const columnId = "_id";
  static const columnName = "name";
  static const columnDate = "date";
  static const columnShotAngle = "shotAngle";
  static const columnDistance = "distance";
  static const columnTargetSize = "targetSize";
  static const columnThrows = 'throws';
  static const columnMakes = 'makes';
  static const columnStackSize = 'stackSize';
  static const columnStance = 'stance';
  static const columnShotType = 'shotType';
  static const columnNotes = 'notes';

  // Making it a singleton class
  ApproachDataBaseHelper._privateConstructor();
  static final ApproachDataBaseHelper instance =
      ApproachDataBaseHelper._privateConstructor();

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

  Future _onCreate(Database db, int version) async {
    db.execute(puttingTableCreate);
    db.execute(approachTableCreate);
  }

  Future<int> insert(Map<String, dynamic> row) async {
    Database? db = await instance.database;
    return await db!.insert(_approachTableName, row);
  }

  Future<List<Map<String, dynamic>>> queryAll() async {
    Database? db = await instance.database;
    return db!.query(_approachTableName);
  }

  Future<int> update(Map<String, dynamic> row) async {
    Database? db = await instance.database;
    int id = row[columnId];
    return await db!.update(
      _approachTableName,
      row,
      where: "$columnId = ?",
      whereArgs: [id],
    );
  }

  Future<int> delete(int id) async {
    Database? db = await instance.database;
    return await db!
        .delete(_approachTableName, where: "$columnId = ?", whereArgs: [id]);
  }
}

// structure of the table returned by SQFLITE!
// {
//   "_id" : 12,
// "name" : "name"
// }
