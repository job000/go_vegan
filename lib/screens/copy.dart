/*
import 'package:flutter/material.dart';
//import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:io';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_camera_ml_vision/flutter_camera_ml_vision.dart';


class HomePage extends StatefulWidget {
  static const String screenId = 'HomePage';

  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}


final databaseReference = Firestore.instance;

class HomePageState extends State<HomePage> {

  String barcode = "";
  var text;
  var vegOrNot="";

  void updateData() {
    try {
      databaseReference
          .collection('Vegansk Produkter')
          .document('1')
          .updateData({'id': '2'});
    } catch (e) {
      print(e.toString());
    }
  }
/*
 checkBarcodeWithDatabase(){

    if(barcode==text){
      print("Vegan");
      vegOrNot="Vegan";
    }else{
      print("Not registered yet.");
      vegOrNot="Not registered in our database, would you like to register?";
    }
  }

 */


  void getDataAuto(){
    CollectionReference reference = Firestore.instance.collection('Vegansk Produkter');
    reference.snapshots().listen((querySnapshot) {
      querySnapshot.documentChanges.forEach((change) {
        // Do something with change
        setState(() {
          print(change.document.data.toString());
          text=change.document.data['strekkode'];
        });
      });
    });
  }


/*
  void getData() {

    databaseReference
        .collection("Vegansk Produkter")
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((f) {
        print('${f.data}}');

        setState(() {
          text = f.data;
        });
      });
    });
  }

 */


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDataAuto();
    //updateData();
    //getData();

    getDriversList().then((results) {
      setState(() {
        querySnapshot = results;
      });
    });
  }
  QuerySnapshot querySnapshot;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        title: Text('Homepage'),
      ),
      drawer: (Drawer(
          child: UserAccountsDrawerHeader(
            accountName: Text('JM'),
            accountEmail: Text('Test'),
          ))),
      body: _showDrivers(),
    );
  }

  Widget _showDrivers() {

    if(barcode.isEmpty){
      return Center(
        child: new Column(
          children: <Widget>[
            new Container(
              child: new RaisedButton(
                  onPressed: barcodeScanning, child: new Text("Capture image")),
              padding: const EdgeInsets.all(8.0),
            ),
            new Padding(
              padding: const EdgeInsets.all(8.0),
            ),
            Text("Barcode Number after Scan : " + barcode),
            // displayImage(),
          ],
        ),
      );
    }else {
      //check if querysnapshot is null
      if (querySnapshot != null) {
        for (int i = 0; i < querySnapshot.documents.length; i++) {
          text = querySnapshot.documents[i].data['strekkode'];


          if (barcode == text) {
            setState(() {
              vegOrNot = 'Vegan';
            });
            break;
          }  else {
            setState(() {
              vegOrNot='Not registered yet';
            });
          }
        }

        print(vegOrNot);
        return Center(child: Column(children: <Widget>[
          RaisedButton(
              onPressed: barcodeScanning, child: new Text("Capture image")),
          SizedBox(height: 20.0,),
          Text(vegOrNot),

        ],)

        );


        /*
      return ListView.builder(
        primary: false,
        itemCount: querySnapshot.documents.length,
        padding: EdgeInsets.all(12),
        itemBuilder: (context, i) {
          return Column(
            children: <Widget>[
//load data into widgets

              Text("${querySnapshot.documents[i].data['id']}"),
              Text("${querySnapshot.documents[i].data['kategori']}"),
              Text("${querySnapshot.documents[i].data['produktnavn']}"),
              Text(text),

            ],
          );
        },
      );

       */
      } else {
        return Center(
          child: CircularProgressIndicator(),
        );
      }
    }
  }

  //get firestore instance
  getDriversList() async {
    return await Firestore.instance.collection('Vegansk Produkter').getDocuments();
  }

  Future barcodeScanning() async {
//imageSelectorGallery();

    try {
      String barcode = await BarcodeScanner.scan();
      setState(() => this.barcode = barcode);

    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          this.barcode = 'No camera permission!';
        });
      } else {
        setState(() => this.barcode = 'Unknown error: $e');
      }
    } on FormatException {
      setState(() => this.barcode =
      'Nothing captured.');
    } catch (e) {
      setState(() => this.barcode = 'Unknown error: $e');
    }
  }
}


 */