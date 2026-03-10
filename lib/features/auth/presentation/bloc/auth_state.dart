import "package:equatable/equatable.dart";

import "../../domain/entities/auth_session.dart";

enum AuthStatus {
  unknown,
  loading,
  authenticated,
  unauthenticated,
  failure,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final AuthSession? session;
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.session,
    this.errorMessage,
  });

  const AuthState.initial()
      : status = AuthStatus.unknown,
        session = null,
        errorMessage = null;

  AuthState copyWith({
    AuthStatus? status,
    AuthSession? session,
    bool clearSession = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      session: clearSession ? null : (session ?? this.session),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, session, errorMessage];
}
