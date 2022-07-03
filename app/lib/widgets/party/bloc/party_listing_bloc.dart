import 'dart:async';

import 'package:rauschmelder/repositories/party_repository.dart';
import 'package:rauschmelder/widgets/location/bloc/location_bloc.dart';
import 'package:rauschmelder/widgets/location/bloc/location_state.dart';
import 'package:rauschmelder/widgets/party/bloc/party_listing_event.dart';
import 'package:rauschmelder/widgets/party/bloc/party_listing_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PartyListingBloc extends Bloc<PartyListingEvent, PartyListingState> {
  PartyRepository partyListingRepository;
  LocationBloc locationBloc;
  late StreamSubscription locationSubscription;

  PartyListingBloc({required this.partyListingRepository, required this.locationBloc}) : super(const PartyListingState()) {
    locationSubscription = locationBloc.stream.listen((state) {
      if (state.status == LocationStateStatus.success) {
        add(LocationChangedEvent(location: state.location!));
      }
    });
    on<LocationChangedEvent>(_mapLocationChangedEventToState);
  }

  void _mapLocationChangedEventToState(LocationChangedEvent event, Emitter<PartyListingState> emit) async {
    emit(state.copyWith(status: PartyListingStatus.loading));
    try {
      final parties = await partyListingRepository.fetchPartiesNearby(event.location);
      emit(
        state.copyWith(
          status: PartyListingStatus.success,
          parties: parties,
        ),
      );
    } catch (error, stacktrace) {
      print(stacktrace);
      emit(state.copyWith(status: PartyListingStatus.error));
    }
  }
}