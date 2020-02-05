/// Line chart with range annotations example.
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/entrys.dart';
import '../models/diary_entry.dart';

// class that builds the Bar Chart on Home Screen

class VerticalBarLabelChart extends StatefulWidget {
  @override
  _VerticalBarLabelChartState createState() => _VerticalBarLabelChartState();
}

class _VerticalBarLabelChartState extends State<VerticalBarLabelChart> {
  final int currentIndex = 0;
  final String day = '${DateFormat('dd').format(DateTime.now())}';
  final String month = '${DateFormat('MM').format(DateTime.now())}';
  final String year = '${DateFormat('yyyy').format(DateTime.now())}';

  RangeValues range = RangeValues(70.0, 170.0);

  AppBar appBar = AppBar(
    title: Text('Get appBar width'),
  );
  
  @override
  void initState() {
    super.initState();
    _getSettings();
  }

  // method to get the current Settings

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
    return FutureBuilder(
      future: Provider.of<Entrys>(context, listen: false)
          .fetchAndSetTodaysEntrys(day, month, year),
      builder: (ctx, snapshot) => snapshot.connectionState ==
              ConnectionState.waiting
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Consumer<Entrys>(
              child: Center(),
              builder: (ctx, diaryEntrys, ch) => diaryEntrys.entrys.length <= 0
                  ? ch
                  : Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        color: Colors.blueGrey[700],
                        child: charts.BarChart(
                          _createSampleData(diaryEntrys.entrys),
                          animate: false,
                          defaultRenderer: charts.BarRendererConfig(
                              // draw rounded bars with a radius of 8
                              cornerStrategy:
                                  const charts.ConstCornerStrategy(8)),
                          behaviors: [
                            charts.RangeAnnotation(
                              [
                                charts.RangeAnnotationSegment(
                                    range.start,
                                    range.end,
                                    charts.RangeAnnotationAxisType.measure,
                                    labelAnchor:
                                        charts.AnnotationLabelAnchor.end,
                                    color:
                                        charts.Color.fromHex(code: '#263238'),
                                    endLabel: '${range.end.toInt()}',
                                    startLabel: '${range.start.toInt()}',
                                    labelPosition:
                                        charts.AnnotationLabelPosition.margin,
                                    labelStyleSpec: charts.TextStyleSpec(
                                        fontSize: 8,
                                        color: charts.Color.fromHex(
                                            code: '#263238'))),
                              ],
                            ),
                          ],
                          domainAxis: charts.OrdinalAxisSpec(
                            renderSpec: charts.SmallTickRendererSpec(
                              // horizontal axis styling
                              labelStyle: charts.TextStyleSpec(
                                fontSize: 8, // size in Pts.
                                color: charts.MaterialPalette.white,
                                lineHeight: 2,
                              ),
                              lineStyle: charts.LineStyleSpec(
                                color: charts.MaterialPalette.white,
                                thickness: 1,
                              ),
                            ),
                          ),
                          primaryMeasureAxis: charts.NumericAxisSpec(
                            renderSpec: charts.GridlineRendererSpec(
                              // vertical axis styling
                              labelStyle: charts.TextStyleSpec(
                                fontSize: 8, // size in Pts.
                                color: charts.MaterialPalette.white,
                              ),
                              lineStyle: charts.LineStyleSpec(
                                color: charts.MaterialPalette.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
    );
  }

  // method to get the data for creating the barChart
  List<charts.Series<LinearValues, String>> _createSampleData(
      List<Entry> list) {
    List<LinearValues> data = [];
    print('${list[0].hour}\:${list[0].minutes}');
    for (int i = 0; i < list.length; i++) {
      data.add(LinearValues('${list[i].hour}\:${list[i].minutes}',
          int.tryParse(list[i].currentValue)));
    }
    return [
      charts.Series<LinearValues, String>(
        id: 'values',
        domainFn: (LinearValues values, _) => values.date,
        measureFn: (LinearValues values, _) => values.values,
        data: data,
        fillColorFn: (LinearValues values, __) =>
            (values.values < range.start || values.values > range.end)
                ? (values.values > 50 && values.values < 240
                    ? charts.Color.fromHex(code: '#FF9800')
                    : charts.Color.fromHex(code: '#F44336'))
                : charts.Color.fromHex(code: '#4CAF50'),
      )
    ];
  }
}

// implement a datatype for the barChart
class LinearValues {
  final String date;
  final int values;

  LinearValues(this.date, this.values);
}
