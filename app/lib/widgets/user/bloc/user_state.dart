part of 'user_bloc.dart';

enum UserStateStatus { initial, success, error, loading }

class UserState {
  final UserStateStatus status;
  final User? user;
  final String errorMessage;

  const UserState({
    this.status = UserStateStatus.initial,
    this.user,
    String? errorMessage,
  }) : errorMessage = errorMessage ?? '';

  @override
  List<Object?> get props =>
      [
        status,
        user,
        errorMessage,
      ];

  UserState copyWith({
    UserStateStatus? status,
    User? user,
    String? errorMessage,
  }) {
    return UserState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}