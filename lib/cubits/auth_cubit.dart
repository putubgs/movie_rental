import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthState.unauthenticated());

  Future<void> loginWithEmail(String email, String password) async {
    emit(state.copyWith(status: AuthStatus.loading));
    await Future.delayed(const Duration(milliseconds: 800));
    // TODO: replace with real auth
    emit(const AuthState.authenticated());
  }

  Future<void> registerWithEmail(String email, String password) async {
    emit(state.copyWith(status: AuthStatus.loading));
    await Future.delayed(const Duration(milliseconds: 800));
    // TODO: replace with real register
    emit(const AuthState.authenticated());
  }

  void logout() {
    emit(const AuthState.unauthenticated());
  }
}
