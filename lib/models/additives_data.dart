import 'package:async/async.dart';
import 'package:go_vegan/utils/db_helper.dart';
import 'package:sqflite/sqlite_api.dart';
import 'dart:async';
import 'package:sqflite/sqflite.dart';
//Fetch all from table


Future<List> getAllRecords(String dbTable) async {
  Database db = await DatabaseHelper.instance.database;
  var result = await db.rawQuery("SELECT * FROM $dbTable");

  return result.toList();
}

//Fetching single
Future<List> query(String dbTable, String name) async {
  List<Map> _result=[];
  _result.clear();
  // get a reference to the database
  Database db = await DatabaseHelper.instance.database;
  // raw query

  _result =
  await db.rawQuery("SELECT * FROM $dbTable WHERE _title LIKE'%$name' ORDER BY _title ASC");

  // print the results
 //_result.forEach((row) => print("BLAAAAAAAAAAH fra query foreach: $row"));
  // {_id: 2, name: Mary, age: 32}
  return _result;
}

Future<List> multipleQuery(String dbTable, List listOfQuery) async {
  List<Map> _result=[];
  List tempResult;
  List anotherOne;
  _result.clear();
  // get a reference to the database
  Database db = await DatabaseHelper.instance.database;

  for(int i=0; i<listOfQuery.length; i++) {
    _result =
    await db.rawQuery(
        "SELECT * FROM $dbTable WHERE _title LIKE '%${listOfQuery[i]}' ORDER BY _title ASC");
    anotherOne.add(_result.toList()[i]['_suitablefor']);
  }
  print("anotherOne:::: ${anotherOne.toString()}");
  return anotherOne;
}

insert() async {
  // get a reference to the database
  // because this is an expensive operation we use async and await
  Database db = await DatabaseHelper.instance.database;

  // show the results: print all rows in the db
  //print(await db.query(DatabaseHelper.table));
}