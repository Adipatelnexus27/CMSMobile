import "../../../../core/network/api_client.dart";
import "../models/claim_document_model.dart";

class DocumentRemoteDataSource {
  final ApiClient _apiClient;

  DocumentRemoteDataSource(this._apiClient);

  Future<List<ClaimDocumentModel>> getClaimDocuments({
    required String claimId,
    required bool latestOnly,
    required String accessToken,
  }) async {
    final rows = await _apiClient.getJsonList(
      "/documents/claims/$claimId",
      accessToken: accessToken,
      query: {"latestOnly": latestOnly.toString()},
    );

    return rows
        .whereType<Map<String, dynamic>>()
        .map(ClaimDocumentModel.fromJson)
        .toList(growable: false);
  }

  Future<void> uploadDocument({
    required String claimId,
    required String filePath,
    required String fileName,
    required String documentCategory,
    String? documentGroupId,
    required String accessToken,
  }) async {
    final fields = <String, String>{"documentCategory": documentCategory};
    if (documentGroupId != null && documentGroupId.trim().isNotEmpty) {
      fields["documentGroupId"] = documentGroupId.trim();
    }

    await _apiClient.postMultipart(
      "/documents/claims/$claimId/upload",
      accessToken: accessToken,
      filePath: filePath,
      fileFieldName: "file",
      fileName: fileName,
      fields: fields,
    );
  }
}
