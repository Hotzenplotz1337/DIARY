import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/entrys.dart';
import '../models/diary_entry.dart';

// class that builds the vertical Scrollable List on Home Screen

class Carousel extends StatefulWidget {
  Carousel({Key key}) : super(key: key);

  @override
  _CarouselState createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  PageController _pageController;
  RangeValues range = RangeValues(70.0, 170.0);
  static String day = '${DateFormat('dd').format(DateTime.now())}';
  static String month = '${DateFormat('MM').format(DateTime.now())}';
  static String year = '${DateFormat('yyyy').format(DateTime.now())}';

  AppBar appBar = AppBar(
    title: Text('Get the height of an AppBar'),
  );

  @override
  void initState() {
    super.initState();
    _getSettings();
    _pageController =
        PageController(initialPage: 0, keepPage: false, viewportFraction: 0.8);
  }

  Future _getSettings() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      range =
          RangeValues(pref.getDouble('rangeStart'), pref.getDouble('rangeEnd'));
    });
  }

  Orientation orientation;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return FutureBuilder(
      future: Provider.of<Entrys>(context, listen: false)
          .fetchAndSetTodaysEntrys(day, month, year),
      builder: (ctx, snapshot) => snapshot.connectionState ==
              ConnectionState.waiting
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Consumer<Entrys>(
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
              builder: (ctx, diaryEntrys, ch) => diaryEntrys.entrys.length <= 0
                  ? ch
                  : Container(
                      width: width,
                      height: orientation == Orientation.portrait
                          ? (MediaQuery.of(context).size.height -
                                  appBar.preferredSize.height) /
                              2
                          : MediaQuery.of(context).size.height -
                              appBar.preferredSize.height,
                      child: PageView.builder(
                        pageSnapping: true,
                        reverse: false,
                        itemCount: diaryEntrys.entrys.length,
                        controller: _pageController,
                        itemBuilder: (context, index) =>
                            animateItemBuilder(index, diaryEntrys.entrys),
                      ),
                    ),
            ),
    );
  }

  animateItemBuilder(int index, List<Entry> list) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        double value = 0.85;
        if (_pageController.position.haveDimensions) {
          value = _pageController.page - index;
          value = (0.85 - (value.abs() * 0.1))
              .clamp(0.0, 1.0); // Werte verstehen !!! Animationen lernen
        }
        return Column(
          children: <Widget>[
            // SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: Curves.easeIn.transform(value) * 300,
                width: double.infinity,
                child: Container(
                  height: ((MediaQuery.of(context).size.height -
                          appBar.preferredSize.height) /
                      2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(13)),
                    color: index % 2 == 0
                        ? Colors.blueGrey[900]
                        : Colors.blueGrey[700],
                  ),
                  margin: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        '${list[index].currentValue}',
                        style: TextStyle(
                          fontSize: 60,
                          color: int.tryParse(list[index].currentValue) <
                                      range.start ||
                                  int.tryParse(list[index].currentValue) >
                                      range.end
                              ? (int.tryParse(list[index].currentValue) > 50 &&
                                      int.tryParse(list[index].currentValue) <
                                          240
                                  ? Colors.orange
                                  : Colors.red)
                              : Colors.green,
                        ),
                      ),
                      Text(
                        '${list[index].day}.${list[index].month}.${list[index].year}',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                      Text(
                        '${list[index].hour}\:${list[index].minutes}',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
