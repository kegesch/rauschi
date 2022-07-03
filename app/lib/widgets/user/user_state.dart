import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../drink.dart';

class UserModel {
  static const Duration minimumDurationBetweenDrinksAdded = Duration(minutes: 5);

  String? userName;
  List<Drink> drinks = List.empty();
  DateTime? lastAddedDrinkTimestamp;

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
      try {
        drinksList = List<Drink>.from(decoded
            .map((data) => Drink.fromJson(data))
            .toList());
      } catch (error) {
        drinksList = List.empty(growable: true);
      }
    }
    return drinksList;
  }

  Future addDrink(Drink drink) async {
    if (lastAddedDrinkTimestamp != null) {
      var timeDiff = DateTime.now().difference(lastAddedDrinkTimestamp!);
      if(timeDiff < minimumDurationBetweenDrinksAdded) {
        throw Exception("Last added drink was ${timeDiff.inMinutes} min ago. Try again in ${(minimumDurationBetweenDrinksAdded - timeDiff).inMinutes} min.");
      }
    }


    var prefs = await _prefs;

    var drinkList = await getDrinks();
    drinkList.add(drink);

    var jsonMap = {};
    jsonMap['drinks'] = drinkList;
    var encoded = json.encode(jsonMap);
    await prefs.setString("Drinks", encoded);

    lastAddedDrinkTimestamp = DateTime.now();
  }

  Future<int> getNearbyParties() async {
    return 5;
  }

}