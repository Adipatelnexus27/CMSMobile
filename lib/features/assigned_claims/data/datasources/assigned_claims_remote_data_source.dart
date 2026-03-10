import "../../../../core/network/api_client.dart";
import "../models/assigned_claim_model.dart";

class AssignedClaimsRemoteDataSource {
  final ApiClient _apiClient;

  AssignedClaimsRemoteDataSource(this._apiClient);

  Future<List<AssignedClaimModel>> getAssignedClaims({
    required String accessToken,
    required String assigneeUserId,
    required String role,
  }) async {
    final rows = await _apiClient.getJsonList(
      "/claims/assigned",
      accessToken: accessToken,
      query: {
        "assigneeUserId": assigneeUserId,
        "role": role,
      },
    );

    return rows
        .whereType<Map<String, dynamic>>()
        .map(AssignedClaimModel.fromJson)
        .toList(growable: false);
  }
}
