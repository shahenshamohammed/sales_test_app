import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../auth/auth_firebase_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuthRepository repo;
  AuthBloc(this.repo) : super(const AuthState()) {
    on<AuthCheckRequested>(_onCheck);
    on<LoginSubmitted>(_onLogin);
    on<LogoutRequested>(_onLogout);
  }

  Future<void> _onCheck(AuthCheckRequested e, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.checking, error: null));
    final ok = await repo.hasValidSession();
    emit(state.copyWith(status: ok ? AuthStatus.authenticated : AuthStatus.unauthenticated));
  }

// lib/src/presentation/blocs/auth/auth_bloc.dart
  Future<void> _onLogin(LoginSubmitted e, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.submitting, error: null));
    try {
      await repo.signIn(email: e.email, password: e.password);
      emit(state.copyWith(status: AuthStatus.success));
    } on FirebaseAuthException catch (ex, st) {
      // Log full details to console for debugging
      // (Don't show stack to users; just helpful while developing)
      // ignore: avoid_print
      print('FirebaseAuthException: code=${ex.code}, message=${ex.message}\n$st');

      final msg = switch (ex.code) {
        'invalid-email'           => 'Please enter a valid email address.',
        'user-disabled'           => 'This account has been disabled.',
        'user-not-found'          => 'No user found with this email.',
        'wrong-password'          => 'Incorrect password. Please try again.',
        'invalid-credential'      => 'Invalid email/password combination.', // newer SDKs return this
        'operation-not-allowed'   => 'Email/password sign-in is disabled. Enable it in Firebase Console.',
        'network-request-failed'  => 'Network error. Check your connection and try again.',
        'too-many-requests'       => 'Too many attempts. Try again later.',
        _                         => 'Login failed (${ex.code}).',
      };
      emit(state.copyWith(status: AuthStatus.failure, error: msg));
    } catch (ex, st) {
      // Log the non-Firebase error so we can see what failed (often secure storage)
      // ignore: avoid_print
      print('Non-Firebase error during login: $ex\n$st');
      emit(state.copyWith(
        status: AuthStatus.failure,
        error: 'Something went wrong. Please try again.',
      ));
    }
  }


  Future<void> _onLogout(LogoutRequested e, Emitter<AuthState> emit) async {
    await repo.signOut();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
