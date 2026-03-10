import "../repositories/investigation_repository.dart";

class UpdateInvestigationProgressUseCase {
  final InvestigationRepository _repository;

  UpdateInvestigationProgressUseCase(this._repository);

  Future<void> call({
    required String claimId,
    required int progressPercent,
    required String accessToken,
  }) {
    return _repository.updateProgress(
      claimId: claimId,
      progressPercent: progressPercent,
      accessToken: accessToken,
    );
  }
}
