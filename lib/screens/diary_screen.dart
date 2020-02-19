import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/app_drawer.dart';
import '../providers/entrys.dart';
import '../screens/new_entry_screen.dart';
import '../screens/edit_entry_screen.dart';

class DiaryScreen extends StatefulWidget {
  static const routeName = '/entry-list-screen';
  @override
  _DiaryScreenState createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  void _delEntry(id) {
    Provider.of<Entrys>(context, listen: false).deleteEntry(id);
  }

  // Settings needed

  RangeValues range;

  // Entry data;

  String _entryId;
  DateTime _selectedDate;
  String day = '${DateFormat('dd').format(DateTime.now())}';
  String month = '${DateFormat('MM').format(DateTime.now())}';
  String year = '${DateFormat('yyyy').format(DateTime.now())}';
  bool _dateIsPicked = false;
  bool isExpand = false;

  activitySelected(bool sel) {
    if (sel) {
      return Colors.white;
    }
    return Colors.blueGrey[900];
  }

  @override
  void initState() {
    super.initState();
    _getSettings();
  }

  // colors for the Blood-Sugar-Level value
  // green => good value
  // orange => slightly increased value
  // red => too high value

  getColor(String val, range) {
    var value = int.parse(val);
    if (value <= range.end && value >= range.start) {
      return Colors.green;
    } else if (value > range.end && value < 240 ||
        value < range.start && value > 40) {
      return Colors.orange;
    } else if (value <= 40 || value >= 240) {
      return Colors.red;
    }
  }

  // method to get current Settings from Shared Preferences

