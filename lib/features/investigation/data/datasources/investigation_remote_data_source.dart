import "../../../../core/network/api_client.dart";
import "../models/investigation_detail_model.dart";

class InvestigationRemoteDataSource {
  final ApiClient _apiClient;

  InvestigationRemoteDataSource(this._apiClient);

  Future<InvestigationDetailModel> getInvestigation({
    required String claimId,
    required String accessToken,
  }) async {
    final response = await _apiClient.getJsonMap(
      "/claims/$claimId/investigation",
      accessToken: accessToken,
    );

    return InvestigationDetailModel.fromJson(response);
  }

  Future<void> updateProgress({
    required String claimId,
    required int progressPercent,
    required String accessToken,
  }) {
    return _apiClient.putNoContent(
      "/claims/$claimId/investigation/progress",
      accessToken: accessToken,
      payload: {
        "progressPercent": progressPercent,
      },
    );
  }

  Future<void> addNote({
    required String claimId,
    required String noteText,
    int? progressPercentSnapshot,
    required String accessToken,
  }) {
    return _apiClient.postNoContent(
      "/claims/$claimId/investigation/notes",
      accessToken: accessToken,
      payload: {
        "noteText": noteText,
        "progressPercentSnapshot": progressPercentSnapshot,
      },
    );
  }

  Future<void> uploadDocument({
    required String claimId,
    required String filePath,
    required String fileName,
    required String documentCategory,
    required String accessToken,
  }) {
    return _apiClient.postMultipart(
      "/claims/$claimId/investigation/documents",
      accessToken: accessToken,
      filePath: filePath,
      fileFieldName: "file",
      fileName: fileName,
      fields: {
        "documentCategory": documentCategory,
      },
    ).then((_) => null);
  }
}
