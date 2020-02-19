import 'dart:async';
import 'dart:convert' show utf8;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/entrys.dart';
import '../models/settings.dart';

final _cvController = TextEditingController();
final _uiController = TextEditingController();
final _nController = TextEditingController();

bool bluetooth = false;

bool search = false;

getList() {
  FlutterBlue.instance.startScan(timeout: Duration(seconds: 4));
  search = true;
}

stopScan() {
  FlutterBlue.instance.stopScan();
  search = false;
}

class NewEntryScreen extends StatefulWidget {
  NewEntryScreen({
    Key key,
  }) : super(key: key); //this.state
  static const routeName = '/add-entry-screen';
  @override
  _NewEntryScreenState createState() => _NewEntryScreenState();
}

class _NewEntryScreenState extends State<NewEntryScreen> {
  bool isReady = false;
  bool reqVal = false;

  // important for validating the Blood-Sugar_Level

  var _validate = true;
  var _consume = false;

  // variables important for getting user input

  final _id = DateTime.now().toString();
  static DateTime dt = DateTime.now();
  var _day = '${DateFormat('dd').format(dt)}';
  var _month = '${DateFormat('MM').format(dt)}';
  var _year = '${DateFormat('yyyy').format(dt)}';

  static TimeOfDay _time = TimeOfDay.fromDateTime(DateTime.parse('$dt'));
  var _hour = '${_time.hour}'.length == 2 ? '${_time.hour}' : '0${_time.hour}';
  var _minutes =
      '${_time.minute}'.length == 2 ? '${_time.minute}' : '0${_time.minute}';

  String _insulinSort;
  bool _isInjected = true;
  bool _meal = false;
  bool _sport = false;
  bool _bed = false;
  int _radioValue = -1;

  Settings settings;

