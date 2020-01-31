import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_vegan/models/additives_data.dart';
import 'dart:async';

import 'package:go_vegan/utils/db_helper.dart';

class GetListOfAdditivesFromImage {
  List listResultQuery = new List();
  List<Map> tempListFromQuery;

  Future<List> listOfQuery(List imageAdditives) async {
    listResultQuery.clear();
    for (int i = 0; i < imageAdditives.length; i++) {
      tempListFromQuery = await query("additivesTable", imageAdditives[i]);
      listResultQuery.addAll(tempListFromQuery);
    }
    return listResultQuery;
  }

  Color textColor = Colors.redAccent;
  Future<List<String>> veganAdditiveChecker(List<String> imageAdditives) async {
    List veganOrNot = new List();
    int vegan;
    int mightBeVegan;
    int notVegan;
    int notDefined;

    for (int i = 0; i < imageAdditives.length; i++) {
      tempListFromQuery = await query("additivesTable", imageAdditives.toString());
      //veganOrNot.add(tempListFromQuery[i]['_suitablefor']);
      print("new for loop= ${veganOrNot.toList()}");
    }

    print("HER $veganOrNot");

    print("veganAdditiveChecker :: ${imageAdditives.toString()}");

    //listResultQuery.clear();

    for (int i = 0; i < imageAdditives.length; i++) {
      var db = await DatabaseHelper.instance.database;
      print("imageAdditives.length::: ${imageAdditives.length}");
      print("imageAdditives[$i]: ${imageAdditives[i]}");
      tempListFromQuery = await query("additivesTable", imageAdditives[i]);
      print("veganOrNot::: $veganOrNot");

      if(tempListFromQuery.length>0) {

        print("QUERY in String:-> ${tempListFromQuery[i]['_suitablefor']}");
        if (tempListFromQuery.toList()[0]['_suitablefor'].toString()=="Vegan") {
          print("tempListFromQuery[i]['_suitablefor'].toString():: ${tempListFromQuery[i]['_suitablefor'].toString()}");
          vegan++;
        }
        else if (tempListFromQuery.toList()[0]['_suitablefor'].toString()=="May or may not be vegan") {
          print("tempListFromQuery[i]['_suitablefor'].toString():: ${tempListFromQuery[i]['_suitablefor'].toString()}");
          mightBeVegan++;
        }
        else if (tempListFromQuery.toList()[0]['_suitablefor'].toString()=="Not vegan") {

          notVegan++;
        }
        else if (imageAdditives.length <= 0 && imageAdditives != null) {
          tempListFromQuery.clear();
          notDefined++;
        }
        print("Number of vegan: $vegan");
        print("Number of Not vegan: $notVegan");
        print("Number of Maybe vegan: $mightBeVegan");
        //print("QUERY 3: $queryInString}");
      }
    }

    if (vegan > 0 && notVegan <= 0 && mightBeVegan <= 0 && notDefined <= 0) {
      veganOrNot = ["Vegan"];
      textColor = Colors.greenAccent;
    } else if (notVegan <= 0 && mightBeVegan > 0) {
      veganOrNot=["May or may not be vegan"];
      textColor = Colors.orangeAccent;
    } else if (notVegan > 0) {
      veganOrNot = ["Not vegan"];
      textColor = Colors.redAccent;
    } else {
      veganOrNot = ["No additive(s) found"];
    }

    print("veganOrNot: $veganOrNot");
    return veganOrNot.toList();
  }
}
