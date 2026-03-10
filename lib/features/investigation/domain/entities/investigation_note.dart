import "package:equatable/equatable.dart";

class InvestigationNote extends Equatable {
  final String claimInvestigationNoteId;
  final String noteText;
  final int? progressPercentSnapshot;
  final String? createdByUserId;
  final DateTime createdAtUtc;

  const InvestigationNote({
    required this.claimInvestigationNoteId,
    required this.noteText,
    required this.progressPercentSnapshot,
    required this.createdByUserId,
    required this.createdAtUtc,
  });

  @override
  List<Object?> get props => [
        claimInvestigationNoteId,
        noteText,
        progressPercentSnapshot,
        createdByUserId,
        createdAtUtc,
      ];
}
