import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'drink.dart';

class UserModel {
  String? userName;
  List<Drink> drinks = List.empty();

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future load() async {
    userName = await getUserName();
    drinks = await getDrinks();
    print("done loading from storage");
  }

  Future<bool> isLoggedIn() async {
    return (await getUserName()) != null;
  }

  Future<String?> getUserName() async {
    print("getting user name");
    if(userName == null) {
      var prefs = await _prefs;
      userName = prefs.getString("UserName");
    }
    print("got user name");
    return userName;
  }

  Future setUserName(String? userName) async {
    if (userName == null) {
      return;
    }
    var prefs = await _prefs;
    await prefs.setString("UserName", userName);
  }

  Future<List<Drink>> getDrinks() async {
    print("getting drinks");
    var prefs = await _prefs;
    var drinks = prefs.getString("Drinks");

    List<Drink> drinksList;
    if (drinks == null) {
      print("drinks list is empty");
      drinksList = List.empty(growable: true);
    } else {
      var decoded = json.decode(drinks)['drinks'];
      drinksList = List<Drink>.from(decoded
          .map((data) => Drink.fromJson(data))
          .toList());
      print("parsed drink list");
    }
    return drinksList;
  }

  Future addDrink(Drink drink) async {
    var prefs = await _prefs;

    var drinkList = await getDrinks();
    drinkList.add(drink);

    var jsonMap = {};
    jsonMap['drinks'] = drinkList;
    var encoded = json.encode(jsonMap);
    await prefs.setString("Drinks", encoded);
  }

}