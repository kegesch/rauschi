part of "./login_bloc.dart";

enum LoginStateStatus { initial, loading, loggedIn, error }

class LoginState {
  final LoginStateStatus status;
  final String error;
  const LoginState({this.status = LoginStateStatus.initial, String? error}) : error = error ?? "";

  List<Object?> get props => [error, status];

  LoginState copyWith({
    LoginStateStatus? status,
    String? error,
  }) {
    return LoginState(
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }
}