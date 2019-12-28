import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_vegan/components/gallery_screen.dart';
import 'package:go_vegan/components/string_manipulation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'detector_painters.dart';
import 'package:go_vegan/components/veganAdditives.dart';

class PictureScanner extends StatefulWidget {
  static final String screenId = "PictureScanner";

  @override
  State<StatefulWidget> createState() => _PictureScannerState();
}

class _PictureScannerState extends State<PictureScanner> {
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
                      'Exit Application',
                      style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54),
                    ),
                    onTap: () {
                      SystemNavigator.pop();
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
      appBar: AppBar(
        title: Center(
          child: Text(
            'Additives Checker Demo',
            textAlign: TextAlign.center,
          ),
        ),
        actions: <Widget>[
          PopupMenuButton<Detector>(
            onSelected: (Detector result) {
              _currentDetector = result;
              if (_imageFile != null) _scanImage(_imageFile);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<Detector>>[
              const PopupMenuItem<Detector>(
                child: Text('Detect Barcode'),
                value: Detector.barcode,
              ),
              const PopupMenuItem<Detector>(
                child: Text('Detect Label'),
                value: Detector.label,
              ),
              const PopupMenuItem<Detector>(
                child: Text('Detect Text'),
                value: Detector.text,
              ),
            ],
          ),
        ],
      ),
      body: _imageFile == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Select or take a photo from camera',
                    style: TextStyle(fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                      color: Colors.black54
                    ),),
                  SizedBox(
                    height: 20,
                  ),
                  RaisedButton(
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                    ),
                    color: Colors.lightBlueAccent,
                    // Provide an onPressed callback.
                    onPressed: () {
                      _showChoiceDialog(context);
                    },
                  ),
                ],
              ),
            )
          : _getAdditives(),

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

  //Vegan additives:
  List<String> veganAdditives = Vegan.veganAdditives;
  List<String> additivesFromImage = [];
  Widget _getAdditives() {
    additivesFromImage = addToAdditiveList(textRecResult);
    String data = '';
    int additiveCounter = 0;

    if (additivesFromImage.length > 0) {
      for (int j = 0; j < additivesFromImage.length; j++) {
        for (int i = 0; i < veganAdditives.length; i++) {
          if (additivesFromImage[j].toLowerCase() ==
              veganAdditives[i].toLowerCase()) {
            additiveCounter++;
          } else {
            setState(() {
              data = 'Not Defined';

            });
            break;
          }
        }
      }

      if (additiveCounter == additivesFromImage.length) {
        debugPrint('Fra Bilder: ${additivesFromImage.length}');
        debugPrint('Teller: $additiveCounter');

        setState(() {
          data = 'Vegan';
          additiveCounter = 0;
        });
      } else {
        setState(() {
          data = 'Might not be vegan';
          additiveCounter = 0;
        });
      }
    } else {
      data = 'Could not find any additives';
    }
    Color listTileColor;
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