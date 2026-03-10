import "../repositories/investigation_repository.dart";

class AddInvestigationNoteUseCase {
  final InvestigationRepository _repository;

  AddInvestigationNoteUseCase(this._repository);

  Future<void> call({
    required String claimId,
    required String noteText,
    int? progressPercentSnapshot,
    required String accessToken,
  }) {
    return _repository.addNote(
      claimId: claimId,
      noteText: noteText,
      progressPercentSnapshot: progressPercentSnapshot,
      accessToken: accessToken,
    );
  }
}
