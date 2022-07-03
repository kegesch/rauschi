import 'dart:convert';

import 'package:rauschmelder/api/model/user.dart';
import 'package:rauschmelder/api/network.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationService {
  static const String userPreferenceField = "user";

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  NetworkProvider networkProvider;

  AuthenticationService({required this.networkProvider});

  Future<User?> getCurrentUser() async {
    var prefs = await _prefs;
    var userJson = prefs.getString(userPreferenceField);
    if (userJson == null) {
      return null;
    }

    var user = User.fromJson(jsonDecode(userJson));
    return user;
  }

  Future<User> registerUser(String userName) async {
    var user = await networkProvider.registerUser(userName);

    var prefs = await _prefs;
    var userJson = jsonEncode(user.toJson());
    await prefs.setString(userPreferenceField, userJson);

    return user;
  }
}