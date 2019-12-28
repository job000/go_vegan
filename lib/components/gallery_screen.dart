import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class GalleryImage{

  GalleryImage(){
    openGallery();
  }

  //File imageFile;
  static Future<File> openGallery() async{

    File _imageFile;
    _imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    return _imageFile;
  }


}

