import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthCubit() : super(const AuthState.initial()) {
    _auth.userChanges().listen((user) {
      if (user != null) {
        emit(const AuthState.authenticated());
      } else {
        emit(const AuthState.unauthenticated());
      }
    });
  }

  Future<void> loginWithEmail(String email, String password) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      emit(const AuthState.authenticated());
    } on FirebaseAuthException catch (e) {
      emit(AuthState(status: AuthStatus.failure, errorMessage: e.message));
    } catch (e) {
      emit(AuthState(status: AuthStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> registerWithEmail(String email, String password) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      emit(const AuthState.authenticated());
    } on FirebaseAuthException catch (e) {
      emit(AuthState(status: AuthStatus.failure, errorMessage: e.message));
    } catch (e) {
      emit(AuthState(status: AuthStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    emit(const AuthState.unauthenticated());
  }
}
