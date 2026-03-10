import "../entities/investigation_detail.dart";

abstract class InvestigationRepository {
  Future<InvestigationDetail> getInvestigation({
    required String claimId,
    required String accessToken,
  });

  Future<void> updateProgress({
    required String claimId,
    required int progressPercent,
    required String accessToken,
  });

  Future<void> addNote({
    required String claimId,
    required String noteText,
    int? progressPercentSnapshot,
    required String accessToken,
  });

  Future<void> uploadDocument({
    required String claimId,
    required String filePath,
    required String fileName,
    required String documentCategory,
    required String accessToken,
  });
}
