part of 'user_bloc.dart';

class UserEvent {
  @override
  List<Object?> get props => [];
}

class RegisterUser extends UserEvent {
  String userName;

  RegisterUser({required this.userName});
}
