import 'package:flutter/cupertino.dart';
import 'package:go_vegan/utils/db_helper.dart';
import 'package:sqflite/sqlite_api.dart';
import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
//Fetch all from table
Future<List> getAllRecords(String dbTable) async {
  Database db = await DatabaseHelper.instance.database;
  var result = await db.rawQuery("SELECT * FROM $dbTable");

  return result.toList();
}

//Fetching single
Future<List> query(String dbTable, String name) async {
  // get a reference to the database
  Database db = await DatabaseHelper.instance.database;
  // raw query

  List<Map> result =
  await db.rawQuery("SELECT * FROM $dbTable WHERE _title LIKE '%$name%' ORDER BY _title ASC");

  // print the results
  result.forEach((row) => print(row));
  // {_id: 2, name: Mary, age: 32}
  debugPrint('LENGDE: Dette er fra additives_data page: '+result.toString());
  debugPrint('LENGDE TALL: Dette er fra additives_data page: '+result.length.toString());

  return result;
}
insert() async {
  // get a reference to the database
  // because this is an expensive operation we use async and await
  Database db = await DatabaseHelper.instance.database;

  // show the results: print all rows in the db
  print(await db.query(DatabaseHelper.table));
}
