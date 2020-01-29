import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/app_drawer.dart';
// import '../providers/entrys.dart';
import '../widgets/carousel.dart';
import '../widgets/chart.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home-screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //je nach Wert soll dieser in unterschiedlichen Fraben dargestellt werden,
  //sodass schneller verstanden wird, ob der Wert gut oder schlecht ist

  AppBar appBar = AppBar(
    title: Text('Get the height of an AppBar'),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Theme.of(context).accentColor,
        title: Text(
          'Home',
          style: GoogleFonts.openSans(
            textStyle: TextStyle(color: Colors.white),
            fontSize: 20,
          ),
        ),
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return GridView.count(
            shrinkWrap: true,
            primary: false,
            crossAxisCount: orientation == Orientation.portrait ? 1 : 1,
            childAspectRatio: orientation == Orientation.portrait
                ? (MediaQuery.of(context).size.width + 30) /
                    (MediaQuery.of(context).size.height -
                        appBar.preferredSize.height)
                : (MediaQuery.of(context).size.width) /
                    (MediaQuery.of(context).size.height -
                        appBar.preferredSize.height - 30),
            children: <Widget>[
              orientation == Orientation.portrait
                  ? Container(
                      color: Colors.blueGrey[800],
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            flex: 4,
                            child: Carousel(),
                          ),
                          Expanded(
                            flex: 5,
                            child: Container(
                              child: Padding(
                                padding: const EdgeInsets.all(25.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(13)),
                                    color: Colors.blueGrey[700],
                                  ),
                                  padding: EdgeInsets.all(10),
                                  child: VerticalBarLabelChart(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Row(
                      children: <Widget>[
                        Container(
                            width: (MediaQuery.of(context).size.width / 2),
                            child: Carousel()),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            width:
                                ((MediaQuery.of(context).size.width / 2) - 50),
                            height: (MediaQuery.of(context).size.height -
                                appBar.preferredSize.height -
                                60),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(13)),
                              color: Colors.blueGrey[700],
                            ),
                            child: VerticalBarLabelChart(),
                          ),
                        ),
                      ],
                    ),
            ],
          );
        },
      ),
      drawer: AppDrawer(),
    );
  }
}
