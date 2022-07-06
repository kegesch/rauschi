part of "./login_bloc.dart";


abstract class LoginEvent {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

class LoginWithUserNameButtonPressed extends LoginEvent {
  final String userName;

  LoginWithUserNameButtonPressed({required this.userName});

  @override
  List<Object> get props => [userName];
}