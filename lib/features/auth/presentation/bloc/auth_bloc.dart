import "package:flutter_bloc/flutter_bloc.dart";

import "../../domain/usecases/login_usecase.dart";
import "../../domain/usecases/logout_usecase.dart";
import "../../domain/usecases/restore_session_usecase.dart";
import "auth_event.dart";
import "auth_state.dart";

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final RestoreSessionUseCase _restoreSessionUseCase;
  final LogoutUseCase _logoutUseCase;

  AuthBloc({
    required LoginUseCase loginUseCase,
    required RestoreSessionUseCase restoreSessionUseCase,
    required LogoutUseCase logoutUseCase,
  })  : _loginUseCase = loginUseCase,
        _restoreSessionUseCase = restoreSessionUseCase,
        _logoutUseCase = logoutUseCase,
        super(const AuthState.initial()) {
    on<AuthAppStarted>(_onAppStarted);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onAppStarted(AuthAppStarted event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));

    try {
      final session = await _restoreSessionUseCase();
      if (session == null) {
        emit(state.copyWith(
          status: AuthStatus.unauthenticated,
          clearSession: true,
          clearError: true,
        ));
        return;
      }

      emit(state.copyWith(
        status: AuthStatus.authenticated,
        session: session,
        clearError: true,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        clearSession: true,
        errorMessage: error.toString(),
      ));
    }
  }

  Future<void> _onLoginRequested(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));

    try {
      final session = await _loginUseCase(
        email: event.email.trim(),
        password: event.password,
      );

      emit(state.copyWith(
        status: AuthStatus.authenticated,
        session: session,
        clearError: true,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        clearSession: true,
        errorMessage: error.toString(),
      ));
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await _logoutUseCase();
    emit(state.copyWith(
      status: AuthStatus.unauthenticated,
      clearSession: true,
      clearError: true,
    ));
  }
}
