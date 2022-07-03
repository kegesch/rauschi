import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rauschmelder/repositories/user_repository.dart';
import 'package:rauschmelder/api/model/user.dart';

part 'user_state.dart';
part 'user_event.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserRepository userRepository;

  UserBloc({required this.userRepository}) : super(const UserState()) {
    on<RegisterUser>(_registerUser);
  }

  void _registerUser(RegisterUser event, Emitter<UserState> emit) async {
    try {
      emit(state.copyWith(status: UserStateStatus.loading));

      var registeredUser = await userRepository.registerUser(event.userName);

      emit(
        state.copyWith(
          user: registeredUser,
          status: UserStateStatus.success,
        ),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: UserStateStatus.error,
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