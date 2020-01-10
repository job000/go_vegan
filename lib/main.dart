import 'package:flutter/material.dart';
import 'package:go_vegan/screens/barcode_page.dart';
import 'package:go_vegan/screens/loginPage.dart';
import 'screens/home_page.dart';
import 'custom_showDialog.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Butikkvare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: Colors.blue
      ),

      initialRoute: PictureScanner.screenId,
      routes: {

        LogInPage.screenId:(context)=>LogInPage(),
        PictureScanner.screenId:(context)=> PictureScanner(),
        //BarcodePage.screenId:(context)=> BarcodePage(),
        //BeLocation.screenId:(context)=>BeLocation(),
      },
    );
  }
}