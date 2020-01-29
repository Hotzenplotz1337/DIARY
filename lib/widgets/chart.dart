/// Line chart with range annotations example.
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/entrys.dart';
import '../models/diary_entry.dart';

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

  Future _getSettings() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      range =
          RangeValues(pref.getDouble('rangeStart'), pref.getDouble('rangeEnd'));
    });
  }

  Orientation orientation;

  // [BarLabelDecorator] will automatically position the label
  // inside the bar if the label will fit. If the label will not fit,
  // it will draw outside of the bar.
  // Labels can always display inside or outside using [LabelPosition].
  //
  // Text style for inside / outside can be controlled independently by setting
  // [insideLabelStyleSpec] and [outsideLabelStyleSpec].
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
                  : Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        color: Colors.blueGrey[700],
                        child: charts.BarChart(
                          _createSampleData(diaryEntrys.entrys),
                          animate: false,

                          defaultRenderer: charts.BarRendererConfig(
                              // By default, bar renderer will draw rounded bars with a constant
                              // radius of 100.
                              // To not have any rounded corners, use [NoCornerStrategy]
                              // To change the radius of the bars, use [ConstCornerStrategy]
                              cornerStrategy:
                                  const charts.ConstCornerStrategy(8)),

                          // Set a bar label decorator.
                          // Example configuring different styles for inside/outside:
                          //       barRendererDecorator: new charts.BarLabelDecorator(
                          //          insideLabelStyleSpec: new charts.TextStyleSpec(...),
                          //          outsideLabelStyleSpec: new charts.TextStyleSpec(...)),
                          // barRendererDecorator: new charts.BarLabelDecorator<String>(),
                          // domainAxis: new charts.OrdinalAxisSpec(),
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

                                  // Tick and Label styling here.
                                  labelStyle: charts.TextStyleSpec(
                                    fontSize: 8, // size in Pts.
                                    color: charts.MaterialPalette.white,
                                    lineHeight: 2,
                                  ),

                                  // Change the line colors to match text color.
                                  lineStyle: charts.LineStyleSpec(
                                      color: charts.MaterialPalette.white,
                                      thickness: 1))),

                          /// Assign a custom style for the measure axis.
                          primaryMeasureAxis: charts.NumericAxisSpec(
                              renderSpec: charts.GridlineRendererSpec(

                                  // Tick and Label styling here.
                                  labelStyle: charts.TextStyleSpec(
                                      fontSize: 8, // size in Pts.
                                      color: charts.MaterialPalette.white),

                                  // Change the line colors to match text color.
                                  lineStyle: charts.LineStyleSpec(
                                      color: charts.MaterialPalette.white))),
                        ),
                      ),
                    ),
            ),
    );
  }


  /// Create one series with sample hard coded data.
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
        // strokeWidthPxFn: (LinearValues values, _) => 5,
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

/// Sample ordinal data type.
class LinearValues {
  final String date;
  final int values;

  LinearValues(this.date, this.values);
}
