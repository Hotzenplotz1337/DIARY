import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../screens/home_screen.dart';
import '../screens/diary_screen.dart';
import '../screens/food_screen.dart';
import '../screens/settings_screen.dart';

// class that builds the AppDrawer (Navigation)

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Theme.of(context).accentColor,
        child: Column(
          children: <Widget>[
            AppBar(
              title: Text(
                'Navigation',
                style: GoogleFonts.openSans(
                  textStyle: TextStyle(color: Colors.white),
                  fontSize: 20,
                ),
              ),
              automaticallyImplyLeading: false,
              backgroundColor: Theme.of(context).accentColor,
              elevation: 0,
            ),
            ListTile(
              leading: Icon(FontAwesomeIcons.home, color: Colors.white),
              title: Text(
                'Home',
                style: GoogleFonts.openSans(
                  textStyle: TextStyle(color: Colors.white),
                  fontSize: 20,
                ),
              ),
              onTap: () {
                Navigator.of(context)
                    .pushReplacementNamed(HomeScreen.routeName);
              },
            ),
            Divider(
              endIndent: 5,
              indent: 5,
              color: Theme.of(context).backgroundColor,
              thickness: 1,
            ),
            ListTile(
              leading: Icon(FontAwesomeIcons.book, color: Colors.white),
              title: Text(
                'Diary',
                style: GoogleFonts.openSans(
                  textStyle: TextStyle(color: Colors.white),
                  fontSize: 20,
                ),
              ),
              onTap: () {
                Navigator.of(context)
                    .pushReplacementNamed(DiaryScreen.routeName);
              },
            ),
            Divider(
              endIndent: 5,
              indent: 5,
              color: Theme.of(context).backgroundColor,
              thickness: 1,
            ),
            ListTile(
              leading: Icon(FontAwesomeIcons.list, color: Colors.white),
              title: Text(
                'Food',
                style: GoogleFonts.openSans(
                  textStyle: TextStyle(color: Colors.white),
                  fontSize: 20,
                ),
              ),
              onTap: () {
                Navigator.of(context)
                    .pushReplacementNamed(FoodScreen.routeName);
              },
            ),
            Divider(
              endIndent: 5,
              indent: 5,
              color: Theme.of(context).backgroundColor,
              thickness: 1,
            ),
            ListTile(
              leading: Icon(FontAwesomeIcons.cog, color: Colors.white),
              title: Text(
                'Settings',
                style: GoogleFonts.openSans(
                  textStyle: TextStyle(color: Colors.white),
                  fontSize: 20,
                ),
              ),
              onTap: () {
                Navigator.of(context)
                    .pushReplacementNamed(SettingsScreen.routeName);
              },
            ),
            Divider(
              endIndent: 5,
              indent: 5,
              color: Theme.of(context).backgroundColor,
              thickness: 1,
            ),
          ],
        ),
      ),
    );
  }
}
