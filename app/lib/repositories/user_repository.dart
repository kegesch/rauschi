import 'package:rauschmelder/api/model/user.dart';
import 'package:rauschmelder/api/network.dart';

class UserRepository {
  NetworkProvider networkProvider;

  UserRepository({required this.networkProvider});

  Future<User> registerUser(String userName) async {
    return await networkProvider.registerUser(userName);
  }
}