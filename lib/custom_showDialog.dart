import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CustomDialogPage extends StatefulWidget {
  static final String screenId = "CustomDialog";

  final String additiveIdentifier;
  CustomDialogPage({@required this.additiveIdentifier});

  @override
  _CustomDialogPageState createState() =>
      _CustomDialogPageState(this.additiveIdentifier);
}

class _CustomDialogPageState extends State<CustomDialogPage> {
  String identifier;
  _CustomDialogPageState(this.identifier);

  @override
  Widget build(BuildContext context) {
    _setAdditiveTitle(identifier);
    _setAdditiveName(identifier);
    _setAdditiveColour(identifier);
    _setAdditiveDescription(identifier);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  Widget dialogContent(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;

    return Container(
      margin: EdgeInsets.only(left: 0.0, right: 0.0),
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
              top: 18.0,
            ),
            margin: EdgeInsets.only(top: 13.0, right: 8.0),
            decoration: BoxDecoration(
                color: Colors.lightGreen,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 0.0,
                    offset: Offset(0.0, 0.0),
                  ),
                ]),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(
                  height: 20.0,
                ),
                Center(
                    child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 10.0,
                      ),
                    ],
                  ),
                ) //
                    ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(_getAdditiveTitle(),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                fontSize: 25.0,
                                color: Colors.black54)),
                        SizedBox(height: 20.0),
                        Text("Name(s):",
                            style: TextStyle(
                                letterSpacing: 0.3,
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54)),
                        SizedBox(height: 3.0),
                        Text(_getAdditiveName(),
                            style: TextStyle(
                                letterSpacing: 0.3,
                                fontSize: 15.0,
                                color: Colors.black54)),
                        SizedBox(height: 5.0),
                        Text("Color:",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                                fontSize: 16.0,
                                color: Colors.black54)),
                        SizedBox(height: 3.0),
                        Text(_getAdditiveColour(),
                            style: TextStyle(
                                letterSpacing: 0.3,
                                fontSize: 15.0,
                                color: Colors.black54)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24.0),
                InkWell(
                  child: Container(
                    padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(16.0),
                          bottomRight: Radius.circular(16.0)),
                    ),
                    child: Text(
                      "BACK",
                      style: TextStyle(color: Colors.lightGreenAccent, fontSize: 25.0,fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      Navigator.pop(context);
                    });
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, Map<String, String>> additivesDescription = {
    'E150d': {
      'Name': 'Test',
      'Colour': 'Yellow',
      'Description': 'Dette er en test'
    },
    'E300': {
      'Name': 'Ascorbic acid (Vitamin C)',
      'Colour': 'antioxidant',
      'Description': 'Vel'
    },
    'E472': {
      'Name': 'Acetic acid esters of mono- and diglycerides of fatty acids',
      'Colour': 'emulsifier',
      'Description': 'Hmm'
    },
    'E471': {
      'Name':
          'Mono- and diglycerides of fatty acids (glyceryl monostearate, glyceryl distearate)',
      'Colour': 'emulsifier',
      'Description': 'None'
    },
  };

  String _title, _name, _colour, _description;
  //Setters

  void _setAdditiveTitle(String additiveIdentifier) {
    for (String key in additivesDescription.keys) {
      if (key == additiveIdentifier) {
        setState(() {
          _title = key.toString();
        });
        break;
      }
    }
  }

  void _setAdditiveName(String additiveIdentifier) {
    for (String key in additivesDescription.keys) {
      if (key == additiveIdentifier) {
        setState(() {
          _name = additivesDescription[key]['Name'].toString();
        });
        break;
      }
    }
  }

  void _setAdditiveColour(String additiveIdentifier) {
    for (String key in additivesDescription.keys) {
      if (key == additiveIdentifier) {
        setState(() {
          _colour = additivesDescription[key]['Colour'].toString();
        });
        break;
      }
    }
  }

  void _setAdditiveDescription(String additiveIdentifier) {
    for (String key in additivesDescription.keys) {
      if (key == additiveIdentifier) {
        setState(() {
          _description = additivesDescription[key]['Description'].toString();
        });
        break;
      }
    }
  }

  //Getters
  String _getAdditiveTitle() {
    return _title;
  }

  String _getAdditiveName() {
    return _name;
  }

  String _getAdditiveColour() {
    return _colour;
  }

  String _getAdditiveDescription() {
    return _description;
  }
}
