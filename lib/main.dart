import 'package:flutter/material.dart';
import 'package:go_vegan/models/dev_only.dart';
import 'package:go_vegan/screens/login_page.dart';
import 'screens/main_page.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Butikkvare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.white),

      initialRoute: PictureScanner.screenId,
      routes: {

        LogInPage.screenId:(context)=>LogInPage(),
        PictureScanner.screenId:(context)=> PictureScanner(),
        HomePage.screenId:(context)=> HomePage(),
        //BarcodePage.screenId:(context)=> BarcodePage(),
        //BeLocation.screenId:(context)=>BeLocation(),
      },
    );
  }
}