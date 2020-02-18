import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/foods.dart';
import '../widgets/image_input.dart';

class NewFoodScreen extends StatefulWidget {
  static const routeName = '/New-food-screen';

  @override
  _NewFoodScreenState createState() => _NewFoodScreenState();
}

class _NewFoodScreenState extends State<NewFoodScreen> {

  // variables important for getting user input

  final _id = DateTime.now().toIso8601String();
  File _image;
  final _nController = TextEditingController(); // food name
  final _cController = TextEditingController(); // carbohydrates
  final _desCont = TextEditingController(); // description
  var category; // food category
  bool _validate = false; 

  void _selectImage(File pickedImage) {
    _image = pickedImage;
  }


  // method to validate a Food Entry
  // if it is validated, it gets saved
  
  void _saveFood() {
    if (_nController.text.isEmpty) {
      _validate = false;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.blueGrey[900],
            title: Text(
              'Missing Name.',
              style: TextStyle(color: Colors.white70),
            ),
            content: Text(
              'Please enter a Name.',
              style: TextStyle(color: Colors.white70),
            ),
            actions: <Widget>[
              new FlatButton(
                color: Colors.blueGrey[700],
                child: Text('ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ], /*shape: ,*/
          );
        },
      );
    } else if (_cController.text.isEmpty ||
        int.tryParse(_cController.text) < 0 ||
        int.tryParse(_cController.text) > 100) {
      _validate = false;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.blueGrey[900],
            title: Text(
              'Invalid Carbohydrates.',
              style: TextStyle(color: Colors.white70),
            ),
            content: Text(
              'Please enter a valid amount of carbohydrates (from 0-100).',
              style: TextStyle(color: Colors.white70),
            ),
            actions: <Widget>[
              new FlatButton(
                color: Colors.blueGrey[700],
                child: Text('ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ], /*shape: ,*/
          );
        },
      );
    } else {
      _validate = true;
    }
    if (_validate) {
      Provider.of<Foods>(context, listen: false).addFood(
        _id,
        _image == null ? null : _image,
        '${_nController.text[0].toUpperCase()}${_nController.text.substring(1)}',
        int.parse(_cController.text),
        category,
        _desCont.text,
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return new Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Theme.of(context).accentColor,
          title: Text(
            'New Food Entry',
            style: GoogleFonts.openSans(
              textStyle: TextStyle(color: Colors.white),
              fontSize: 20,
            ),
          ),
          elevation: 0,
        ),
        body: ListView(shrinkWrap: true, children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ImageInput(_selectImage),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    maxLength: 30,
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(color: Colors.white70),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(color: Colors.blueGrey[900]),
                      ),
                      labelText: "Name",
                      labelStyle: TextStyle(
                        color: Colors.white70,
                      ),
                      hintText: 'Enter the foods name.',
                      hintStyle: TextStyle(color: Colors.white38),
                    ),
                    keyboardType: TextInputType.text,
                    controller: _nController,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    decoration: new InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(color: Colors.white70),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(color: Colors.blueGrey[900]),
                      ),
                      labelText: "Carbohydrates",
                      labelStyle: TextStyle(
                        color: Colors.white70,
                      ),
                      hintText:
                          'Enter the carbohydrates that 100 gram of the chosen food contain.',
                      hintStyle: TextStyle(color: Colors.white38),
                    ),
                    keyboardType: TextInputType.number,
                    controller: _cController,
                    autofocus: false,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    child: DropdownButton<String>(
                      value: category,
                      iconSize: 20,
                      elevation: 8,
                      style: TextStyle(color: Colors.white),
                      onChanged: (String newValue) {
                        setState(() {
                          category = newValue;
                        });
                      },
                      isExpanded: true,
                      items: <String>[
                        'Drinks',
                        'Fruits',
                        'Vegetables',
                        'Legumes & Nuts'
                            'Grain(products) & Rice',
                        'Bread & Biscuits',
                        'Sweets',
                        'Fish & Meat',
                        'Milk(products) & Eggs',
                      ].map<DropdownMenuItem<String>>(
                        (String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        },
                      ).toList(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    maxLength: 300,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    decoration: new InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(color: Colors.white70),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(color: Colors.blueGrey[900]),
                      ),
                      labelText: "Description",
                      labelStyle: TextStyle(
                        color: Colors.white70,
                      ),
                      hintText: 'Enter a description of the chosen food.',
                      hintStyle: TextStyle(color: Colors.white38),
                    ),
                    controller: _desCont,
                    autofocus: false,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                          flex: 3,
                          child: Container(
                            width: 200,
                            height: 200,
                          )),
                      Expanded(
                        flex: 2,
                        child: RaisedButton.icon(
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(10.0)),
                          color: Theme.of(context).backgroundColor,
                          label: Text('Save',
                              style: TextStyle(
                                color: Colors.white,
                              )),
                          icon: Icon(
                            FontAwesomeIcons.solidSave,
                            color: Colors.white,
                          ),
                          onPressed: _saveFood,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
