import "../../domain/entities/claim_document.dart";

class ClaimDocumentModel extends ClaimDocument {
  const ClaimDocumentModel({
    required super.claimDocumentId,
    required super.claimId,
    required super.originalFileName,
    required super.documentCategory,
    required super.contentType,
    required super.documentGroupId,
    required super.versionNumber,
    required super.isLatest,
    required super.uploadedAtUtc,
  });

  factory ClaimDocumentModel.fromJson(Map<String, dynamic> json) {
    return ClaimDocumentModel(
      claimDocumentId: json["claimDocumentId"]?.toString() ?? "",
      claimId: json["claimId"]?.toString() ?? "",
      originalFileName: json["originalFileName"]?.toString() ?? "",
      documentCategory: json["documentCategory"]?.toString() ?? "General",
      contentType: json["contentType"]?.toString() ?? "application/octet-stream",
      documentGroupId: json["documentGroupId"]?.toString() ?? "",
      versionNumber: _parseInt(json["versionNumber"]),
      isLatest: _parseBool(json["isLatest"]),
      uploadedAtUtc: _parseDate(json["uploadedAtUtc"]),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? "0") ?? 0;
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) {
      return value;
    }

    final text = value?.toString().toLowerCase();
    return text == "true" || text == "1";
  }

  static DateTime _parseDate(dynamic value) {
    final raw = value?.toString();
    if (raw == null || raw.trim().isEmpty) {
      return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    }

    return DateTime.tryParse(raw)?.toUtc() ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  }
}
