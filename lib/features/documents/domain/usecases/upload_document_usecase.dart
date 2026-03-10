import "../repositories/document_repository.dart";

class UploadDocumentUseCase {
  final DocumentRepository _repository;

  UploadDocumentUseCase(this._repository);

  Future<void> call({
    required String claimId,
    required String filePath,
    required String fileName,
    required String documentCategory,
    String? documentGroupId,
    required String accessToken,
  }) {
    return _repository.uploadDocument(
      claimId: claimId,
      filePath: filePath,
      fileName: fileName,
      documentCategory: documentCategory,
      documentGroupId: documentGroupId,
      accessToken: accessToken,
    );
  }
}
