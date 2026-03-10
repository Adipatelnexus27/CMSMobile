import "../../../../core/errors/app_exception.dart";
import "../../../../core/utils/jwt_utils.dart";
import "../../domain/entities/assigned_claim.dart";
import "../../domain/repositories/assigned_claims_repository.dart";
import "../datasources/assigned_claims_remote_data_source.dart";

class AssignedClaimsRepositoryImpl implements AssignedClaimsRepository {
  final AssignedClaimsRemoteDataSource _remoteDataSource;

  AssignedClaimsRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<AssignedClaim>> getAssignedClaims({
    required String accessToken,
    required String role,
    String? assigneeUserId,
  }) async {
    final resolvedUserId =
        (assigneeUserId != null && assigneeUserId.trim().isNotEmpty) ? assigneeUserId.trim() : JwtUtils.extractUserId(accessToken);

    if (resolvedUserId == null || resolvedUserId.isEmpty) {
      throw const AppException("Unable to resolve assignee user id from token.");
    }

    return _remoteDataSource.getAssignedClaims(
      accessToken: accessToken,
      assigneeUserId: resolvedUserId,
      role: role,
    );
  }
}
