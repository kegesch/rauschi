import '../api/network.dart';
import '../api/model/party.dart';
import '../services/location_service.dart';

class PartyRepository {
  final NetworkProvider _api = NetworkProvider();

  Future<List<Party>> fetchPartiesNearby(Geo location) =>
      _api.fetchPartiesNearby(location);
}