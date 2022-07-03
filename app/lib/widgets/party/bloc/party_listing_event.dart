import 'package:rauschmelder/api/model/party.dart';

import '../../../services/location_service.dart';

abstract class PartyListingEvent{}

class LocationChangedEvent extends PartyListingEvent {
  final Geo location;
  LocationChangedEvent({required this.location});
}