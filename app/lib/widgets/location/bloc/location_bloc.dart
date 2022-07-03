
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rauschmelder/widgets/location/bloc/location_state.dart';
import 'package:rauschmelder/widgets/location/bloc/location_event.dart';
import 'package:rauschmelder/repositories/location_repository.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  LocationBloc({
    required this.locationRepository,
  }) : super(LocationState()) {
    on<GetLocation>(_getLocationEvent);
  }
  final LocationRepository locationRepository;

  void _getLocationEvent(GetLocation event, Emitter<LocationState> emit) async {
    try {
      emit(state.copyWith(status: LocationStateStatus.loading));

      var currentLocation = await locationRepository.getLocation();

      emit(
        state.copyWith(
          location: currentLocation,
          status: currentLocation == null ? LocationStateStatus.initial : LocationStateStatus.success,
        ),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: LocationStateStatus.error,
          errorMessage: e.toString(),
        ),
      );
      // This is important to check errors on tests.
      // Also you can see the error on the [BlocObserver.onError].
      addError(e);
      print(e);
    }
  }
}