import "../entities/claim_document.dart";

abstract class DocumentRepository {
  Future<List<ClaimDocument>> getClaimDocuments({
    required String claimId,
    required bool latestOnly,
    required String accessToken,
  });

  Future<void> uploadDocument({
    required String claimId,
    required String filePath,
    required String fileName,
    required String documentCategory,
    String? documentGroupId,
    required String accessToken,
  });
}
