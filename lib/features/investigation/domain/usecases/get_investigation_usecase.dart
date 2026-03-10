import "../entities/investigation_detail.dart";
import "../repositories/investigation_repository.dart";

class GetInvestigationUseCase {
  final InvestigationRepository _repository;

  GetInvestigationUseCase(this._repository);

  Future<InvestigationDetail> call({
    required String claimId,
    required String accessToken,
  }) {
    return _repository.getInvestigation(claimId: claimId, accessToken: accessToken);
  }
}
