import 'package:flutter/cupertino.dart';
import 'package:go_vegan/utils/db_helper.dart';
import 'package:sqflite/sqlite_api.dart';
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

  List<String> possiblyNonVegan = [
    'E153',
    'E161g',
    'E161h',
    'E161i',
    'E161j',
    'E252',
    'E270',
    'E322',
    'E325',
    'E326',
    'E327',
    'E422',
    'E430',
    'E431',
    'E432',
    'E433',
    'E434',
    'E435',
    'E436',
    'E442',
    'E470a',
    'E470b',
    'E471',
    'E472a',
    'E472b',
    'E472c',
    'E472d',
    'E472e',
    'E472f',
    'E473',
    'E474',
    'E475',
    'E476',
    'E477',
    'E478',
    'E479b',
    'E481',
    'E482',
    'E483',
    'E491',
    'E492',
    'E493',
    'E494',
    'E495',
    'E570',
    'E572',
    'E585',
    'E627',
    'E631',
    'E635',
    'E640'
  ];

  await db.rawInsert(
      'INSERT INTO my_table(_title,_name,_color,_description,_category) VALUES(?,?,?,?,?)',
      ['E151', 'E151', 'Yellow', 'This is the other test', 'Vegan']);
  await db.rawInsert(
      'INSERT INTO my_table(_title,_name,_color,_description,_category) VALUES(?,?,?,?,?)',
      ['E152', 'E152', 'Grey', 'Yes', 'Vegan']);
  await db.rawInsert(
      'INSERT INTO my_table(_title,_name,_color,_description,_category) VALUES(?,?,?,?,?)',
      ['E170', 'E170', 'Blue', 'This is the other test', 'Vegan']);
  await db.rawInsert(
      'INSERT INTO my_table(_title,_name,_color,_description,_category) VALUES(?,?,?,?,?)',
      ['E471', 'E471', 'Yellow', 'This is the other test', 'Vegan']);
  await db.rawInsert(
      'INSERT INTO my_table(_title,_name,_color,_description,_category) VALUES(?,?,?,?,?)',
      ['E472', 'E472', 'Blue', 'This is the other test', 'Vegan']);

  await db.rawInsert(
      'INSERT INTO my_table(_title,_name,_color,_description,_category) VALUES(?,?,?,?,?)',
      ['E100', 'Curcumin(from turmeric)', 'Yellow-orange', 'This is the other test', '']);

  await db.rawInsert(
      'INSERT INTO my_table(_title,_name,_color,_description,_category) VALUES(?,?,?,?,?)',
      ['E123', 'Curcumin(from turmeric)', 'Yellow-orange', 'This is the other test', '']);

  await db.rawInsert(
      'INSERT INTO my_table(_title,_name,_color,_description,_category) VALUES(?,?,?,?,?)',
      ['E300', 'Dette', 'Yellow-orange', 'This is the other test', '']);

  await db.rawInsert(
      'INSERT INTO my_table(_title,_name,_color,_description,_category) VALUES(?,?,?,?,?)',
      ['E300', 'Dette', 'Yellow-orange', 'This is the other test', '']);



  /*
  int id = 0;
  for(int i=0;i<possiblyNonVegan.length;i++) {
    id = await db.rawInsert('INSERT INTO my_table(_name) VALUES(?)', [possiblyNonVegan[i]]);
    debugPrint('ID: ${id.toString()}');
  }

  */

  // show the results: print all rows in the db
  print(await db.query(DatabaseHelper.table));
}