  @override
  void initState() {
    super.initState();
    getSettings();
  }

// method to get current user settings from Shared Preferences

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
      });
    }
  }

  // method for handling the change of the radio buttons

  void _handleRadioValueChange(int value) {
    setState(() {
      _radioValue = value;

      switch (_radioValue) {
        case 0:
          if (_meal) {
            _meal = false;
          } else {
            _meal = true;
            _sport = false;
            _bed = false;
          }

          break;
        case 1:
          if (_sport) {
            _sport = false;
          } else {
            _sport = true;
            _bed = false;
            _meal = false;
          }
          break;
        case 2:
          if (_bed) {
            _bed = false;
          } else {
            _bed = true;
            _meal = false;
            _sport = false;
          }
          break;
      }
    });
  }

  // method to calculate insulin units to correct a too high Blood-Sugar-Level
  // ((Current Blood-Sugar-Level - Target Level) / Relation ) * Correcting Factor = Calculated Units
  // the correcting factor depends on the TimeOfDay
  // morning  =>   (TimeofDay >= 6am && TimeofDay < 11am)
  // noon     =>   (TimeofDay >= 11am && TimeofDay < 5pm)
  // evening  =>   (TimeofDay >= 5pm && TimeofDay < 6am)

  bool _calculateInsulinUnits(int value, TimeOfDay time, Settings settings) {
    if (value > 50 && value < settings.range.start) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.blueGrey[900],
            title: Text(
              'Your inserted level is low.',
              style: TextStyle(
                color: Colors.white70,
              ),
            ),
            content: Text(
              'Please consume some sugary food.',
              style: TextStyle(
                color: Colors.white70,
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                color: Colors.blueGrey[700],
                child: Text(
                  'Ok',
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ], /*shape: ,*/
          );
        },
      );
      _consume = true;
      return false;
    } else if (value <= 50) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.blueGrey[900],
            title: Text(
              'Your inserted level is extremely low.',
              style: TextStyle(
                color: Colors.white70,
              ),
            ),
            content: Text(
              'Please consume some sugary food, notify someone about your situation and stay calm until your level gets normal.',
              style: TextStyle(
                color: Colors.white70,
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                color: Colors.blueGrey[700],
                child: Text(
                  'Ok',
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ], /*shape: ,*/
          );
        },
      );
      _consume = true;
      return false;
    } else if (value > settings.range.end) {
      double factor = time.hour < 6
          ? settings.evening
          : (time.hour < 11 ? settings.morning : settings.noon);
      int _unitsCalculated =
          ((((value - 100) ~/ settings.relation) * factor).toInt());
      _uiController.text = _unitsCalculated.toString();
      setState(() {
        _insulinSort = settings.bolus;
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.blueGrey[900],
            title: Text(
              'Your inserted level is too high.',
              style: TextStyle(
                color: Colors.white70,
              ),
            ),
            content: Text(
              'Please consume $_unitsCalculated units of $_insulinSort',
              style: TextStyle(
                color: Colors.white70,
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                color: Colors.blueGrey[700],
                child: Text(
                  'Ok',
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ], /*shape: ,*/
          );
        },
      );
      return false;
    } else
      return true;
  }

  // method to validate a Diary Entry
  // if it is validated, it gets saved

  void _saveEntry(int value, TimeOfDay time, Settings settings) {
    // Check if the Blood-Sugar-Level is between 40 and 500
    // and if a Blood-Sugar-Level was entered or not

    if (_cvController.text.isEmpty) {
      _validate = false;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.blueGrey[900],
            title: Text(
              'Invalid Blood Sugar Level.',
              style: TextStyle(color: Colors.white70),
            ),
            content: Text(
              'Please enter a valid Blood Sugar Level.',
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
    } else if (int.tryParse(_cvController.text) >= 40 &&
        int.tryParse(_cvController.text) <= 500) {
      if ((_uiController.text.isEmpty || _uiController.text == '0') &&
          int.tryParse(_cvController.text) > settings.range.end &&
          !_consume) {
        _validate = _calculateInsulinUnits(value, time, settings);
      } else if (int.tryParse(_cvController.text) >= 40 &&
          int.tryParse(_cvController.text) < settings.range.start &&
          !_consume) {
        _validate = _calculateInsulinUnits(value, time, settings);
      } else
        _validate = true;
    } else {
      _validate = false;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.blueGrey[900],
            title: Text(
              'Invalid Blood Sugar Level.',
              style: TextStyle(color: Colors.white70),
            ),
            content: Text(
              'Please enter a valid blood sugar level.',
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
    }
    if (_uiController.text.isEmpty || _uiController.text == '0') {
      _isInjected = false;
    }
    if (_validate) {
      if (int.tryParse(_cvController.text) >= settings.range.start &&
          int.tryParse(_cvController.text) <= settings.range.end) {
        _uiController.text = '';
      }
      Provider.of<Entrys>(context, listen: false).addEntry(
        _id,
        _day,
        _month,
        _year,
        _hour,
        _minutes,
        _cvController.text,
        _uiController.text,
        _insulinSort,
        _nController.text,
        _isInjected,
        _meal,
        _sport,
        _bed,
      );
      _cvController.text = '';
      _uiController.text = '';
      _nController.text = '';
      Navigator.of(context).pop();
    }
    setState(() {
      dt = DateTime.now();
      _time = TimeOfDay.fromDateTime(DateTime.parse('$dt'));
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        stopScan();
        return new Future.value(true);
      },
      child: StreamBuilder<BluetoothState>(
        stream: FlutterBlue.instance.state,
        initialData: BluetoothState.unknown,
        builder: (context, snapshot) {
          final state = snapshot.data;
          if (state == BluetoothState.on) {
            bluetooth = true;
          }
          return Scaffold(
            appBar: AppBar(
              iconTheme: IconThemeData(color: Colors.white),
              backgroundColor: Theme.of(context).accentColor,
              title: Text(
                'New Entry',
                style: GoogleFonts.openSans(
                  textStyle: TextStyle(color: Colors.white),
                  fontSize: 20,
                ),
              ),
              elevation: 0,
            ),
            body: ListView(
              shrinkWrap: true,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          maxLength: 3,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              borderSide: BorderSide(color: Colors.white70),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              borderSide:
                                  BorderSide(color: Colors.blueGrey[900]),
                            ),
                            labelText: 'Blood Sugar Level',
                            labelStyle: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          controller: _cvController,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: snapshot.data == BluetoothState.on
                            ? ExpansionTile(
                                backgroundColor: Colors.blueGrey[900],
                                leading: StreamBuilder(
                                  stream: FlutterBlue.instance.isScanning,
                                  initialData: false,
                                  builder: (c, snapshot) {
                                    if (snapshot.data) {
                                      return FlatButton(
                                        child: Icon(
                                          FontAwesomeIcons.stop,
                                          color: Colors.white,
                                        ),
                                        onPressed: () =>
                                            FlutterBlue.instance.stopScan(),
                                        color: Colors.blueGrey[700],
                                        shape: new RoundedRectangleBorder(
                                            borderRadius:
                                                new BorderRadius.circular(
                                                    10.0)),
                                      );
                                    } else {
                                      return FlatButton(
                                          child: Icon(
                                            FontAwesomeIcons.search,
                                            color: Colors.white,
                                          ),
                                          color: Colors.blueGrey[700],
                                          shape: new RoundedRectangleBorder(
                                              borderRadius:
                                                  new BorderRadius.circular(
                                                      10.0)),
                                          onPressed: () => FlutterBlue.instance
                                              .startScan(
                                                  timeout:
                                                      Duration(seconds: 4)));
                                    }
                                  },
                                ),
                                title: Text('Show Device List',
                                    style: TextStyle(color: Colors.white)),
                                children: <Widget>[
                                  StreamBuilder<List<ScanResult>>(
                                    stream: FlutterBlue.instance.scanResults,
                                    initialData: [],
                                    builder: (c, snapshot) => Column(
                                      children: snapshot.data
                                          .map((r) => ScanResultTile(
                                                    result: r,
                                                    onTap: () {
                                                      stopScan();
                                                      Navigator.of(context)
                                                          .push(
                                                        MaterialPageRoute(
                                                          builder: (context) {
                                                            r.device.connect();
                                                            return Value(
                                                                device:
                                                                    r.device);
                                                          },
                                                        ),
                                                      );
                                                    },
                                                  )
                                              // : Container(),
                                              )
                                          .toList(),
                                    ),
                                  ),
                                ],
                              )
                            : Container(
                                width: double.infinity,
                                height: 30,
                                child: Center(
                                  child: Text(
                                    'Bluetooth Disabled',
                                    style: TextStyle(
                                      color: Colors.blueGrey[900],
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: <Widget>[
                            Flexible(
                              child: TextFormField(
                                maxLength: 2,
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                                decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                    borderSide:
                                        BorderSide(color: Colors.white70),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                    borderSide:
                                        BorderSide(color: Colors.blueGrey[900]),
                                  ),
                                  labelText: "Injected units",
                                  labelStyle: TextStyle(
                                    color: Colors.white,
                                  ),
                                  hintText:
                                      'Enter your injected units for correcting.',
                                  hintStyle: TextStyle(color: Colors.white38),
                                ),
                                keyboardType: TextInputType.number,
                                controller: _uiController,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: RaisedButton.icon(
                                color: Colors.blueGrey[700],
                                shape: new RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(10.0)),
                                label: Text(
                                  'Check Level',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                icon: Icon(
                                  FontAwesomeIcons.check,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  _calculateInsulinUnits(
                                    int.tryParse(_cvController.text),
                                    _time,
                                    settings,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              color: Colors.blueGrey[900]),
                          child: DropdownButtonFormField<String>(
                            icon: Icon(Icons.keyboard_arrow_down, size: 25),
                            iconEnabledColor: Colors.blueGrey[700],
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                                borderSide:
                                    BorderSide(color: Colors.blueGrey[800]),
                              ),
                            ),
                            hint: Text('Insulin',
                                style: TextStyle(color: Colors.white38)),
                            value: _insulinSort,
                            iconSize: 20,
                            elevation: 8,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                            onChanged: (String newValue) {
                              setState(() {
                                _insulinSort = newValue;
                              });
                            },
                            items: <String>[settings.bolus, settings.basal]
                                .map<DropdownMenuItem<String>>(
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
                          textAlignVertical: TextAlignVertical.top,
                          maxLines: 2,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          decoration: new InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              borderSide: BorderSide(color: Colors.white70),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              borderSide:
                                  BorderSide(color: Colors.blueGrey[900]),
                            ),
                            labelText: "Notes",
                            labelStyle: TextStyle(
                              color: Colors.white,
                            ),
                            hintText: 'Some space to take some notes.',
                            hintStyle: TextStyle(color: Colors.white38),
                          ),
                          controller: _nController,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    '$_day\.$_month\.$_year',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                RaisedButton(
                                  shape: new RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(10.0)),
                                  color: Colors.blueGrey[700],
                                  child: Icon(
                                    FontAwesomeIcons.calendarAlt,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    showDatePicker(
                                      context: context,
                                      initialDate: dt,
                                      firstDate: DateTime(1919),
                                      lastDate: dt,
                                    ).then((date) {
                                      setState(() {
                                        dt = date;
                                        _day = '${DateFormat('dd').format(dt)}';
                                        _month =
                                            '${DateFormat('MM').format(dt)}';
                                        _year =
                                            '${DateFormat('yyyy').format(dt)}';
                                      });
                                    });
                                  },
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    '$_hour:$_minutes' '',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                RaisedButton(
                                  shape: new RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(10.0)),
                                  color: Colors.blueGrey[700],
                                  child: Icon(
                                    FontAwesomeIcons.clock,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    showTimePicker(
                                      context: context,
                                      initialTime: _time,
                                    ).then((timePicked) {
                                      setState(() {
                                        _time = timePicked;
                                        _hour = '${_time.hour}'.length == 2
                                            ? '${_time.hour}'
                                            : '0${_time.hour}';
                                        _minutes = '${_time.minute}'.length == 2
                                            ? '${_time.minute}'
                                            : '0${_time.minute}';
                                      });
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(children: <Widget>[
                          Radio(
                              activeColor: Colors.white70,
                              value: 0,
                              groupValue: _radioValue,
                              onChanged: _handleRadioValueChange),
                          Icon(
                            FontAwesomeIcons.hamburger,
                            color:
                                _meal ? Colors.white70 : Colors.blueGrey[900],
                          ),
                          Radio(
                              activeColor: Colors.white70,
                              value: 1,
                              groupValue: _radioValue,
                              onChanged: _handleRadioValueChange),
                          Icon(
                            FontAwesomeIcons.dumbbell,
                            color:
                                _sport ? Colors.white70 : Colors.blueGrey[900],
                          ),
                          Radio(
                              activeColor: Colors.white70,
                              value: 2,
                              groupValue: _radioValue,
                              onChanged: _handleRadioValueChange),
                          Icon(
                            FontAwesomeIcons.bed,
                            color: _bed ? Colors.white70 : Colors.blueGrey[900],
                          ),
                        ]),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: <Widget>[
                            Expanded(flex: 4, child: Container()),
                            Expanded(
                              flex: 2,
                              child: RaisedButton.icon(
                                shape: new RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(10.0)),
                                color: Colors.blueGrey[700],
                                label: Text('Submit',
                                    style: TextStyle(
                                      color: Colors.white,
                                    )),
                                icon: Icon(
                                  FontAwesomeIcons.solidSave,
                                  color: Colors.white,
                                ),
                                onPressed: () => _saveEntry(
                                  int.tryParse(_cvController.text),
                                  _time,
                                  settings,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// class for building a singe bluetooth device liste tile

class ScanResultTile extends StatelessWidget {
  const ScanResultTile({Key key, this.result, this.onTap}) : super(key: key);

  final ScanResult result;
  final VoidCallback onTap;

  _buildTitle(BuildContext context) {
    // if (result.device.name.length > 0 &&
    //     result.device.id.toString() == '24:6F:28:A1:B5:16') {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          result.device.name,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          result.device.id.toString(),
          style: Theme.of(context).textTheme.caption,
        )
      ],
    );
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueGrey[800],
      child: ListTile(
        title: _buildTitle(context),
        leading: Text(result.rssi.toString()),
        trailing: result.device.id.toString() ==
                '24:6F:28:A1:B5:16' // Adresse des ESP32
            ? RaisedButton(
                child: Text('CONNECT'),
                color: Colors.blueGrey[700],
                textColor: Colors.white70,
                onPressed:
                    (result.advertisementData.connectable) ? onTap : null,
              )
            : FlatButton(
                onPressed: () {},
                color: Colors.blueGrey[900],
                child: Text('Not Supported',
                    style: TextStyle(
                      color: Colors.white30,
                    )),
              ),
      ),
    );
  }
}

// class for getting the value from ESP32 and passing the value to the
// Blood-Sugar_Level TextFormField Controller

class Value extends StatefulWidget {
  Value({Key key, this.device}) : super(key: key);
  final BluetoothDevice device;

  @override
  _ValueState createState() => _ValueState();
}

class _ValueState extends State<Value> {
  final String serviceUUID = "2d70aaee-2170-11ea-978f-2e728ce88125";
  final String characteristicUUID = "2d70ad8c-2170-11ea-978f-2e728ce88125";
  bool isReady;
  Stream<List<int>> stream;

  @override
  void initState() {
    super.initState();
    isReady = false;
    connectToDevice();
  }

  connectToDevice() async {
    if (widget.device == null) {
      _pop();
      return;
    }

    new Timer(const Duration(seconds: 15), () {
      if (!isReady) {
        disconnectFromDevice();
        _pop();
      }
    });
    await widget.device.connect();
    discoverServices();
  }

  disconnectFromDevice() {
    if (widget.device == null) {
      _pop();
      return;
    }
    widget.device.disconnect();
  }

  discoverServices() async {
    if (widget.device == null) {
      _pop();
      return;
    }

    List<BluetoothService> services = await widget.device.discoverServices();
    services.forEach((service) {
      if (service.uuid.toString() == serviceUUID) {
        service.characteristics.forEach((characteristic) {
          if (characteristic.uuid.toString() == characteristicUUID) {
            characteristic.setNotifyValue(!characteristic.isNotifying);
            stream = characteristic.value;
            setState(() {
              isReady = true;
            });
          }
        });
      }
    });

    if (!isReady) {
      _pop();
      return;
    }
  }

  // Hinweis der erscheint, wenn der zurück Button betätigt wird

  Future<bool> _onWillPop() {
    return showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
              backgroundColor: Colors.blueGrey[900],
              title: Text(
                'Are you sure',
                style: TextStyle(color: Colors.white70),
              ),
              content: Text(
                'Do you want to disconnect the device and go back?',
                style: TextStyle(color: Colors.white70),
              ),
              actions: <Widget>[
                FlatButton(
                  color: Colors.blueGrey[700],
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'No',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                FlatButton(
                  color: Colors.blueGrey[700],
                  onPressed: () {
                    disconnectFromDevice();
                    Navigator.of(context).pop(true);
                  },
                  child: Text(
                    'Yes',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ) ??
            false);
  }

  _pop() {
    Navigator.of(context).pop(true);
  }

  String _dataParser(List<int> dataFromDevice) {
    return utf8.decode(dataFromDevice);
  }

  bool isSynced = false;
  int value = 0;

  _getCurrentValue() {
    setState(() {
      _cvController.text = value.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Blood Sugar Measurement'),
          backgroundColor: Colors.blueGrey[800],
        ),
        body: Container(
          child: !isReady
              ? Container(
                  color: Colors.blueGrey[700],
                  child: Center(
                    child: Text(
                      'Waiting for Connection ...',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 24,
                      ),
                    ),
                  ),
                )
              : Container(
                  color: Colors.blueGrey[700],
                  child: StreamBuilder<List<int>>(
                    stream: stream,
                    builder: (BuildContext context,
                        AsyncSnapshot<List<int>> snapshot) {
                      if (snapshot.hasError)
                        return Text('Error: ${snapshot.error}');
                      if (snapshot.connectionState == ConnectionState.active) {
                        var currentValue = _dataParser(snapshot.data);
                        print(currentValue);
                        value = currentValue.isEmpty
                            ? 0
                            : double.parse(currentValue).round();
                        print('$value');
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Image.asset(
                                    'assets/images/esp32.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(
                                        'Last measured \nBlood Sugar Level',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 18,
                                        ),
                                      ),
                                      Text(
                                        '$value mg/dl',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      20.0, 0.0, 20.0, 0.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      FlatButton(
                                        color: Colors.blueGrey[800],
                                        onPressed: () {
                                          isSynced = true;
                                          _getCurrentValue();
                                          return Scaffold.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  "Last Blood Sugar Level synced"),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          'Sync Measurement',
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      } else {
                        return Text('Check the Stream');
                      }
                    },
                  ),
                ),
        ),
      ),
    );
  }
}
