import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_vegan/models/additives_data.dart';

//TODO: Legg til database her.

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

    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.only(left: 0.0, right: 0.0),
        child: Stack(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(
                top: 2.0,
              ),
              margin: EdgeInsets.only(top: 13.0, right: 8.0),
              decoration: BoxDecoration(
                  color: Colors.white,
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
                    padding: const EdgeInsets.all(2.0),
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
                    child: _getAdditiveName() == null
                        ? noData()
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Center(
                                  child: Text(
                                      _getAdditiveTitle() == null
                                          ? ''
                                          : _getAdditiveTitle(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                          fontSize: 25.0,
                                          color: Colors.black54)),
                                ),
                                SizedBox(height: 20.0),
                                Text("Name(s):",
                                    style: TextStyle(
                                        letterSpacing: 0.3,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black54)),
                                SizedBox(height: 3.0),
                                Text(
                                    _getAdditiveName() == null
                                        ? ''
                                        : _getAdditiveName(),
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
                                Text(
                                    _getAdditiveColour() == null
                                        ? ''
                                        : _getAdditiveColour(),
                                    style: TextStyle(
                                        letterSpacing: 0.3,
                                        fontSize: 15.0,
                                        color: Colors.black54)),
                                SizedBox(height: 5.0),
                                Text("Description:",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.3,
                                        fontSize: 16.0,
                                        color: Colors.black54)),
                                SizedBox(height: 3.0),
                                Text(
                                    _getAdditiveDescription() == null
                                        ? ''
                                        : _getAdditiveDescription(),
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
                        color: Color.fromRGBO(60, 80, 90, .7),
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(16.0),
                            bottomRight: Radius.circular(16.0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Hide",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                            ),
                          )
                        ],
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
      ),
    );
  }

  Widget noData() {
    return Center(
      child: Column(
        children: <Widget>[
          Text(
            "NO DATA",
            style: TextStyle(
                fontSize: 30.0,
                letterSpacing: 1.0,
                color: Color.fromRGBO(60, 80, 90, .7)),
          ),
          SizedBox(
            height: 10.0,
          ),
          Text(
            "We apologise for any",
            style: TextStyle(
                fontSize: 14.0,
                letterSpacing: 1.0,
                color: Color.fromRGBO(60, 80, 90, .7)),
          ),
          Text(
            "inconvenience it may caused.",
            style: TextStyle(
                fontSize: 14.0,
                letterSpacing: 1.0,
                color: Color.fromRGBO(60, 80, 90, .7)),
          ),
        ],
      ),
    );
  }

  String _title, _name, _colour, _description;
  //Setters

  void _setAdditiveTitle(String additiveIdentifier) async {
    Map result;
    List the = await query('my_table', additiveIdentifier);
    result = the.asMap();

    for (int key in result.keys) {
      if (result[key]['_name'].toString() == additiveIdentifier) {
        setState(() {
          _title = result[key]['_name'].toString();
        });
        break;
      }
    }
  }

  void _setAdditiveName(String additiveIdentifier) async {
    Map result;
    List the = await query('my_table', additiveIdentifier);
    result = the.asMap();

    for (int key in result.keys) {
      if (result[key]['_name'].toString() == additiveIdentifier) {
        setState(() {
          _name = result[key]['_name'].toString();
        });
        break;
      }
    }
  }

  void _setAdditiveColour(String additiveIdentifier) async {
    Map result;
    List the = await query('my_table', additiveIdentifier);
    result = the.asMap();
    for (int key in result.keys) {
      if (result[key]['_name'].toString() == additiveIdentifier) {
        setState(() {
          _colour = result[key]['_color'].toString();
        });
        break;
      }
    }
  }

  void _setAdditiveDescription(String additiveIdentifier) async {
    Map result;
    List the = await query('my_table', additiveIdentifier);
    result = the.asMap();
    debugPrint('HELLLLOOOOOOOOA: ${result.toString()}');
    for (int key in result.keys) {
      if (result[key]['_name'].toString() == additiveIdentifier) {
        setState(() {
          _description = result[key]['_description'].toString();
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
