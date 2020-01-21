import 'dart:io' show Directory;
import 'package:path/path.dart' show join;
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart' show getApplicationDocumentsDirectory;

class DatabaseHelper {

  static final _databaseName = "MyDatabase.db";
  static final _databaseVersion = 1;

  static final table = 'additivesTable';

  static final columnId = '_id';
  static final columnTitle = '_title';
  static final columnName = '_name';
  static final columnSuitableFor = '_suitablefor';
  static final columnDescription = '_description';
  static final columnCategory = '_category';
  static final columnStatus = '_status';


  // make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate,

    );
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {

    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY,
            $columnTitle TEXT,
            $columnName TEXT,
            $columnSuitableFor TEXT,
            $columnDescription TEXT,
            $columnCategory TEXT,
            $columnStatus TEXT
          )
          ''');


    await db.rawInsert(
        'INSERT INTO $table(_title,_name,_suitablefor,_description,_category, _status) VALUES(?,?,?,?,?,?)',
        ['E100', 'Curcumin (from turmeric)', 'Vegan', 'None','Colours, Yellow-orange','Approved in the EU. Approved in the US.']);

    await db.rawInsert(
        'INSERT INTO $table(_title,_name,_suitablefor,_description,_category, _status) VALUES(?,?,?,?,?,?)',
        ['E101', 'Riboflavin (Vitamin B2), formerly called lactoflavin', 'Hey', 'Colours Yellow-orange','Approved in the EU. Approved in the US']);

    await db.rawInsert(
        'INSERT INTO $table(_title,_name,_suitablefor,_description,_category, _status) VALUES(?,?,?,?,?,?)',
        ['E201', 'Bla', 'Bla', '', 'Vegan','']);

    await db.rawInsert(
        'INSERT INTO $table(_title,_name,_suitablefor,_description,_category, _status) VALUES(?,?,?,?,?,?)',
        ['', '', '', '', '','']);

  }


}