  Future _getSettings() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      range =
          RangeValues(pref.getDouble('rangeStart'), pref.getDouble('rangeEnd'));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
          elevation: 0,
          backgroundColor: Theme.of(context).accentColor,
          title: Text(
            'Diary',
            style: GoogleFonts.openSans(
              textStyle: TextStyle(color: Colors.white),
              fontSize: 20,
            ),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(FontAwesomeIcons.filter),
              color: _dateIsPicked ? Colors.white70 : Colors.blueGrey[900],
              onPressed: () {
                setState(() {
                  _dateIsPicked = false;
                });
              },
              splashColor: Colors.blueGrey[400],
            ),
            IconButton(
                icon: Icon(FontAwesomeIcons.calendarAlt),
                color: Colors.white,
                onPressed: () {
                  showDatePicker(
                    context: context,
                    initialDate:
                        _selectedDate == null ? DateTime.now() : _selectedDate,
                    firstDate: DateTime(1919),
                    lastDate: DateTime.now(),
                  ).then((date) {
                    setState(() {
                      _selectedDate = date;
                      day = '${DateFormat('dd').format(_selectedDate)}';
                      month = '${DateFormat('MM').format(_selectedDate)}';
                      year = '${DateFormat('yyyy').format(_selectedDate)}';
                      print('$_selectedDate');
                      if (!_dateIsPicked) {
                        _dateIsPicked = true;
                      }
                    });
                  });
                }),
          ]),
      body: FutureBuilder(
        future: Provider.of<Entrys>(context, listen: false)
            .fetchAndSetEntrys(_dateIsPicked, day, month, year),
        builder: (ctx, snapshot) => snapshot.connectionState ==
                ConnectionState.waiting
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Consumer<Entrys>(
                child: Container(
                  height: double.infinity,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).accentColor,
                  ),
                  child: Center(
                    child: Text(
                      'Got no entrys yet,\nstart adding some.',
                      style: TextStyle(
                        fontFamily: 'SourceSansPro',
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                builder: (ctx, diaryEntrys, ch) => diaryEntrys.entrys.length <=
                        0
                    ? ch
                    : Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).accentColor,
                        ),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: diaryEntrys.entrys.length,
                          itemBuilder: (ctx, index) {
                            return Dismissible(
                              key: Key('${diaryEntrys.entrys[index].id}'),
                              direction: DismissDirection.endToStart,
                              confirmDismiss: (_) => showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: Colors.blueGrey[900],
                                    title: Text(
                                      'You are going to delete the chosen Entry.',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    content: Text(
                                      'Are you sure?',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    actions: <Widget>[
                                      FlatButton(
                                        color: Colors.blueGrey[700],
                                        child: Text('Yes'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          setState(
                                            () {
                                              _entryId =
                                                  '${diaryEntrys.entrys[index].id}';
                                              _delEntry(_entryId);
                                            },
                                          );
                                        },
                                      ),
                                      FlatButton(
                                        color: Colors.blueGrey[700],
                                        child: Text('No'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ], /*shape: ,*/
                                  );
                                },
                              ),
                              onDismissed: (direction) {},
                              background: Container(
                                child: Container(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Icon(FontAwesomeIcons.trash,
                                        size: 20, color: Colors.white),
                                  ),
                                ),
                              ),
                              child: Card(
                                elevation: 6,
                                color: Theme.of(context).backgroundColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: ExpansionTile(
                                    leading: IconButton(
                                      icon: Icon(
                                        FontAwesomeIcons.book,
                                        color: getColor(
                                            diaryEntrys
                                                .entrys[index].currentValue,
                                            range),
                                      ),
                                      onPressed: null,
                                      enableFeedback: true,
                                    ),
                                    key: Key('${diaryEntrys.entrys[index].id}'),
                                    title: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Container(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                '${diaryEntrys.entrys[index].currentValue}',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w700,
                                                  color: getColor(
                                                      diaryEntrys.entrys[index]
                                                          .currentValue,
                                                      range),
                                                ),
                                              ),
                                              Text(
                                                '${diaryEntrys.entrys[index].day}.${diaryEntrys.entrys[index].month}.${diaryEntrys.entrys[index].year}',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w300,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              Text(
                                                '${diaryEntrys.entrys[index].hour}:${diaryEntrys.entrys[index].minutes}',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w300,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          width: 15,
                                        ),
                                        Expanded(
                                            flex: 1,
                                            child: Column(
                                              children: <Widget>[
                                                Row(
                                                  children: <Widget>[
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Icon(
                                                        FontAwesomeIcons
                                                            .syringe,
                                                        color: diaryEntrys
                                                                    .entrys[
                                                                        index]
                                                                    .isInjected &&
                                                                diaryEntrys
                                                                        .entrys[
                                                                            index]
                                                                        .unitsInjected !=
                                                                    '0'
                                                            ? Colors.white
                                                            : Colors
                                                                .blueGrey[900],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Icon(
                                                        FontAwesomeIcons
                                                            .hamburger,
                                                        size: 20,
                                                        color: activitySelected(
                                                            diaryEntrys
                                                                .entrys[index]
                                                                .meal),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: <Widget>[
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Icon(
                                                        FontAwesomeIcons
                                                            .dumbbell,
                                                        size: 20,
                                                        color: activitySelected(
                                                            diaryEntrys
                                                                .entrys[index]
                                                                .sport),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Icon(
                                                        FontAwesomeIcons.bed,
                                                        size: 20,
                                                        color: activitySelected(
                                                            diaryEntrys
                                                                .entrys[index]
                                                                .bed),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            )),
                                      ],
                                    ),
                                    children: <Widget>[
                                      ListTile(
                                        leading: IconButton(
                                          icon: Icon(
                                            FontAwesomeIcons.edit,
                                            color: Colors.white70,
                                          ),
                                          onPressed: () {
                                            Provider.of<Entrys>(context).getId(
                                                diaryEntrys.entrys[index].id);
                                            Provider.of<Entrys>(context)
                                                .getListIndex(index);
                                            Navigator.of(context).pushNamed(
                                                EditEntryScreen.routeName);
                                          },
                                        ),
                                        title: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            (diaryEntrys
                                                            .entrys[index]
                                                            .unitsInjected
                                                            .isEmpty ||
                                                        diaryEntrys
                                                                .entrys[index]
                                                                .unitsInjected ==
                                                            '0') &&
                                                    diaryEntrys.entrys[index]
                                                        .notes.isEmpty
                                                ? Text(
                                                    'No notes left.',
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w300,
                                                      color: Colors.white,
                                                    ),
                                                  )
                                                : Text(
                                                    diaryEntrys
                                                            .entrys[index]
                                                            .unitsInjected
                                                            .isEmpty
                                                        ? ''
                                                        : 'Injected Units: ${diaryEntrys.entrys[index].unitsInjected}',
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w300,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                            Text(
                                              diaryEntrys
                                                          .entrys[index]
                                                          .unitsInjected
                                                          .isEmpty ||
                                                      diaryEntrys.entrys[index]
                                                              .sort ==
                                                          null
                                                  ? ''
                                                  : 'Insulin: ${diaryEntrys.entrys[index].sort}',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w300,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              diaryEntrys.entrys[index].notes
                                                      .isEmpty
                                                  ? ''
                                                  : 'Notes: ${diaryEntrys.entrys[index].notes}',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w300,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ]),
                              ),
                            );
                          },
                        ),
                      ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 6,
        onPressed: () {
          Navigator.of(context).pushNamed(NewEntryScreen.routeName);
        },
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Theme.of(context).backgroundColor,
      ),
      drawer: AppDrawer(),
    );
  }
}
