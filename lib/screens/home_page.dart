import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:animated_background/animated_background.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_vegan/components/custom_textfield.dart';
import 'package:go_vegan/components/drawer_page.dart';
import 'package:go_vegan/components/gallery_screen.dart';
import 'package:go_vegan/components/logo.dart';
import 'package:go_vegan/components/string_manipulation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'detector_painters.dart';
import 'package:go_vegan/components/veganAdditives.dart';
import 'package:go_vegan/custom_showDialog.dart';


class PictureScanner extends StatefulWidget {
  static final String screenId = "PictureScanner";

  @override
  State<StatefulWidget> createState() => _PictureScannerState();
}

class _PictureScannerState extends State<PictureScanner> with TickerProviderStateMixin {

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
            title: Text(
              'Get Image from:',
              style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
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
                  GestureDetector(
                    child: Text(
                      'Reset',
                      style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54),
                    ),
                    onTap: () {
                      //SystemNavigator.pop();
                      setState(() {
                        Navigator.pop(context);
                        _imageFile = null;
                      });
                    },
                  )
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.white,
      drawer: DrawerPage(),

      body: SafeArea(
        child: _imageFile == null
            ? Center(
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: TextField(
                    decoration: InputDecoration(
                        border: OutlineInputBorder()
                    )
                ),
              ),
              Expanded(
                flex: 10,
                child: Container(
                  color: listTileColor,
                  child: ListView.builder(
                    itemCount: veganAdditives.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          leading: Icon(Icons.info),
                          title: Text(
                            veganAdditives[index],
                            style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.black54,
                                fontWeight: FontWeight.bold),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios),

                          onTap: (){
                            setState(() {
                              //navigateToDetail(additivesFromImage[index]);
                            });
                          },
                        ),
                      );

                    },
                  ),
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

  //List of additives:
  List<String> veganAdditives = Vegan.veganAdditives;
  List<String> possiblyVeganAdditives = Vegan.possiblyNonVegan;
  List<String> nonVeganAdditives = Vegan.nonVegan;

  List<String> additivesFromImage = [];

  Widget _getAdditives() {
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
          if (additivesFromImage[j].toLowerCase().trim()== veganAdditives[i].toLowerCase().trim())
          {
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
          if (additivesFromImage[j].toLowerCase().trim() == possiblyVeganAdditives[i].toLowerCase().trim())
          {
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
          if (additivesFromImage[j].toLowerCase().trim() == nonVeganAdditives[i].toLowerCase().trim())
          {
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

      if (veganAdditiveCounter == additivesFromImage.length && _possiblyVeganAdditiveCounter<=0 && _nonVeganAdditivesCounter<=0) {

        setState(() {
          data = 'Vegan';
          veganAdditiveCounter = 0;
        });
      } else if(_possiblyVeganAdditiveCounter>0 && _nonVeganAdditivesCounter<=0) {
        setState(() {
          data = 'Might not be vegan';
          _possiblyVeganAdditiveCounter = 0;
        });
      }else if(_nonVeganAdditivesCounter>0){
       setState(() {
         data = 'Not Vegan';
         _nonVeganAdditivesCounter=0;
       });

      }
    } else {
      data = 'Could not find any additives';
    }

    //return Text(data);
    return Center(
      child: Column(
        children: <Widget>[
          Expanded(
              flex: 1,
              child: Container(
                child: Center(
                    child: Text(data,
                        style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold))),
              )),
          Expanded(
            flex: 2,
            child: Container(
              color: listTileColor,
              child: ListView.builder(
                itemCount: additivesFromImage.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      leading: Icon(Icons.info),
                      title: Text(
                        additivesFromImage[index],
                        style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.black54,
                            fontWeight: FontWeight.bold),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios),

                      onTap: (){
                        setState(() {
                          navigateToDetail(additivesFromImage[index]);
                        });
                      },
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

  void navigateToDetail(String additiveIdentifier) async {
    //NoteDetail(note, title);
    debugPrint("HER FRA HOME_PAGE: $additiveIdentifier");
      showDialog(context: context, builder: (BuildContext context)=>CustomDialogPage(additiveIdentifier: additiveIdentifier));

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
