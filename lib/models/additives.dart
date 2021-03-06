/*import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:go_vegan/models/additives.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper; // Singleton DatabaseHelper
  static Database _database; // Singleton Database

  String additivesTable = 'additives_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colName = 'name';
  String colColor = 'color';
  String colCategory = 'category';

  DatabaseHelper._createInstance(); // Named constructor to create instance of DatabaseHelper

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper
          ._createInstance(); // This is executed only once, singleton object
    }
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    // Get the directory path for both Android and iOS to store database.
    Directory directory = await getApplicationDocumentsDirectory();
    String path =
        join(directory.path, 'additives.db'); //directory.path + 'notes.db';

    // Open/create the database at a given path
    var notesDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return notesDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute('CREATE TABLE $additivesTable('
        '$colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT,$colColor TEXT, '
        '$colDescription TEXT, $colCategory TEXT, $colName TEXT)'); //TODO: priority=>category and date=>Name
  }

  //TODO: priority=>category and date=>Name
  // Fetch Operation: Get all note objects from database
  Future<List<Map<String, dynamic>>> getAdditivesMapList() async {
    Database db = await this.database;

//		var result = await db.rawQuery('SELECT * FROM $noteTable order by $colPriority ASC');
    var result = await db.query(additivesTable, orderBy: '$colCategory ASC');
    return result;
  }

  // Insert Operation: Insert a Note object to database
  Future<int> insertAdditives(Additives additives) async {
    Database db = await this.database;
    var result = await db.insert(additivesTable, additives.toMap());
    return result;
  }

  // Update Operation: Update a Note object and save it to database
  Future<int> updateAdditives(Additives additives) async {
    var db = await this.database;
    var result = await db.update(additivesTable, additives.toMap(),
        where: '$colId = ?', whereArgs: [additives.id]);
    return result;
  }

  // Delete Operation: Delete a Note object from database
  Future<int> deleteAdditives(int id) async {
    var db = await this.database;
    int result =
        await db.rawDelete('DELETE FROM $additivesTable WHERE $colId = $id');
    return result;
  }

  // Get number of Note objects in database
  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $additivesTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  // Get the 'Map List' [ List<Map> ] and convert it to 'Note List' [ List<Note> ]
  Future<List<Additives>> getAdditivesList() async {
    var additivesMapList =
        await getAdditivesMapList(); // Get 'Map List' from database
    int count =
        additivesMapList.length; // Count the number of map entries in db table

    List<Additives> additivesList = List<Additives>();
    // For loop to create a 'Note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      additivesList.add(Additives.fromMapObject(additivesMapList[i]));
    }

    return additivesList;
  }
}*/
