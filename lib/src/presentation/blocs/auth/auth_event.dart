abstract class AuthEvent {}

class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;
  LoginSubmitted(this.email, this.password);
}

class LogoutRequested extends AuthEvent {}

class AuthCheckRequested extends AuthEvent {} // ← NEW: run at app start
