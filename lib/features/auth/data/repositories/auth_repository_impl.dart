import "../../../../core/storage/session_storage.dart";
import "../../domain/entities/auth_session.dart";
import "../../domain/repositories/auth_repository.dart";
import "../datasources/auth_remote_data_source.dart";
import "../models/auth_session_model.dart";

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SessionStorage _sessionStorage;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required SessionStorage sessionStorage,
  })  : _remoteDataSource = remoteDataSource,
        _sessionStorage = sessionStorage;

  @override
  Future<AuthSession> login({required String email, required String password}) async {
    final session = await _remoteDataSource.login(email: email, password: password);
    await _sessionStorage.saveSession(session.toJson());
    return session;
  }

  @override
  Future<AuthSession?> restoreSession() async {
    final cached = await _sessionStorage.loadSession();
    if (cached == null) {
      return null;
    }

    try {
      final session = AuthSessionModel.fromJson(cached);
      if (session.accessToken.trim().isEmpty) {
        return null;
      }

      return session;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearSession() {
    return _sessionStorage.clearSession();
  }
}
