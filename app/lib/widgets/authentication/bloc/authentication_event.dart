part of 'authentication_bloc.dart';

abstract class AuthenticationEvent {
  const AuthenticationEvent();

  @override
  List<Object> get props => [];
}

// Fired just after the app is launched
class AppLoaded extends AuthenticationEvent {}

// Fired when a user has successfully logged in
class UserRegistered extends AuthenticationEvent {
  final String userName;

  UserRegistered({required this.userName});

  @override
  List<Object> get props => [userName];
}