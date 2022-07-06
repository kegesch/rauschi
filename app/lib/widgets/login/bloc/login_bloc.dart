
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../services/authentication_service.dart';
import '../../authentication/bloc/authentication_bloc.dart';
part  "./login_state.dart";
part  "./login_event.dart";

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthenticationBloc authenticationBloc;
  final AuthenticationService authenticationService;

  LoginBloc({required this.authenticationBloc, required this.authenticationService}) : super(const LoginState())
  {
    on<LoginWithUserNameButtonPressed>(_mapLoginWithUsernameToState);
  }


  void _mapLoginWithUsernameToState(LoginWithUserNameButtonPressed event, Emitter<LoginState> emit) async {
    emit(state.copyWith(status: LoginStateStatus.loading));

    try {
      authenticationBloc.add(UserRegistered(userName: event.userName));
      emit(state.copyWith(status: LoginStateStatus.loggedIn));
    } catch (err) {
      emit(state.copyWith(status: LoginStateStatus.error, error: err.toString()));
    }
  }
}