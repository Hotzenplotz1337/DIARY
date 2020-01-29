import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/app_drawer.dart';
import '../providers/foods.dart';
import '../screens/new_food_screen.dart';
import '../screens/edit_food_screen.dart';

class FoodScreen extends StatefulWidget {
  static const routeName = '/food-list-screen';
  @override
  _FoodScreenState createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  String _entryId;
  String search = '';
  int count = 0;
  final _searchCont = TextEditingController();
  bool _isactive = false;
  bool _isSearched = false;
  void _delFood(id) {
    Provider.of<Foods>(context, listen: false).deleteFood(id);
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
          'Food',
          style: GoogleFonts.openSans(
            textStyle: TextStyle(color: Colors.white),
            fontSize: 20,
          ),
        ),
        actions: <Widget>[
          IconButton(
            color: _isSearched ? Colors.white70 : Colors.blueGrey[900],
            icon: Icon(FontAwesomeIcons.filter),
            onPressed: () {
              setState(() {
                _isSearched = false;
                _isactive = false;
                count = 0;
              });
            },
          ),
          IconButton(
            color: Colors.white70,
            icon: Icon(FontAwesomeIcons.search),
            onPressed: () {
              if (count == 1)
                setState(() {
                  _isSearched = true;
                  search = _searchCont.text;
                  _isactive = false;
                  return;
                });
              count++;
              if (count == 1)
                setState(() {
                  _isactive = true;
                });
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: Provider.of<Foods>(context, listen: false)
            .fetchAndSetFood(_searchCont.text, _isSearched),
        builder: (ctx, snapshot) => snapshot.connectionState ==
                ConnectionState.waiting
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Consumer<Foods>(
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
                        fontSize: 20,
                        color: Colors.white,
                        fontFamily: 'SourceSansPro',
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ),
                builder: (ctx, foodEntrys, ch) => foodEntrys.foods.length <= 0
                    ? ch
                    : Column(
                        children: <Widget>[
                          _isactive
                              ? Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: TextFormField(
                                      maxLength: 30,
                                      style: TextStyle(
                                        color: Colors.white70,
                                      ),
                                      decoration: InputDecoration(
                                        // icon: Icon(FontAwesomeIcons.search),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10.0)),
                                          borderSide:
                                              BorderSide(color: Colors.white70),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10.0)),
                                          borderSide: BorderSide(
                                              color: Colors.blueGrey[900]),
                                        ),
                                        labelText: "Search",
                                        labelStyle: TextStyle(
                                          color: Colors.white70,
                                        ),
                                        hintText:
                                            'Enter the foods name you want to search.',
                                        hintStyle:
                                            TextStyle(color: Colors.white38),
                                      ),
                                      keyboardType: TextInputType.text,
                                      controller: _searchCont),
                                )
                              : Container(),
                          Expanded(
                            child: Scrollbar(
                              child: ListView.builder(
                                  padding: EdgeInsets.all(8.0),
                                  itemCount: foodEntrys.foods.length,
                                  itemBuilder: (ctx, index) {
                                    return Dismissible(
                                      key: Key('${foodEntrys.foods[index].id}'),
                                      direction: DismissDirection.endToStart,
                                      onDismissed: (direction) {
                                        setState(
                                          () {
                                            _entryId =
                                                '${foodEntrys.foods[index].id}';
                                            _delFood(_entryId);
                                          },
                                        );
                                      },
                                      background: Container(
                                        child: Container(
                                          alignment: Alignment.centerRight,
                                          child: Padding(
                                            padding: const EdgeInsets.all(15.0),
                                            child: Icon(FontAwesomeIcons.trash,
                                                size: 20, color: Colors.white),
                                          ),
                                        ),
                                      ),
                                      child: Card(
                                        elevation: 6,
                                        color:
                                            Theme.of(context).backgroundColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        ),
                                        child: ExpansionTile(
                                          title: Row(
                                            children: <Widget>[
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        0.0, 15.0, 0.0, 15.0),
                                                child: Container(
                                                  child: Container(
                                                    height: 120,
                                                    width: 90,
                                                    decoration: BoxDecoration(
                                                      image: DecorationImage(
                                                        image: foodEntrys
                                                                    .foods[
                                                                        index]
                                                                    .image !=
                                                                null
                                                            ? FileImage(
                                                                foodEntrys
                                                                    .foods[
                                                                        index]
                                                                    .image,
                                                              )
                                                            : AssetImage(
                                                                'assets/images/np.png'),
                                                        fit: BoxFit.fitWidth,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      15.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: <Widget>[
                                                      Text(
                                                        '${foodEntrys.foods[index].name}',
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      Text(
                                                        '${foodEntrys.foods[index].carbohydrates}g',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w300,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      Text(
                                                        '${(foodEntrys.foods[index].carbohydrates / 12).toStringAsFixed(1)} BE',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w300,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      Text(
                                                        '${(foodEntrys.foods[index].carbohydrates / 10).toStringAsFixed(1)} KE',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w300,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          children: <Widget>[
                                            ListTile(
                                              leading: Container(
                                                width: 90,
                                                child: IconButton(
                                                  icon: Icon(
                                                    FontAwesomeIcons.edit,
                                                    color: Colors.white70,
                                                  ),
                                                  onPressed: () {
                                                    Provider.of<Foods>(context)
                                                        .getId(foodEntrys
                                                            .foods[index].id);
                                                    Provider.of<Foods>(context)
                                                        .getListIndex(index);
                                                    Navigator.of(context)
                                                        .pushNamed(
                                                            EditFoodScreen
                                                                .routeName);
                                                  },
                                                ),
                                              ),
                                              title: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  foodEntrys.foods[index]
                                                              .category ==
                                                          null
                                                      ? Text('Category: -',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            color: Colors.white,
                                                          ),)
                                                      : Text(
                                                          'Category: ${foodEntrys.foods[index].category}',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                  foodEntrys.foods[index]
                                                              .description ==
                                                          ''
                                                      ? Text('Description: -',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            color: Colors.white,
                                                          ),)
                                                      : Text(
                                                          'Description: ${foodEntrys.foods[index].description}',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                          ),
                        ],
                      ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 6,
        onPressed: () {
          Navigator.of(context).pushNamed(NewFoodScreen.routeName);
        },
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Theme.of(context).backgroundColor,
      ),
      drawer: AppDrawer(),
    );
  }
}
