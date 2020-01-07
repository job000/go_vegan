import 'package:beauty_textfield/beauty_textfield.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return  BeautyTextfield(
      width: double.maxFinite,
      height: 60,
      duration: Duration(milliseconds: 300),
      inputType: TextInputType.text,
      prefixIcon: Icon(Icons.lock_outline),
      suffixIcon: Icon(Icons.remove_red_eye),
      placeholder: "Search Additives",
      onTap: () {
        print('Click');
      },
      onChanged: (text) {
        print(text);
      },
      onSubmitted: (data) {
        print(data.length);
      },
    );
  }
}