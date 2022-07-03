import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rauschmelder/api/model/user.dart';
import 'package:rauschmelder/services/authentication_service.dart';

part 'authentication_event.dart';

part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final AuthenticationService _authenticationService;

  AuthenticationBloc({required AuthenticationService authenticationService})
      : _authenticationService = authenticationService,
        super(const AuthenticationState()) {
    on<AppLoaded>(_mapAppLoadedToState);
    on<UserRegistered>(_mapUserRegisteredToState);
  }

  void _mapAppLoadedToState(AppLoaded event, Emitter<AuthenticationState> emit) async {
    emit(state.copyWith(status: AuthenticationStateStatus.loading));

    try {
      final currentUser = await _authenticationService.getCurrentUser();

      if (currentUser != null) {
        emit(state.copyWith(status: AuthenticationStateStatus.authenticated, user: currentUser));
      } else {
        emit(state.copyWith(status: AuthenticationStateStatus.notAuthenticated));
      }
    } catch (e) {
      emit(state.copyWith(status: AuthenticationStateStatus.error, error: e.toString()));
    }
  }

  void _mapUserRegisteredToState(UserRegistered event, Emitter<AuthenticationState> emit) async {
    emit(state.copyWith(status: AuthenticationStateStatus.loading));

    try {
      final currentUser = await _authenticationService.registerUser(event.userName);
      emit(state.copyWith(status: AuthenticationStateStatus.authenticated, user: currentUser));
    } catch (e) {
      emit(state.copyWith(status: AuthenticationStateStatus.error, error: e.toString()));
    }
  }
}
