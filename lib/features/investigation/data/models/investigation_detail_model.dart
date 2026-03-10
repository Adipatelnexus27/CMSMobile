import "../../domain/entities/investigation_detail.dart";
import "investigation_document_model.dart";
import "investigation_note_model.dart";

class InvestigationDetailModel extends InvestigationDetail {
  const InvestigationDetailModel({
    required super.claimId,
    required super.claimNumber,
    required super.claimStatus,
    required super.investigationProgress,
    required super.documents,
    required super.notes,
  });

  factory InvestigationDetailModel.fromJson(Map<String, dynamic> json) {
    return InvestigationDetailModel(
      claimId: json["claimId"]?.toString() ?? "",
      claimNumber: json["claimNumber"]?.toString() ?? "",
      claimStatus: json["claimStatus"]?.toString() ?? "",
      investigationProgress: _parseInt(json["investigationProgress"]),
      documents: (json["documents"] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(InvestigationDocumentModel.fromJson)
          .toList(growable: false),
      notes: (json["notes"] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(InvestigationNoteModel.fromJson)
          .toList(growable: false),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? "0") ?? 0;
  }
}
