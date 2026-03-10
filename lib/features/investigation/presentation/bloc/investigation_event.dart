import "package:equatable/equatable.dart";

abstract class InvestigationEvent extends Equatable {
  const InvestigationEvent();

  @override
  List<Object?> get props => const [];
}

class InvestigationLoaded extends InvestigationEvent {
  final String claimId;
  final String accessToken;

  const InvestigationLoaded({required this.claimId, required this.accessToken});

  @override
  List<Object?> get props => [claimId, accessToken];
}

class InvestigationProgressUpdated extends InvestigationEvent {
  final String claimId;
  final int progressPercent;
  final String accessToken;

  const InvestigationProgressUpdated({
    required this.claimId,
    required this.progressPercent,
    required this.accessToken,
  });

  @override
  List<Object?> get props => [claimId, progressPercent, accessToken];
}

class InvestigationNoteSubmitted extends InvestigationEvent {
  final String claimId;
  final String noteText;
  final int? progressPercentSnapshot;
  final String accessToken;

  const InvestigationNoteSubmitted({
    required this.claimId,
    required this.noteText,
    required this.progressPercentSnapshot,
    required this.accessToken,
  });

  @override
  List<Object?> get props => [claimId, noteText, progressPercentSnapshot, accessToken];
}

class InvestigationDocumentUploaded extends InvestigationEvent {
  final String claimId;
  final String filePath;
  final String fileName;
  final String documentCategory;
  final String accessToken;

  const InvestigationDocumentUploaded({
    required this.claimId,
    required this.filePath,
    required this.fileName,
    required this.documentCategory,
    required this.accessToken,
  });

  @override
  List<Object?> get props => [claimId, filePath, fileName, documentCategory, accessToken];
}

class InvestigationMessageCleared extends InvestigationEvent {
  const InvestigationMessageCleared();
}
