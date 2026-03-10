import "../entities/auth_session.dart";
import "../repositories/auth_repository.dart";

class RestoreSessionUseCase {
  final AuthRepository _repository;

  RestoreSessionUseCase(this._repository);

  Future<AuthSession?> call() {
    return _repository.restoreSession();
  }
}
