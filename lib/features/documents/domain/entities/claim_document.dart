import "package:equatable/equatable.dart";

class ClaimDocument extends Equatable {
  final String claimDocumentId;
  final String claimId;
  final String originalFileName;
  final String documentCategory;
  final String contentType;
  final String documentGroupId;
  final int versionNumber;
  final bool isLatest;
  final DateTime uploadedAtUtc;

  const ClaimDocument({
    required this.claimDocumentId,
    required this.claimId,
    required this.originalFileName,
    required this.documentCategory,
    required this.contentType,
    required this.documentGroupId,
    required this.versionNumber,
    required this.isLatest,
    required this.uploadedAtUtc,
  });

  @override
  List<Object?> get props => [
        claimDocumentId,
        claimId,
        originalFileName,
        documentCategory,
        contentType,
        documentGroupId,
        versionNumber,
        isLatest,
        uploadedAtUtc,
      ];
}
