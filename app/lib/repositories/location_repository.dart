import 'package:rauschmelder/services/location_service.dart';

class LocationRepository {
  LocationService locationService;

  LocationRepository({required this.locationService});

  Future<Geo?> getLocation() async {
    return await locationService.getCurrentLocation();
  }
}