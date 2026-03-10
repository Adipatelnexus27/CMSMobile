import "package:equatable/equatable.dart";

abstract class DocumentEvent extends Equatable {
  const DocumentEvent();

  @override
  List<Object?> get props => const [];
}

class DocumentListRequested extends DocumentEvent {
  final String claimId;
  final bool latestOnly;
  final String accessToken;

  const DocumentListRequested({
    required this.claimId,
    required this.latestOnly,
    required this.accessToken,
  });

  @override
  List<Object?> get props => [claimId, latestOnly, accessToken];
}

class DocumentUploadRequested extends DocumentEvent {
  final String claimId;
  final bool latestOnly;
  final String filePath;
  final String fileName;
  final String documentCategory;
  final String? documentGroupId;
  final String accessToken;

  const DocumentUploadRequested({
    required this.claimId,
    required this.latestOnly,
    required this.filePath,
    required this.fileName,
    required this.documentCategory,
    required this.documentGroupId,
    required this.accessToken,
  });

  @override
  List<Object?> get props => [
        claimId,
        latestOnly,
        filePath,
        fileName,
        documentCategory,
        documentGroupId,
        accessToken,
      ];
}

class DocumentMessageCleared extends DocumentEvent {
  const DocumentMessageCleared();
}
