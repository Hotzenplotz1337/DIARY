import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/app_drawer.dart';
import 'home_screen.dart';
import '../models/settings.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = '/settings-screen';

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Settings settings;

  final _baCont = TextEditingController();
  final _boCont = TextEditingController();
  final _relCont = TextEditingController();

  Future getSettings() async {
    var pref = await SharedPreferences.getInstance();
    if (pref.containsKey('rangeStart')) {
      print('Settings loaded');
      setState(() {
        settings = Settings(
          range: RangeValues(
              pref.getDouble('rangeStart'), pref.getDouble('rangeEnd')),
          basal: pref.getString('basal'),
          bolus: pref.getString('bolus'),
          morning: pref.getDouble('morning'),
          noon: pref.getDouble('noon'),
          evening: pref.getDouble('evening'),
          relation: pref.getInt('relation'),
        );
        _baCont.text = pref.getString('basal');
        _boCont.text = pref.getString('bolus');
        _relCont.text = pref.getInt('relation').toString();
      });
    }
  }

  void saveSettings(Settings newSettings) async {
    newSettings.basal = _baCont.text;
    newSettings.bolus = _boCont.text;
    newSettings.relation = int.tryParse(_relCont.text);
    final pref = await SharedPreferences.getInstance();
    pref.setDouble('rangeStart', newSettings.range.start);
    pref.setDouble('rangeEnd', newSettings.range.end);
    pref.setString('basal', newSettings.basal);
    pref.setString('bolus', newSettings.bolus);
    pref.setDouble('morning', newSettings.morning);
    pref.setDouble('noon', newSettings.noon);
    pref.setDouble('evening', newSettings.evening);
    pref.setInt('relation', newSettings.relation);
  }

  @override
  void initState() {
    print('test');
    super.initState();
    getSettings();
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
            'Settings',
            style: GoogleFonts.openSans(
              textStyle: TextStyle(color: Colors.white),
              fontSize: 20,
            ),
          ),
          elevation: 0,
        ),
        body: ListView(shrinkWrap: true, children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Blood Sugar Range (Low to High)',
                        style: TextStyle(color: Colors.white70, fontSize: 20),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Center(
                              child: Text(
                                '${settings.range.start}',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: RangeSlider(
                              values: settings.range,
                              onChanged: (RangeValues newRange) {
                                setState(() {
                                  settings.range = newRange;
                                });
                              },
                              min: 50,
                              max: 240,
                              divisions: 19,
                              activeColor: Colors.white,
                              // labels: RangeLabels('${range.start}', '${range.end}'),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Center(
                              child: Text(
                                '${settings.range.end}',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
                      labelText: "Bolusinsulin",
                      labelStyle: TextStyle(
                        color: Colors.white70,
                      ),
                      hintText: 'Insert the Name of your Bolusinsulin',
                      hintStyle: TextStyle(color: Colors.white38),
                    ),
                    keyboardType: TextInputType.text,
                    controller: _boCont,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    maxLength: 30,
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
                      labelText: "Basalinsulin",
                      labelStyle: TextStyle(
                        color: Colors.white70,
                      ),
                      hintText: 'Insert the Name of your Basalinsulin',
                      hintStyle: TextStyle(color: Colors.white38),
                    ),
                    keyboardType: TextInputType.text,
                    controller: _baCont,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Factors",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white70,
                    ),
                    // controller: _cController,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        'Morning',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white70,
                        ),
                      ),
                      Slider(
                        value: settings.morning,
                        max: 10,
                        min: 1,
                        divisions: 18,
                        onChanged: (value) {
                          setState(() {
                            settings.morning = value;
                          });
                        },
                        activeColor: Colors.white,
                      ),
                      Text(
                        '${settings.morning}',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        'Noon',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white70,
                        ),
                      ),
                      Slider(
                        value: settings.noon,
                        max: 10,
                        min: 1,
                        divisions: 18,
                        onChanged: (value) {
                          setState(() {
                            settings.noon = value;
                          });
                        },
                        activeColor: Colors.white,
                      ),
                      Text(
                        '${settings.noon}',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        'Evening',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white70,
                        ),
                      ),
                      Slider(
                        value: settings.evening,
                        max: 10,
                        min: 1,
                        divisions: 18,
                        onChanged: (value) {
                          setState(() {
                            settings.evening = value;
                          });
                        },
                        activeColor: Colors.white,
                      ),
                      Text(
                        '${settings.evening}',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    maxLength: 3,
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
                      labelText: 'Relation(mg/dl)',
                      labelStyle: TextStyle(
                        color: Colors.white70,
                      ),
                      hintText: 'Insert the Name of your Basalinsulin',
                      hintStyle: TextStyle(color: Colors.white38),
                    ),
                    keyboardType: TextInputType.number,
                    controller: _relCont,
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
                          onPressed: () {
                            saveSettings(settings);
                            print(settings.range);
                            if (settings.relation < 0 ||
                                settings.relation > 100) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: Colors.blueGrey[900],
                                    title: Text(
                                      'Invalid Relation.',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    content: Text(
                                      'Enter a valid Relation (from 0 to 100).',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    actions: <Widget>[
                                      new FlatButton(
                                        color: Colors.blueGrey[700],
                                        child: Text(
                                          'ok',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else
                              showDialog(
                                context: context,
                                builder: (BuildContext conext) {
                                  return AlertDialog(
                                    backgroundColor: Colors.blueGrey[900],
                                    title: Text(
                                      'New Settings Saved',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    content: Text(
                                      'You get back to Home Screen',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    actions: <Widget>[
                                      FlatButton(
                                        color: Colors.blueGrey[700],
                                        child: Text(
                                          'Ok',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        onPressed: () {
                                          int.tryParse(_relCont.text);
                                          Navigator.of(context)
                                              .pushReplacementNamed(
                                                  HomeScreen.routeName);
                                          // print('${}');
                                        },
                                      ),
                                    ], /*shape: ,*/
                                  );
                                },
                              );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ]),
        drawer: AppDrawer(),
      ),
    );
  }
}
