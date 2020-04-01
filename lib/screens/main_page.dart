import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:go_vegan/components/gallery_screen.dart';
import 'package:go_vegan/components/getListOfAdditivesFromImage.dart';
import 'package:go_vegan/components/string_manipulation.dart';
import 'package:go_vegan/main.dart';
import 'package:go_vegan/models/additives_data.dart';
import 'package:go_vegan/models/dev_only.dart';
import 'package:go_vegan/utils/db_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:sqflite/sqflite.dart';
import 'detector_painters.dart';
import 'package:go_vegan/components/veganAdditives.dart';
import 'package:go_vegan/components/custom_showDialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_vegan/components/custom_errorDialog.dart';

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

  CameraDescription description;
  CameraController _controller;

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

  bool triggerAfterDuration = false;
  Future<void> _showChoiceDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            contentPadding: EdgeInsets.only(top: 10.0),
            elevation: 20.0,
            title: Text(
              'Choose image',
              style: TextStyle(
                  fontSize: 22.0, letterSpacing: 0.5, color: Colors.black87),
            ),
            content: SingleChildScrollView(
              child: Container(
                width: 300.0,
                child: ListBody(
                  children: <Widget>[
                    Divider(
                      color: Colors.grey,
                      height: 4.0,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: GestureDetector(
                        onTap: () {
                          //Navigator.of(context).pop();
                          setState(() {
                            Navigator.pop(context);
                            additivesFromImage.clear();
                            _imageFile = null;
                          });
                          _getImageFromGallery();
                        },
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.add_photo_alternate,
                              color: Colors.tealAccent,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              'Gallery',
                              style: TextStyle(
                                  fontSize: 20.0, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(8.0)),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            Navigator.pop(context);
                            additivesFromImage.clear();
                            _imageFile = null;
                          });
                          //Navigator.of(context).pop();
                          _getImageFromCamera();
                        },
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.add_a_photo,
                              color: Colors.tealAccent,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              'Camera',
                              style: TextStyle(
                                  fontSize: 20.0, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(8.0)),
                    SizedBox(
                      height: 10,
                    ),
                    InkWell(
                      child: Container(
                        padding: EdgeInsets.only(top: 10.0, bottom: 5.0),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey,
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(20.0),
                              bottomRight: Radius.circular(20.0)),
                        ),
                        child: FlatButton(
                          child: Text(
                            "Back",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                          onPressed: () {
                            //SystemNavigator.pop();
                            setState(() {
                              Navigator.pop(context);
                              additivesFromImage.clear();
                              _imageFile = null;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  var getListOfAdditivesFromImage = GetListOfAdditivesFromImage();
  FocusNode focusNode;

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
  final textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var db = DatabaseHelper;
    additivesFromImage.clear(); //TODO: THIS DID THE TRICK: AVOIDING DUPLICATES

    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: SafeArea(
        child: _imageFile == null
            ? Center(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 10, top: 10.0, right: 10),
                      child: TextField(
                        focusNode: focusNode,
                        textDirection: TextDirection.ltr,
                        maxLength: 5,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                            letterSpacing: 1.2),
                        autofocus: false,
                        decoration: InputDecoration(
                          alignLabelWithHint: true,
                          hintText: 'Search',
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize: 18),
                          filled: true,
                          fillColor: Colors.white70,
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12.0)),
                            borderSide:
                                BorderSide(color: Colors.tealAccent, width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(color: Colors.greenAccent),
                          ),
                        ),
                        keyboardType: TextInputType.multiline,
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
        backgroundColor: Colors.blueGrey,
        onPressed: () {
          _showChoiceDialog(context);
        },
        tooltip: 'Pick Image',
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }

  List listResult = [];

  Future<List> listOfSearch(String _search) async {
    listResult = await query("additivesTable", _search);
    //print("FRA listOfSearch $listResult");
    return listResult;
  }

  /*
  // This is for the text above the list when getting image from gallery or camera
  String veganOrNot;
  Color textColor;
   Future<String> queryImage(List additives) async{
     Database db;
    int veganCounter=0;
    int mightBeVeganCounter=0;
    int notVeganCounter=0;
    int notDefinedCounter=0;
    List<Map> resultOfQuery;
    Map resultInMap;
    var stream;
    List listOfAdditiveSuitable;
    for(int i=0;i<additives.length;i++){
      db.transaction((txn) async{
        stream =  query("additivesTable", additives[i]).asStream();
      });

      //resultOfQuery = await query("additivesTable", additives[i]);
      //print("HÆH1? $resultOfQuery");
      //print("HÆH? ${resultOfQuery.toList()[0]['_suitablefor']}");
      var additiveFromDb = resultOfQuery.toList()[0]['_suitablefor'];
      if(additiveFromDb == "Vegan"){
        setState(() {
          veganCounter++;
        });

      }else if(additiveFromDb == "May or may not be vegan"){
        setState(() {
          mightBeVeganCounter++;
        });
      }else if(additiveFromDb == "Not vegan"){
        setState(() {
          notVeganCounter++;
        });
      }else{
        setState(() {
          notDefinedCounter++;
        });
      }
    }

    print("veganCounter $veganCounter");
    print("mightbeVeganCounter $mightBeVeganCounter");
    print("notVeganCounter $notVeganCounter");
    print("notDefinedCounter $notDefinedCounter");

    if (veganCounter > 0 && notVeganCounter <= 0 && mightBeVeganCounter <= 0 && notDefinedCounter <= 0) {
      setState(() {
        veganOrNot = "Vegan";
        textColor = Colors.greenAccent;
      });
    } else if (notVeganCounter <= 0 && mightBeVeganCounter > 0) {
      setState(() {
        veganOrNot = "May or may not be vegan";
        textColor = Colors.orangeAccent;
      });
    } else if (notVeganCounter > 0) {

      setState(() {
        veganOrNot = "Not vegan";
        textColor = Colors.redAccent;
      });

    } else {
      setState(() {
        veganOrNot = "No additive(s) found";
      });

    }
    return veganOrNot;
  }

  String getVeganOrNot(){
     String newValue;
     queryImage(additivesFromImage).then((onValue){
       newValue = onValue;
     });
     return newValue;
  }


*/
  FutureBuilder<List> listValue() {
    //debugPrint("INNE I LISTVALUE: $search");

    if (search.isNotEmpty) {
      if (listResult.length > 0) {
        return FutureBuilder<List>(
          future: listOfSearch(search),
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
                      return Hero(
                        tag: snapshot.data[position],
                        child: Card(
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
                                            width: 1.0,
                                            color: Colors.white24))),
                                child: Icon(Icons.info, color: Colors.white),
                              ),
                              onTap: () {
                                navigateToDetail(
                                    snapshot.data[position].row[1]);
                              },
                              title: Text(
                                snapshot.data[position].row[1].toString(),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Row(
                                children: <Widget>[
                                  Icon(Icons.colorize,
                                      color: Colors.yellowAccent),
                                  Text(
                                      snapshot.data[position].row[3].toString(),
                                      style: TextStyle(color: Colors.white))
                                ],
                              ),
                              trailing: Icon(Icons.keyboard_arrow_right,
                                  color: Colors.white, size: 30.0),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.redAccent,
                      strokeWidth: 10,
                    ),
                  );
          },
        );
      }
      return FutureBuilder<List>(
        builder: (context, snapshot) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.redAccent,
              strokeWidth: 10,
            ),
          );
        },
      );
    } else {
      return FutureBuilder<List>(
        future: getAllRecords("additivesTable"), //Database
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
                              Icon(Icons.colorize, color: Colors.greenAccent),
                              Text(snapshot.data[position].row[3].toString(),
                                  style: TextStyle(color: Colors.white)),
                              SizedBox(
                                width: 10,
                              )
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
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.redAccent,
                    strokeWidth: 10,
                  ),
                );
        },
      );
    }
  }

  //List of additives:
  List<String> veganAdditives = Vegan.veganAdditives;
  List<String> possiblyVeganAdditives = Vegan.possiblyNonVegan;
  List<String> nonVeganAdditives = Vegan.nonVegan;

  List additivesFromImage = [];
  String data;
  int veganAdditiveCounter = 0;
  int _possiblyVeganAdditiveCounter = 0;
  int _nonVeganAdditivesCounter = 0;
  void getAdditives() {
    setState(() {
      additivesFromImage = addToAdditiveList(textRecResult);
    });
  }

  Widget _getAdditives() {
    Color textColor = Colors.white70;
    getAdditives();
    print("Lengde er: ${additivesFromImage.length}");

    //additivesFromImage[j].toLowerCase().trim() ==
    //              veganAdditives[i].toLowerCase().trim()
    if (additivesFromImage.length > 0) {
      //For vegan check
      for (int j = 0; j < additivesFromImage.length; j++) {
        for (int i = 0; i < veganAdditives.length; i++) {
          debugPrint(additivesFromImage[j]);
          if (additivesFromImage[j].toLowerCase().trim() ==
              veganAdditives[i].toLowerCase().trim()) {
            veganAdditiveCounter++;
            setState(() {
              data = "Vegan";
            });
            break;
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
            setState(() {
              data = "May or may not be vegan";
            });
            break;
          } else {
            data = "";
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
            setState(() {
              data = "Not vegan";
            });
            break;
          } else {
            data = "";
          }
        }
      }

      debugPrint('Fra Bilder: ${additivesFromImage.length}');
      debugPrint('Vegan: ${veganAdditiveCounter.toString()}');
      debugPrint('Possibly vegan: ${_possiblyVeganAdditiveCounter.toString()}');
      debugPrint('Non vegan: ${_nonVeganAdditivesCounter.toString()}');

      if (veganAdditiveCounter > 0 &&
          _possiblyVeganAdditiveCounter <= 0 &&
          _nonVeganAdditivesCounter <= 0) {
        setState(() {
          data = 'Vegan';
          textColor = Colors.greenAccent;
          //veganAdditiveCounter = 0;
        });
      } else if (_possiblyVeganAdditiveCounter > 0 &&
          _nonVeganAdditivesCounter <= 0 &&
          veganAdditiveCounter <= 0) {
        setState(() {
          data = 'May or may not be vegan';
          textColor = Colors.orangeAccent;
          //_possiblyVeganAdditiveCounter = 0;
        });
      } else if (_nonVeganAdditivesCounter > 0) {
        setState(() {
          data = 'Not Vegan';
          textColor = Colors.redAccent;
          //_nonVeganAdditivesCounter = 0;
        });
      }

      //return Text(data);
      //TODO: CREATE DYNAMIC SUITABLE FOR UNDER
      return Center(
        child: Hero(
          tag: 'identifier',
          child: GestureDetector(
            onHorizontalDragStart: (DragStartDetails start) {
              Navigator.pushNamed(context, PictureScanner.screenId);
              setState(() {
                Navigator.pop(context);
                additivesFromImage.clear();
                _imageFile = null;
              });
            },
            child: FutureBuilder<List>(
              future:
                  getListOfAdditivesFromImage.listOfQuery(additivesFromImage),
              initialData: List(),
              builder: (context, snapshot) {
                return snapshot.hasData
                    ? Column(
                        children: <Widget>[
                          //Could add another Expanded here
                          Expanded(
                            flex: 6,
                            child: ListView.builder(
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
                                      key: Key(snapshot.data[position].row[1]),
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 20.0, vertical: 10.0),
                                      leading: Container(
                                        padding: EdgeInsets.only(right: 12.0),
                                        decoration: new BoxDecoration(
                                            border: new Border(
                                                right: new BorderSide(
                                                    width: 1.0,
                                                    color: Colors.white24))),
                                        child: Icon(Icons.info,
                                            color: Colors.white),
                                      ),
                                      onTap: () {
                                        navigateToDetail(
                                            snapshot.data[position].row[1]);
                                      },

                                      title: Text(
                                        snapshot.data[position].row[1]
                                            .toString(),
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Row(
                                        children: <Widget>[
                                          Icon(Icons.colorize,
                                              color: Colors.yellowAccent),
                                          Text(
                                              snapshot.data[position].row[3]
                                                  .toString(),
                                              style: TextStyle(
                                                  color: Colors.white))
                                        ],
                                      ),
                                      trailing: Icon(Icons.keyboard_arrow_right,
                                          color: Colors.white, size: 30.0),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      )
                    : Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.redAccent,
                          strokeWidth: 10,
                        ),
                      );
              },
            ),
          ),
        ),
      );
    } else {
      Timer(Duration(seconds: 2), () {
        setState(() {
          triggerAfterDuration = true;
        });
      });

      if (triggerAfterDuration) {
        return customErrorDialog(context);
      } else {
        return Center(
          child: CircularProgressIndicator(
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  String getData() {
    return this.data;
  }

  void navigateToDetail(String additiveIdentifier) async {
    //NoteDetail(note, title);
    //debugPrint("HER FRA HOME_PAGE: $additiveIdentifier");
    showDialog(
        context: context,
        builder: (BuildContext context) =>
            CustomDialogPage(additiveIdentifier: additiveIdentifier));

    //Navigator.push(context, MaterialPageRoute(builder:(context)=>CustomDialogPage(additiveIdentifier: additiveIdentifier)));
  }

  @override
  void dispose() {
    _controller?.dispose();
    textController.dispose();
    _barcodeDetector.close();
    _faceDetector.close();
    _imageLabeler.close();
    _cloudImageLabeler.close();
    _recognizer.close();
    _cloudRecognizer.close();
    super.dispose();
  }
}
