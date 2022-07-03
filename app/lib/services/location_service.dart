import 'package:rauschmelder/api/network.dart';
import 'package:location/location.dart';

class Geo {
  late double longitude;
  late double latitude;

  Geo.fromLocation(LocationData location) {
    longitude = location.longitude!;
    latitude = location.latitude!;
  }

}

class LocationService {
  final Location location = Location();

  LocationService();
  
  Future<Geo?> getCurrentLocation() async {
    print("getting location");
    if (await location.hasPermission() == PermissionStatus.denied) {
      var permission = await location.requestPermission();
      if(permission == PermissionStatus.denied || permission == PermissionStatus.deniedForever) {
        return null;
      }
    }

    return Geo.fromLocation(await location.getLocation());
  }
}
