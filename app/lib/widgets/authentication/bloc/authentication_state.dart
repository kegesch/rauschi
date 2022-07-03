part of 'authentication_bloc.dart';

enum AuthenticationStateStatus { initial, loading, notAuthenticated, authenticated, error }

class AuthenticationState {
  final AuthenticationStateStatus status;
  final User? user;
  final String error;
  const AuthenticationState({this.status = AuthenticationStateStatus.initial, this.user, String? error}) : error = error ?? "";

  List<Object?> get props => [user, error, status];

  AuthenticationState copyWith({
    AuthenticationStateStatus? status,
    User? user,
    String? error,
  }) {
    return AuthenticationState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }
}