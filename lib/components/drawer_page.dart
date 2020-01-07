import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DrawerPage extends StatefulWidget {
  @override
  _DrawerPageState createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text("John Doe"),
            accountEmail: Text("john.doe@gmail.com"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Theme.of(context).platform == TargetPlatform.iOS
                  ? Colors.white
                  : Colors.white,
              child: Text(
                "JD",
                style: TextStyle(fontSize: 40.0),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.assignment),
            title: Text('Todo list'),
            onTap: () {
              Navigator.pop(context);
              // Update the state of the app.
              // ...
            },
          ),
          ListTile(
            leading: Icon(Icons.account_circle),
            title: Text('Settings'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Exit'),
            onTap: () {
              exit(0);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}




