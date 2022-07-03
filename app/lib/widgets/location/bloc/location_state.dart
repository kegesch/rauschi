import 'package:rauschmelder/services/location_service.dart';

enum LocationStateStatus { initial, success, error, loading }

extension LocationStateStatusX on LocationStateStatus {
  bool get isInitial => this == LocationStateStatus.initial;
  bool get isSuccess => this == LocationStateStatus.success;
  bool get isError => this == LocationStateStatus.error;
  bool get isLoading => this == LocationStateStatus.loading;
}

class LocationState {
  const LocationState({
    this.status = LocationStateStatus.initial,
    this.location,
    String? errorMessage,
  })  : errorMessage = errorMessage ?? '';

  final LocationStateStatus status;
  final Geo? location;
  final String errorMessage;

  @override
  List<Object?> get props => [
    status,
    location,
    errorMessage,
  ];

  LocationState copyWith({
    LocationStateStatus? status,
    Geo? location,
    String? errorMessage,
  }) {
    return LocationState(
      status: status ?? this.status,
      location: location ?? this.location,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}