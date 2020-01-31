import 'package:flutter/cupertino.dart';

String _afterLetterE = "";
int startsWithLetterE = 0;

RegExp re = new RegExp(r'(\w+)');

//Gets the value after E.
String setValueAfterE(String s, int numbOfStringAfterE) {
  startsWithLetterE = s.indexOf('E');
  String newString = s.substring(startsWithLetterE + 1);
  //debugPrint('the newString: $newString');
  try {
    _afterLetterE = newString.substring(0, numbOfStringAfterE); //
  } catch (e) {
    //print("Feil men håndterbart: $e");
  }
  return _afterLetterE;
}

String getValueAfterE() {
  return _afterLetterE;
}

bool _isNumeric(String str) {
  str = str.trim();
  if (str == null) {
    return false;
  }
  return int.tryParse(str) != null;
}

//Check for letter E
//Get value after E
//Check if the 3 next value after E is numeric
//If checking for the 3 next value after E Save the next 4 value
//Check if the 4 next value after E is numeric
//Save the value if numeric
String temp1 = "";
String temp2 = "";
String temp3 = "";
String fAdditive1 = "";
String fAdditive2 = "";
String fAdditive3 = "";
List<String> additivesFromImage = [];

List<String> addToAdditiveList(String textRecResult) {
  for (int i = 0; i < textRecResult.length; i++) {
    try {
      if (textRecResult.contains('e') || textRecResult.contains('E')) {
        if (_isNumeric(setValueAfterE(textRecResult, 4))) {
          fAdditive2 = setValueAfterE(textRecResult, 4);
          fAdditive1 = setValueAfterE(textRecResult, 5);
          fAdditive3 = fAdditive1.substring(4, 5);
          RegExp alphanumeric = RegExp(r'^[a-zA-Z0-9]+$');
          RegExp re = new RegExp(r'^\D+$');

          if (alphanumeric.hasMatch(fAdditive3)) {
            if (re.hasMatch(fAdditive3)) {
              //print('HER ER VI ${fAdditive3.replaceAll('[^A-Za-z0-9]', '').trim()}');
              additivesFromImage
                  .add('E${fAdditive1.replaceAll('[^A-Za-z0-9]', '').trim()}');
            }
          } else {
            additivesFromImage
                .add('E${fAdditive2.replaceAll('[^A-Za-z0-9]', '').trim()}');
          }
          //additivesFromImage.add('E' + getValueAfterE());
          textRecResult = textRecResult.replaceAll('E' + getValueAfterE(), '');
        } else if (_isNumeric(setValueAfterE(textRecResult, 3))) {
          temp2 = setValueAfterE(textRecResult, 3);
          temp1 = setValueAfterE(textRecResult, 4);
          temp3 = temp1.substring(3, 4);
          RegExp alphanumeric = RegExp(r'^[a-zA-Z0-9]+$');
          RegExp re = new RegExp(r'^\D+$');

          if (alphanumeric.hasMatch(temp3)) {
            if (re.hasMatch(temp3)) {
              //print('HER ER VI ${temp3.replaceAll('[^A-Za-z0-9]','').trim()}');

              additivesFromImage
                  .add('E${temp1.replaceAll('[^A-Za-z0-9]', '').trim()}');
              //debugPrint('temp1: E${temp1.replaceAll('[^A-Za-z0-9]', '').trim()}');
              //debugPrint('temp3: $temp3');
            }
          } else {
            additivesFromImage
                .add('E${temp2.replaceAll('[^A-Za-z0-9]', '').trim()}');
            //debugPrint('temp2: E${temp2.replaceAll('[^A-Za-z0-9]', '').trim()}');

          }
          //additivesFromImage.add('E' + getValueAfterE());
          textRecResult = textRecResult.replaceAll('E' + getValueAfterE(), '');
        } else {
          textRecResult = textRecResult.replaceAll('E' + getValueAfterE(), '');
        }
      } else {
        textRecResult = '';
        break;
      }
    } catch (e) {
      print(e);
      additivesFromImage.add("");
    }
  }
  return additivesFromImage;
}
