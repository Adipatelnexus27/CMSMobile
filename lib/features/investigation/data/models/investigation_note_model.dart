import "../../domain/entities/investigation_note.dart";

class InvestigationNoteModel extends InvestigationNote {
  const InvestigationNoteModel({
    required super.claimInvestigationNoteId,
    required super.noteText,
    required super.progressPercentSnapshot,
    required super.createdByUserId,
    required super.createdAtUtc,
  });

  factory InvestigationNoteModel.fromJson(Map<String, dynamic> json) {
    return InvestigationNoteModel(
      claimInvestigationNoteId: json["claimInvestigationNoteId"]?.toString() ?? "",
      noteText: json["noteText"]?.toString() ?? "",
      progressPercentSnapshot: _parseIntNullable(json["progressPercentSnapshot"]),
      createdByUserId: json["createdByUserId"]?.toString(),
      createdAtUtc: _parseDate(json["createdAtUtc"]),
    );
  }

  static int? _parseIntNullable(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    return int.tryParse(value.toString());
  }

  static DateTime _parseDate(dynamic value) {
    final raw = value?.toString();
    if (raw == null || raw.trim().isEmpty) {
      return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    }

    return DateTime.tryParse(raw)?.toUtc() ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  }
}
