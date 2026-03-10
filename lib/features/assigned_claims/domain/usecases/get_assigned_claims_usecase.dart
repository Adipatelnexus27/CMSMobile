import "../entities/assigned_claim.dart";
import "../repositories/assigned_claims_repository.dart";

class GetAssignedClaimsUseCase {
  final AssignedClaimsRepository _repository;

  GetAssignedClaimsUseCase(this._repository);

  Future<List<AssignedClaim>> call({
    required String accessToken,
    required String role,
    String? assigneeUserId,
  }) {
    return _repository.getAssignedClaims(
      accessToken: accessToken,
      role: role,
      assigneeUserId: assigneeUserId,
    );
  }
}
