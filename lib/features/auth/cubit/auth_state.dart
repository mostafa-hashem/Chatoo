import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class EmailVerifyRequestSentLoading extends AuthState {}

class EmailVerifyRequestSentSuccess extends AuthState {}

class EmailVerifyRequestSentError extends AuthState {
  final String message;

  EmailVerifyRequestSentError(this.message);

  @override
  List<Object?> get props => [message];
}

class DeleteAccountLoading extends AuthState {}

class DeleteAccountSuccess extends AuthState {}

class DeleteAccountError extends AuthState {
  final String message;

  DeleteAccountError(this.message);

  @override
  List<Object?> get props => [message];
}

class PasswordResetRequestSent extends AuthState {}

class LoggedOut extends AuthState {}
