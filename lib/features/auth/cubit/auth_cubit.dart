import 'package:chat_app/features/auth/cubit/auth_state.dart';
import 'package:chat_app/features/auth/data/models/login_data.dart';
import 'package:chat_app/features/auth/data/models/register_data.dart';
import 'package:chat_app/features/auth/data/services/auth_firebase_service.dart';
import 'package:chat_app/utils/data/failure/failure.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  static AuthCubit get(BuildContext context) => BlocProvider.of(context);

  final authFirebaseService = AuthFirebaseService();
  bool isLoggedIn = false;
  bool isVisible = false;
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  Future<void> register(RegisterData registerData) async {
    emit(EmailVerifyRequestSentLoading());
    try {
      await authFirebaseService.register(registerData);
      emit(EmailVerifyRequestSentSuccess());
    } catch (e) {
      emit(EmailVerifyRequestSentError(Failure.fromException(e).message));
    }
  }

  Future<void> login(LoginData loginData) async {
    emit(AuthLoading());
    try {
      await authFirebaseService.login(loginData);
      isLoggedIn = true;
      emit(AuthSuccess());
    } catch (e) {
      emit(AuthError(Failure.fromException(e).message));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await authFirebaseService.logout();
      isLoggedIn = false;
      emit(LoggedOut());
    } catch (e) {
      emit(AuthError(Failure.fromException(e).message));
    }
  }

  Future<void> requestPasswordReset(String emailAddress) async {
    emit(AuthLoading());
    try {
      await authFirebaseService.requestPasswordReset(emailAddress);
      emit(PasswordResetRequestSent());
    } catch (e) {
      emit(AuthError(Failure.fromException(e).message));
    }
  }

  void getAuthStatus() {
    try {
      isLoggedIn = authFirebaseService.getAuthStatus();
    } catch (e) {
      emit(AuthError(Failure.fromException(e).message));
    }
  }

  Future<void> deleteAccount() async {
    emit(DeleteAccountLoading());
    try {
      await authFirebaseService.deleteAccount();
      emit(DeleteAccountSuccess());
    } catch (e) {
      emit(DeleteAccountError(Failure.fromException(e).message));
    }
  }
}
