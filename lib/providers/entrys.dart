import 'package:flutter/foundation.dart';

import '../helper/db_helper.dart';
import '../models/diary_entry.dart';

// provider class for Diary Entrys, used to get Diary Data in several screens

class Entrys with ChangeNotifier {
  List<Entry> _entrys = [];

  // copy of _entrys, so _entrys never gets directly edited from other screens

  List<Entry> get entrys {
    return [..._entrys.reversed];
  }

  var entryId;
  var listIndex;

  void getId(entId) {
    entryId = entId;
    notifyListeners();
  }

  void getListIndex(liId) {
    listIndex = liId;
  }

  void addEntry(
      String id,
      String day,
      String month,
      String year,
      String hour,
      String minutes,
      String pickedCurrentValue,
      String pickedUnitsInjected,
      String pickedSort,
      String pickedNotes,
      bool injected,
      bool meal,
      bool sport,
      bool bed) {
    final newEntry = Entry(
      id: id,
      day: day,
      month: month,
      year: year,
      hour: hour,
      minutes: minutes,
      currentValue: pickedCurrentValue,
      unitsInjected: pickedUnitsInjected,
      sort: pickedSort,
      notes: pickedNotes,
      isInjected: injected,
      meal: meal,
      sport: sport,
      bed: bed,
    );
    _entrys.add(newEntry);
    notifyListeners();
    DBHelper.insertEntry(
      'user_diary',
      {
        'id': newEntry.id,
        'day': newEntry.day,
        'month': newEntry.month,
        'year': newEntry.year,
        'hour': newEntry.hour,
        'minutes': newEntry.minutes,
        'currentValue': newEntry.currentValue,
        'unitsInjected': newEntry.unitsInjected,
        'sort': newEntry.sort,
        'notes': newEntry.notes,
        'isInjected': newEntry.isInjected ? 1 : 0,
        'meal': newEntry.meal ? 1 : 0,
        'sport': newEntry.sport ? 1 : 0,
        'bed': newEntry.bed ? 1 : 0,
      },
    );
  }

  Future<void> fetchAndSetEntrys(
      bool dayPicked, String day, String month, String year) async {
    final dataList =
        await DBHelper.getData('user_diary', day, month, year, dayPicked);
    _entrys = dataList
        .map(
          (item) => Entry(
            id: item['id'],
            day: item['day'],
            month: item['month'],
            year: item['year'],
            hour: item['hour'],
            minutes: item['minutes'],
            currentValue: item['currentValue'],
            unitsInjected: item['unitsInjected'],
            sort: item['sort'],
            notes: item['notes'],
            isInjected: item['isInjected'] == 1 ? true : false,
            meal: item['meal'] == 1 ? true : false,
            sport: item['sport'] == 1 ? true : false,
            bed: item['bed'] == 1 ? true : false,
          ),
        )
        .toList();
    notifyListeners();
  }

  Future<void> fetchAndSetTodaysEntrys(
      String day, String month, String year) async {
    final dataList =
        await DBHelper.getTodaysData('user_diary', day, month, year);
    _entrys = dataList
        .map(
          (item) => Entry(
            id: item['id'],
            day: item['day'],
            month: item['month'],
            year: item['year'],
            hour: item['hour'],
            minutes: item['minutes'],
            currentValue: item['currentValue'],
            unitsInjected: item['unitsInjected'],
            sort: item['sort'],
            notes: item['notes'],
            isInjected: item['isInjected'] == 1 ? true : false,
            meal: item['meal'] == 1 ? true : false,
            sport: item['sport'] == 1 ? true : false,
            bed: item['bed'] == 1 ? true : false,
          ),
        )
        .toList();
    notifyListeners();
  }

  void deleteEntry(
    String id,
  ) {
    final entryIndex = _entrys.indexWhere((entry) => entry.id == id);
    final delId = '${_entrys[entryIndex].id}';
    _entrys.removeAt(entryIndex);
    notifyListeners();
    DBHelper.removeEntry(
      'user_diary',
      '$delId',
    );
  }

  void editEntry(
    String id,
    String day,
    String month,
    String year,
    String hour,
    String minutes,
    String pickedCurrentValue,
    String pickedUnitsInjected,
    String pickedSort,
    String pickedNotes,
    bool injected,
    bool meal,
    bool sport,
    bool bed,
  ) {
    final newEntry = Entry(
      id: entryId,
      day: day,
      month: month,
      year: year,
      hour: hour,
      minutes: minutes,
      currentValue: pickedCurrentValue,
      unitsInjected: pickedUnitsInjected,
      sort: pickedSort,
      notes: pickedNotes,
      isInjected: injected,
      meal: meal,
      sport: sport,
      bed: bed,
    );
    print(entryId);
    final entryIndex = _entrys.indexWhere((entry) => entry.id == entryId);
    print(entryIndex);
    final editId = _entrys[entryIndex].id;
    _entrys.removeAt(entryIndex);
    _entrys.insert(entryIndex, newEntry);
    notifyListeners();
    DBHelper.updateEntry(
      'user_diary',
      editId,
      {
        'id': newEntry.id,
        'day': newEntry.day,
        'month': newEntry.month,
        'year': newEntry.year,
        'hour': newEntry.hour,
        'minutes': newEntry.minutes,
        'currentValue': newEntry.currentValue,
        'unitsInjected': newEntry.unitsInjected,
        'sort': newEntry.sort,
        'notes': newEntry.notes,
        'isInjected': newEntry.isInjected ? 1 : 0,
        'meal': newEntry.meal ? 1 : 0,
        'sport': newEntry.sport ? 1 : 0,
        'bed': newEntry.bed ? 1 : 0,
      },
    );
  }
}
