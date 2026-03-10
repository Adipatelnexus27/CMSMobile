import "../../domain/entities/assigned_claim.dart";

class AssignedClaimModel extends AssignedClaim {
  const AssignedClaimModel({
    required super.claimId,
    required super.claimNumber,
    required super.policyNumber,
    required super.claimType,
    required super.claimStatus,
    required super.priority,
    required super.workflowStep,
    required super.investigatorUserId,
    required super.adjusterUserId,
    required super.reporterName,
    required super.incidentDateUtc,
    required super.createdAtUtc,
    required super.investigationProgress,
  });

  factory AssignedClaimModel.fromJson(Map<String, dynamic> json) {
    return AssignedClaimModel(
      claimId: json["claimId"]?.toString() ?? "",
      claimNumber: json["claimNumber"]?.toString() ?? "",
      policyNumber: json["policyNumber"]?.toString() ?? "",
      claimType: json["claimType"]?.toString() ?? "",
      claimStatus: json["claimStatus"]?.toString() ?? "",
      priority: _parseInt(json["priority"]),
      workflowStep: json["workflowStep"]?.toString() ?? "",
      investigatorUserId: json["investigatorUserId"]?.toString(),
      adjusterUserId: json["adjusterUserId"]?.toString(),
      reporterName: json["reporterName"]?.toString() ?? "",
      incidentDateUtc: _parseDate(json["incidentDateUtc"]),
      createdAtUtc: _parseDate(json["createdAtUtc"]),
      investigationProgress: _parseInt(json["investigationProgress"]),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? "0") ?? 0;
  }

  static DateTime _parseDate(dynamic value) {
    final raw = value?.toString();
    if (raw == null || raw.trim().isEmpty) {
      return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    }

    return DateTime.tryParse(raw)?.toUtc() ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  }
}
