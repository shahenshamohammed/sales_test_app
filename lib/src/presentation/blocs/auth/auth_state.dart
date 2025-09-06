enum AuthStatus {
  initial,
  checking,          // ← NEW
  authenticated,     // ← NEW (for app-start check result)
  unauthenticated,   // ← NEW
  submitting,        // during login
  success,           // login ok (you already use this in LoginScreen to navigate)
  failure,
}

class AuthState {
  final AuthStatus status;
  final String? error;
  const AuthState({this.status = AuthStatus.initial, this.error});

  AuthState copyWith({AuthStatus? status, String? error}) =>
      AuthState(status: status ?? this.status, error: error);
}
