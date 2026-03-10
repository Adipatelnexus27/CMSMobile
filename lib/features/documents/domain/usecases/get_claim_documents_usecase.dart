import "../entities/claim_document.dart";
import "../repositories/document_repository.dart";

class GetClaimDocumentsUseCase {
  final DocumentRepository _repository;

  GetClaimDocumentsUseCase(this._repository);

  Future<List<ClaimDocument>> call({
    required String claimId,
    required bool latestOnly,
    required String accessToken,
  }) {
    return _repository.getClaimDocuments(
      claimId: claimId,
      latestOnly: latestOnly,
      accessToken: accessToken,
    );
  }
}
