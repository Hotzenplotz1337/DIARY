import 'dart:io';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as syspaths;

// class for picking or taking a picture for a food entry

class ImageInput extends StatefulWidget {
  final Function onSelectImage;

  ImageInput(this.onSelectImage);

  @override
  _ImageInputState createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  dynamic pickImageError;
  File _storedImage;

  // method that gets triggered, if you tap the "Take Picture" button
  // the user can take a image with device camera app

  Future<void> _takePicture() async {
    try {
      final imageFile = await ImagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1600,
        maxHeight: 1200,
      );
      if (imageFile == null) {
        return;
      }
      setState(() {
        _storedImage = imageFile;
      });
      final appDir = await syspaths.getApplicationDocumentsDirectory();
      final fileName = path.basename(imageFile.path);
      final savedImage = await imageFile.copy('${appDir.path}/$fileName');
      widget.onSelectImage(savedImage);
    } catch (e) {
      pickImageError = e;
    }
  }

  // method that gets triggered, if you tap the "Open Gallery" button
  // the user can select a image file from device storage

  Future<void> _setPicture() async {
    try {
      final imageFile = await ImagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1200,
      );
      if (imageFile == null) {
        return;
      }
      setState(() {
        _storedImage = imageFile;
      });
      final appDir = await syspaths.getApplicationDocumentsDirectory();
      final fileName = path.basename(imageFile.path);
      final savedImage = await imageFile.copy('${appDir.path}/$fileName');
      widget.onSelectImage(savedImage);
    } catch (e) {
      pickImageError = e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            width: 180,
            height: 240,
            child: Center(
                child: _storedImage != null
                    ? Image.file(
                        _storedImage,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : Image(image: AssetImage('assets/images/np.png'))),
            decoration: BoxDecoration(
              color: Colors.blueGrey[900],
            ),
          ),
          Column(
            children: <Widget>[
              RaisedButton.icon(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                color: Theme.of(context).backgroundColor,
                icon: Icon(
                  FontAwesomeIcons.cameraRetro,
                ),
                label: Text(
                  'Take Picture',
                  textAlign: TextAlign.center,
                ),
                textColor: Colors.white,
                onPressed: _takePicture,
              ),
              RaisedButton.icon(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                color: Theme.of(context).backgroundColor,
                icon: Icon(
                  FontAwesomeIcons.images,
                ),
                label: Text(
                  'Open Gallery',
                  textAlign: TextAlign.center,
                ),
                textColor: Colors.white,
                onPressed: _setPicture,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
