import 'package:flutter/material.dart';
import 'package:go_vegan/screens/copied_test_from_git.dart';

Widget customErrorDialog(BuildContext context) {
  
  return Hero(
    tag: 'identifier',
    child: AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      content: Container(
        width: 260.0,
        height: 230.0,
        decoration: new BoxDecoration(
          shape: BoxShape.rectangle,
          color: const Color(0xFFFFFF),
          borderRadius: new BorderRadius.all(new Radius.circular(32.0)),
        ),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
// dialog top
            new Expanded(
              child: new Row(
                children: <Widget>[
                  new Container(
// padding: new EdgeInsets.all(10.0),
                    decoration: new BoxDecoration(
                      color: Colors.white,
                    ),
                    child: new Text(
                      'Error occured',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18.0,
                        fontFamily: 'helvetica_neue_light',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

// dialog centre
            new Expanded(
              child: new Container(
                  child: new TextField(
                decoration: new InputDecoration(
                  border: InputBorder.none,
                  filled: false,
                  contentPadding: new EdgeInsets.only(
                      left: 10.0, top: 10.0, bottom: 10.0, right: 10.0),
                  hintText: 'Cannot find any additives.',
                  hintStyle: new TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 16.0,
                    fontFamily: 'helvetica_neue_light',
                  ),
                ),
              )),
              flex: 2,
            ),

// dialog bottom
            new Expanded(
              child: new Container(
                padding: new EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(60, 80, 90, .7),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                      topRight: Radius.circular(16.0),
                      bottomLeft: Radius.circular(16.0),
                      bottomRight: Radius.circular(16.0)),
                ),
                child: FlatButton(
                  onPressed: (){
                    Navigator.pop(context);
                    Navigator.of(context).pushNamed(PictureScanner.screenId);

                  },
                  child: new Text(
                    'OK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontFamily: 'helvetica_neue_light',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
