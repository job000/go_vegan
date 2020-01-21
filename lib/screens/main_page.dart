import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:go_vegan/components/gallery_screen.dart';
import 'package:go_vegan/components/string_manipulation.dart';
import 'package:go_vegan/models/additives_data.dart';
import 'package:go_vegan/utils/db_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'detector_painters.dart';
import 'package:go_vegan/components/veganAdditives.dart';
import 'package:go_vegan/components/custom_showDialog.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class PictureScanner extends StatefulWidget {

  static final String screenId = "mainPage";

  @override
  State<StatefulWidget> createState() => _PictureScannerState();
}

class _PictureScannerState extends State<PictureScanner>
    with TickerProviderStateMixin {

  Color listTileColor;
  File _imageFile;
  Size _imageSize;
  dynamic _scanResults;
  Detector _currentDetector = Detector.text;
  String textRecResult = '';
  List<CameraDescription> cameras;
  var firstCamera;

  Future<Null> _startCamera() async {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
    firstCamera = cameras.first;
  }

  _getImageFromGallery() async {
    _imageFile = await GalleryImage.openGallery();

    _getAndScanImage();
  }

  Future _getImageFromCamera() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 100);
    print('HER ER IMAGE $image');
    setState(() {
      _imageFile = image;
      print('BLAAAH IMAGE FILE:  $_imageFile');
    });
    _getAndScanImage();
  }

  Future<void> _showChoiceDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            elevation: 20.0,
            title: Center(
              child: Text(
                'Choose image',
                style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                    color: Colors.black54),
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  'Reset',
                  style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54),
                ),
                onPressed: () {
                  //SystemNavigator.pop();
                  setState(() {
                    Navigator.pop(context);
                    _imageFile = null;
                  });
                },
              )
            ],
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  GestureDetector(
                    child: Text(
                      'Gallery',
                      style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      _getImageFromGallery();
                    },
                  ),
                  Padding(padding: EdgeInsets.all(8.0)),
                  SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    child: Text(
                      'Camera',
                      style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      _getImageFromCamera();
                    },
                  ),
                  Padding(padding: EdgeInsets.all(8.0)),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          );
        });

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    additivesFromImage = [];
    _startCamera();

    //_getAndScanImage();
  }

  final BarcodeDetector _barcodeDetector =
      FirebaseVision.instance.barcodeDetector();
  final FaceDetector _faceDetector = FirebaseVision.instance.faceDetector();

  final ImageLabeler _imageLabeler = FirebaseVision.instance.imageLabeler();
  final ImageLabeler _cloudImageLabeler =
      FirebaseVision.instance.cloudImageLabeler();

  final TextRecognizer _recognizer = FirebaseVision.instance.textRecognizer();
  final TextRecognizer _cloudRecognizer =
      FirebaseVision.instance.cloudTextRecognizer();

  Future<void> _getAndScanImage() async {
    //final File imageFile = File(imagePath);//await ImagePicker.pickImage(source: ImageSource.gallery);
    if (_imageFile != null) {
      _getImageSize(_imageFile);
      _scanImage(_imageFile);
    }

    setState(() {
      _imageFile = _imageFile;
    });
  }

  Future<void> _getImageSize(File imageFile) async {
    final Completer<Size> completer = Completer<Size>();

    final Image image = Image.file(imageFile);
    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        ));
      }),
    );

    final Size imageSize = await completer.future;
    setState(() {
      _imageSize = imageSize;
    });
  }

  Future<void> _scanImage(File imageFile) async {
    setState(() {
      _scanResults = null;
    });

    final FirebaseVisionImage visionImage =
        FirebaseVisionImage.fromFile(imageFile);

    dynamic results;
    switch (_currentDetector) {
      case Detector.barcode:
        results = await _barcodeDetector.detectInImage(visionImage);
        break;
      case Detector.face:
        results = await _faceDetector.processImage(visionImage);
        break;
      case Detector.label:
        results = await _imageLabeler.processImage(visionImage);
        break;
      case Detector.cloudLabel:
        results = await _cloudImageLabeler.processImage(visionImage);
        break;
      case Detector.text:
        results = await _recognizer.processImage(visionImage);
        VisionText visionText = results;
        String text = visionText.text;
        //print(text); //TODO: Print ut resultat her.
        setState(() {
          textRecResult = text;
        });

        break;
      case Detector.cloudText:
        results = await _cloudRecognizer.processImage(visionImage);
        break;
      default:
        return;
    }

    setState(() {
      _scanResults = results;
    });
  }

  String search = "";
  TextEditingController textController;

  @override
  Widget build(BuildContext context) {
    var db = DatabaseHelper;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _imageFile == null
            ? Center(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left:10,top:10.0, right: 10),
                      child: TextField(
                        maxLength: 5,
                        textAlign: TextAlign.center,
                        autofocus: true,
                        decoration:InputDecoration(
                          hintText: 'Additive Number',
                          hintStyle: TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white70,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12.0)),
                            borderSide: BorderSide(color: Colors.redAccent, width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(color: Colors.orangeAccent),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        controller: textController,
                        onChanged: (item) async {
                          setState(() {
                            listOfSearch(item);
                            search = item;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      flex: 10,
                      child: Container(
                        decoration: new BoxDecoration(boxShadow: [
                          BoxShadow(
                            color: Colors.white70,
                            blurRadius: 25.0,
                          ),
                        ]),
                        color: listTileColor,
                        child: listValue(),
                      ),
                    ),
                  ],
                ),
              )
            : _getAdditives(),
      ),

      //_buildImage(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showChoiceDialog(context);
        },
        tooltip: 'Pick Image',
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }

  List listResult = [];
  listOfSearch(String _search) async {
    listResult = await query("additivesTable", _search);
    print("FRA listOfSearch $listResult");
  }

  Future<List> resultFromSearch() async {
    return listResult;
  }

  FutureBuilder<List> listValue() {
    debugPrint("INNNE I LISTVALUE: $search");

    if (search.isNotEmpty) {
      if (listResult.length > 0) {
        return FutureBuilder<List>(
          future: resultFromSearch(),
          initialData: List(),
          builder: (context, snapshot) {
            return snapshot.hasData
                ? ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: snapshot.data.length,
                    itemBuilder: (_, int position) {
                      final item = snapshot.data[position];
                      //get your item data here ...
                      return Card(
                        elevation: 8.0,
                        margin: new EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 6.0),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(40.0)),
                              color: Color.fromRGBO(64, 75, 96, .9)),
                          child: ListTile(
                            //TODO: Add another type of Icon
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 10.0),
                            leading: Container(
                              padding: EdgeInsets.only(right: 12.0),
                              decoration: new BoxDecoration(
                                  border: new Border(
                                      right: new BorderSide(
                                          width: 1.0, color: Colors.white24))),
                              child: Icon(Icons.info, color: Colors.white),
                            ),
                            onTap: () {
                              navigateToDetail(snapshot.data[position].row[1]);

                            },
                            title: Text(
                              snapshot.data[position].row[1].toString(),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Row(
                              children: <Widget>[
                                Icon(Icons.linear_scale,
                                    color: Colors.yellowAccent),
                                Text(snapshot.data[position].row[3].toString(),
                                    style: TextStyle(color: Colors.white))
                              ],
                            ),
                            trailing: Icon(Icons.keyboard_arrow_right,
                                color: Colors.white, size: 30.0),
                          ),
                        ),
                      );
                    },
                  )
                : Center(
                    child: CircularProgressIndicator(),
                  );
          },
        );
      }
      return FutureBuilder<List>(
        builder: (context, snapshot) {
          return Center(
            child: Text("COULD NOT FIND ANY DATA",
              style: TextStyle(fontWeight: FontWeight.w200,
                fontSize: 20.0,
              ),
            ),
          );
        },
      );
    } else {
      return FutureBuilder<List>(
        future: getAllRecords("additivesTable"),
        initialData: List(),
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: snapshot.data.length,
                  itemBuilder: (_, int position) {
                    final item = snapshot.data[position];
                    //get your item data here ...
                    return Card(
                      elevation: 8.0,
                      margin: new EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 6.0),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(40.0)),
                            color: Color.fromRGBO(64, 75, 96, .9)),
                        child: ListTile(
                          //TODO: Add another type of Icon
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 10.0),
                          leading: Container(
                            padding: EdgeInsets.only(right: 12.0),
                            decoration: new BoxDecoration(
                                border: new Border(
                                    right: new BorderSide(
                                        width: 1.0, color: Colors.white24))),
                            child: Icon(Icons.info, color: Colors.white),
                          ),
                          onTap: () {
                            navigateToDetail(snapshot.data[position].row[1]);

                          },
                          title: Text(
                            snapshot.data[position].row[1].toString(),
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Row(
                            children: <Widget>[
                              Icon(Icons.linear_scale,
                                  color: Colors.yellowAccent),
                              Text(snapshot.data[position].row[3].toString(),
                                  style: TextStyle(color: Colors.white))
                            ],
                          ),
                          trailing: Icon(Icons.keyboard_arrow_right,
                              color: Colors.white, size: 30.0),
                        ),
                      ),
                    );
                  },
                )
              : Center(
                  child: CircularProgressIndicator(),
                );
        },
      );
    }
  }

  //List of additives:
  List<String> veganAdditives = Vegan.veganAdditives;
  List<String> possiblyVeganAdditives = Vegan.possiblyNonVegan;
  List<String> nonVeganAdditives = Vegan.nonVegan;

  List<String> additivesFromImage = [];

  Widget _getAdditives() {
    Color textColor;
    additivesFromImage = addToAdditiveList(textRecResult);

    String data = '';
    int veganAdditiveCounter = 0;
    int _possiblyVeganAdditiveCounter = 0;
    int _nonVeganAdditivesCounter = 0;
    //additivesFromImage[j].toLowerCase().trim() ==
    //              veganAdditives[i].toLowerCase().trim()

    if (additivesFromImage.length > 0) {

      //For vegan check
      for (int j = 0; j < additivesFromImage.length; j++) {
        for (int i = 0; i < veganAdditives.length; i++) {
          //debugPrint(veganAdditives[i]);
          if (additivesFromImage[j].toLowerCase().trim() ==
              veganAdditives[i].toLowerCase().trim()) {
            veganAdditiveCounter++;
          } else {
            setState(() {
              data = 'Not Defined';
            });
          }
        }
      }

      //For Possibly Vegan check
      for (int j = 0; j < additivesFromImage.length; j++) {
        for (int i = 0; i < possiblyVeganAdditives.length; i++) {
          //debugPrint(veganAdditives[i]);
          if (additivesFromImage[j].toLowerCase().trim() ==
              possiblyVeganAdditives[i].toLowerCase().trim()) {
            _possiblyVeganAdditiveCounter++;
          } else {
            setState(() {
              data = 'Not Defined';
            });
          }
        }
      }


      //For Non Vegan check
      for (int j = 0; j < additivesFromImage.length; j++) {
        for (int i = 0; i < nonVeganAdditives.length; i++) {
          //debugPrint(veganAdditives[i]);
          if (additivesFromImage[j].toLowerCase().trim() ==
              nonVeganAdditives[i].toLowerCase().trim()) {
            _nonVeganAdditivesCounter++;
          } else {
            setState(() {
              data = 'Not Defined';
            });
          }
        }
      }

      debugPrint('Fra Bilder: ${additivesFromImage.length}');
      debugPrint('Vegan: ${veganAdditiveCounter.toString()}');

      debugPrint('Possibly vegan: ${_possiblyVeganAdditiveCounter.toString()}');
      debugPrint('Non vegan: ${_nonVeganAdditivesCounter.toString()}');

      if (veganAdditiveCounter == additivesFromImage.length &&
          _possiblyVeganAdditiveCounter <= 0 &&
          _nonVeganAdditivesCounter <= 0) {
        setState(() {
          data = 'Vegan';
          textColor = Colors.greenAccent;
          veganAdditiveCounter = 0;
        });
      } else if (_possiblyVeganAdditiveCounter > 0 &&
          _nonVeganAdditivesCounter <= 0) {
        setState(() {
          data = 'Might not be vegan';
          textColor = Colors.orangeAccent;
          _possiblyVeganAdditiveCounter = 0;
        });
      } else if (_nonVeganAdditivesCounter > 0) {
        setState(() {
          data = 'Not Vegan';
          textColor = Colors.redAccent;
          _nonVeganAdditivesCounter = 0;
        });
      }
    } else {
      data = 'Cannot find any additives';
      textColor = Colors.red;
    }

    //return Text(data);
    return Center(
      child: Column(
        children: <Widget>[
          Expanded(
              flex: 1,
              child: Container(
                color: Colors.transparent,
                child: Card(
                  color: Colors.white,
                  elevation: 10.0,
                  child: Center(
                      child: Text(data,
                          style: TextStyle(
                            fontSize: 30.0,
                            color: textColor,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ))),
                ),
              )),

          Expanded(
            flex: 2,
            child: Container(
              color: listTileColor,
              child: ListView.builder(
                itemCount: additivesFromImage.length,
                itemBuilder: (context, index) {
                    _setAdditiveSuitableFor(additivesFromImage[index]); //TODO: FIX THIS because this gives the same value of all the item in the list
                  return Container(
                    decoration: new BoxDecoration(boxShadow: [
                      new BoxShadow(
                        color: Colors.white,
                        blurRadius: 20.0,
                      ),
                    ]),
                    child: Card(
                      elevation: 8.0,
                      margin: new EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 6.0),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(40.0)),
                            color: Color.fromRGBO(64, 75, 96, .9)),
                        //decoration: BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 10.0),
                          leading: Container(
                            padding: EdgeInsets.only(right: 12.0),
                            decoration: new BoxDecoration(
                                border: new Border(
                                    right: new BorderSide(
                                        width: 1.0, color: Colors.white24))),
                            child: Icon(Icons.info, color: Colors.white),
                          ),

                          title: Text(
                            additivesFromImage[index],
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Row(
                            children: <Widget>[
                              Icon(Icons.linear_scale,
                                  color: Colors.yellowAccent),
                              Text(
                                  _getAdditiveSuitableFor() == null
                                      ? ''
                                      : _getAdditiveSuitableFor(),
                                  style: TextStyle(color: Colors.white))
                            ],
                          ),
                          trailing: Icon(Icons.keyboard_arrow_right,
                              color: Colors.white, size: 30.0),
                          onTap: () {
                            setState(() {
                              navigateToDetail(additivesFromImage[index]);
                            });
                          },

                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }


  String _tableName = 'additivesTable';
  String _suitableFor; //TODO: CREATE DYNAMIC SUITABLE when user gets image or
 void _setAdditiveSuitableFor(String identifier) async {
    Map result;
      List the = await query(_tableName, identifier);
      result = the.asMap();
      debugPrint("IDENTIFIER ER: $identifier");
    debugPrint('HELLLLOOOOOOOOA: ${result.toString()}');
      for (int key in result.keys) {
        debugPrint("Detter er: ${result[key]['_title'].toString()}");
        if (result[key]['_title'].toString() == identifier) {
          setState(() {
            _suitableFor = result[key]['_suitablefor'].toString();
            debugPrint("_SUITABLEFOR ER: $_suitableFor");
          });
        }
      }
  }

  String _getAdditiveSuitableFor() {
    return _suitableFor;
  }

  void navigateToDetail(String additiveIdentifier) async {
    //NoteDetail(note, title);
    debugPrint("HER FRA HOME_PAGE: $additiveIdentifier");
    showDialog(
        context: context,
        builder: (BuildContext context) =>
            CustomDialogPage(additiveIdentifier: additiveIdentifier));

    //Navigator.push(context, MaterialPageRoute(builder:(context)=>CustomDialogPage(additiveIdentifier: additiveIdentifier)));
  }

  @override
  void dispose() {
    _barcodeDetector.close();
    _faceDetector.close();
    _imageLabeler.close();
    _cloudImageLabeler.close();
    _recognizer.close();
    _cloudRecognizer.close();
    super.dispose();
  }
}
