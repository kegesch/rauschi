import 'dart:convert';
import '../services/location_service.dart';
import 'model/party.dart';
import 'package:http/http.dart' as http;

import 'model/user.dart';

class NetworkProvider {

  String baseUrl = "localhost:8000";
  String partyPath = "party";
  String precisionPath = "precision";
  String userPath = "user";
  final successCode = 200;

  Future<User> registerUser(String userName) async {
    final uri = Uri.http(baseUrl, userPath);
    var user = User(name: userName);
    Map<String,String> headers = {
      'Content-type' : 'application/json',
      'Accept': 'application/json',
    };

    final response = await http.post(uri, headers: headers, body: jsonEncode(user.toJson()));
    var responseJson = jsonDecode(response.body);
    return User.fromJson(responseJson);
  }

  Future<List<Party>> fetchPartiesNearby(Geo location) async {
    final parameters = {
      'location.longitude': location.longitude.toString(),
      'location.latitude': location.latitude.toString(),
    };

    final uri = Uri.http(baseUrl, partyPath, parameters);
    final response = await http.get(uri);

    return parsePartyListResponse(response);
  }

  List<Party> parsePartyListResponse(http.Response response) {
    final responseMaps = jsonDecode(response.body) as List<dynamic>;

    if (response.statusCode == successCode) {
      return responseMaps.map((e) => Party.fromJson(e)).toList();
    } else {
      throw Exception('failed to load parties');
    }
  }

  Future<int> fetchLocationPrecision() async {
    final response = await http.get(Uri.http(baseUrl, precisionPath));
    return jsonDecode(response.body) as int;
  }
}