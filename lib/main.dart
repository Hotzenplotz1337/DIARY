import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './providers/entrys.dart';
import './providers/foods.dart';
import './screens/new_entry_screen.dart';
import './screens/edit_entry_screen.dart';
import './screens/diary_screen.dart';
import './screens/home_screen.dart';
import './screens/new_food_screen.dart';
import './screens/edit_food_screen.dart';
import './screens/settings_screen.dart';
import './screens/food_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var pref = await SharedPreferences.getInstance();
  if (!pref.containsKey('rangeStart')) {
    print('Settings initialization');
    // on first App start set default Settings
    pref.setDouble('rangeStart', 70.0);
    pref.setDouble('rangeEnd', 170.0);
    pref.setString('basal', 'Toujeo');
    pref.setString('bolus', 'Liprolog');
    pref.setDouble('morning', 2.0);
    pref.setDouble('noon', 1.0);
    pref.setDouble('evening', 1.5);
    pref.setInt('relation', 50);
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Entrys(),
        ),
        ChangeNotifierProvider.value(
          value: Foods(),
        ),
      ],
      child: MaterialApp(
        title: 'Diabetes Diary',
        theme: ThemeData(
          textTheme: GoogleFonts.openSansTextTheme(Theme.of(context).textTheme),
          primarySwatch: Colors.blueGrey,
          accentColor: Colors.blueGrey[800],
          canvasColor: Colors.blueGrey[800],
          backgroundColor: Colors.blueGrey[700],
        ),
        home: HomeScreen(),
        routes: {
          HomeScreen.routeName: (ctx) => HomeScreen(),
          DiaryScreen.routeName: (ctx) => DiaryScreen(),
          NewEntryScreen.routeName: (ctx) => NewEntryScreen(),
          EditEntryScreen.routeName: (ctx) => EditEntryScreen(),
          FoodScreen.routeName: (ctx) => FoodScreen(),
          NewFoodScreen.routeName: (ctx) => NewFoodScreen(),
          EditFoodScreen.routeName: (ctx) => EditFoodScreen(),
          SettingsScreen.routeName: (ctx) => SettingsScreen(),
        },
      ),
    );
  }
}
