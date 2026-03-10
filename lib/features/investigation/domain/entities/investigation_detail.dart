import "package:equatable/equatable.dart";

import "investigation_document.dart";
import "investigation_note.dart";

class InvestigationDetail extends Equatable {
  final String claimId;
  final String claimNumber;
  final String claimStatus;
  final int investigationProgress;
  final List<InvestigationDocument> documents;
  final List<InvestigationNote> notes;

  const InvestigationDetail({
    required this.claimId,
    required this.claimNumber,
    required this.claimStatus,
    required this.investigationProgress,
    required this.documents,
    required this.notes,
  });

  @override
  List<Object?> get props => [
        claimId,
        claimNumber,
        claimStatus,
        investigationProgress,
        documents,
        notes,
      ];
}
