import "../repositories/investigation_repository.dart";

class UploadInvestigationDocumentUseCase {
  final InvestigationRepository _repository;

  UploadInvestigationDocumentUseCase(this._repository);

  Future<void> call({
    required String claimId,
    required String filePath,
    required String fileName,
    required String documentCategory,
    required String accessToken,
  }) {
    return _repository.uploadDocument(
      claimId: claimId,
      filePath: filePath,
      fileName: fileName,
      documentCategory: documentCategory,
      accessToken: accessToken,
    );
  }
}
