import "../../domain/entities/investigation_document.dart";

class InvestigationDocumentModel extends InvestigationDocument {
  const InvestigationDocumentModel({
    required super.claimDocumentId,
    required super.originalFileName,
    required super.documentCategory,
    required super.contentType,
    required super.uploadedAtUtc,
  });

  factory InvestigationDocumentModel.fromJson(Map<String, dynamic> json) {
    return InvestigationDocumentModel(
      claimDocumentId: json["claimDocumentId"]?.toString() ?? "",
      originalFileName: json["originalFileName"]?.toString() ?? "",
      documentCategory: json["documentCategory"]?.toString() ?? "General",
      contentType: json["contentType"]?.toString() ?? "application/octet-stream",
      uploadedAtUtc: _parseDate(json["uploadedAtUtc"]),
    );
  }

  static DateTime _parseDate(dynamic value) {
    final raw = value?.toString();
    if (raw == null || raw.trim().isEmpty) {
      return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    }

    return DateTime.tryParse(raw)?.toUtc() ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  }
}
