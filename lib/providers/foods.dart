import 'dart:io';

import 'package:flutter/foundation.dart';

import '../helper/db_food.dart';
import '../models/food_entry.dart';

class Foods with ChangeNotifier {
  // Liste wird deklariert, die später die Einträge enthalten soll

  List<Food> _foods = [];

  // Kopie von _foods wird erzeugt, damit die eigentliche Liste nicht direkt verändert wird

  List<Food> get foods {
    return [..._foods.reversed];
  }

  var foodId;
  var listIndex;

  void getId(foId) {
    foodId = foId;
    notifyListeners();
  }

  void getListIndex(liId) {
    listIndex = liId;
  }

  void addFood(
    String pickedId,
    File pickedImage,
    String pickedName,
    int pickedCarbohydrates,
    String pickedcategory,
    String pickeddescription,
  ) {
    final newFood = Food(
        id: pickedId,
        image: pickedImage,
        name: pickedName,
        carbohydrates: pickedCarbohydrates,
        category: pickedcategory,
        description: pickeddescription);
    _foods.add(newFood);
    notifyListeners();
    DBFood.insertFood(
      'user_foods',
      {
        'id': newFood.id,
        'image': newFood.image == null ? null : newFood.image.path,
        'name': newFood.name,
        'carbohydrates': newFood.carbohydrates,
        'category': newFood.category,
        'description': newFood.description,
      },
    );
  }

  Future<void> fetchAndSetFood(String search, bool isSearched) async {
    final dataList = await DBFood.getFood('user_foods', search, isSearched);
    _foods = dataList
        .map(
          (item) => Food(
            id: item['id'],
            image: item['image'] != null ? File(item['image']) : null,
            name: item['name'],
            carbohydrates: item['carbohydrates'],
            category: item['category'],
            description: item['description'],
          ),
        )
        .toList();
    notifyListeners();
  }

  Future<void> fetchAndSetFoodSearch(String search, bool _isSearched) async {
    final dataList =
        await DBFood.getSearchedFood('user_foods', search, _isSearched);
    _foods = dataList
        .map(
          (item) => Food(
            id: item['id'],
            image: File(item['image']),
            name: item['name'],
            carbohydrates: item['carbohydrates'],
            category: item['category'],
            description: item['description'],
          ),
        )
        .toList();
    if (_foods.isNotEmpty) {
      notifyListeners();
    }
  }

  void deleteFood(
    String id,
  ) {
    final foodsIndex = _foods.indexWhere((entry) => entry.id == id);
    final delId = '${_foods[foodsIndex].id}';
    _foods.removeAt(foodsIndex);
    notifyListeners();
    DBFood.removeFood(
      'user_foods',
      '$delId',
    );
  }

  void editEntry(
    String pickedId,
    File pickedImage,
    String pickedName,
    int pickedCarbohydrates,
    String pickedcategory,
    String pickeddescription,
  ) {
    final newFood = Food(
      id: foodId,
      image: pickedImage,
      name: pickedName,
      carbohydrates: pickedCarbohydrates,
      category: pickedcategory,
      description: pickeddescription,
    );
    final foodIndex = _foods.indexWhere((food) => food.id == foodId);
    final editId = _foods[foodIndex].id;
    _foods.removeAt(foodIndex);
    _foods.insert(foodIndex, newFood);
    notifyListeners();
    DBFood.updateFood(
      'user_foods',
      editId,
      {
        'id': newFood.id,
        'image': newFood.image.path,
        'name': newFood.name,
        'carbohydrates': newFood.carbohydrates,
        'category': newFood.category,
        'description': newFood.description,
      },
    );
  }
}
