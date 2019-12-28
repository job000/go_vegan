import 'package:flutter/cupertino.dart';

String _afterLetterE;
int startsWithLetterE;

String valueAfterE(String s, int numbOfStringAfterE) {
  startsWithLetterE = s.indexOf('E');
  String the = s.substring(startsWithLetterE + 1);
  debugPrint('the her: $the');
  try {
    _afterLetterE = the.substring(0, numbOfStringAfterE); //
  }catch(e){
    _afterLetterE = the.substring(0,numbOfStringAfterE-1);
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


List<String> addToAdditiveList(String textRecResult){

  List<String> additivesFromImage=[];
  textRecResult = textRecResult.replaceAll('/[\W_]+/g', ''); //Replace all non-character
  for(int i = 0; i < textRecResult.length; i++) {

    //print('Three her vettu: $three');
    //String four = valueAfterE(textRecResult, 4);
    if (textRecResult.contains('e') || textRecResult.contains('E')) {
      if (_isNumeric(valueAfterE(textRecResult, 3))) {
        additivesFromImage.add('E' + getValueAfterE());
        textRecResult = textRecResult.replaceAll('E' + getValueAfterE(), '');
      }else{
        textRecResult = textRecResult.replaceAll('E' + getValueAfterE(), '');
      }
    }else{
      textRecResult = '';
      break;
    }
  }
  return additivesFromImage;
}

