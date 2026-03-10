import "package:equatable/equatable.dart";

class InvestigationDocument extends Equatable {
  final String claimDocumentId;
  final String originalFileName;
  final String documentCategory;
  final String contentType;
  final DateTime uploadedAtUtc;

  const InvestigationDocument({
    required this.claimDocumentId,
    required this.originalFileName,
    required this.documentCategory,
    required this.contentType,
    required this.uploadedAtUtc,
  });

  @override
  List<Object?> get props => [
        claimDocumentId,
        originalFileName,
        documentCategory,
        contentType,
        uploadedAtUtc,
      ];
}
