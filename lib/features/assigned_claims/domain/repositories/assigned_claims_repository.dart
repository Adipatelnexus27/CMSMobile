import "../entities/assigned_claim.dart";

abstract class AssignedClaimsRepository {
  Future<List<AssignedClaim>> getAssignedClaims({
    required String accessToken,
    required String role,
    String? assigneeUserId,
  });
}
