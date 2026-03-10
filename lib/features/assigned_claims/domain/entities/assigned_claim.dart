import "package:equatable/equatable.dart";

class AssignedClaim extends Equatable {
  final String claimId;
  final String claimNumber;
  final String policyNumber;
  final String claimType;
  final String claimStatus;
  final int priority;
  final String workflowStep;
  final String? investigatorUserId;
  final String? adjusterUserId;
  final String reporterName;
  final DateTime incidentDateUtc;
  final DateTime createdAtUtc;
  final int investigationProgress;

  const AssignedClaim({
    required this.claimId,
    required this.claimNumber,
    required this.policyNumber,
    required this.claimType,
    required this.claimStatus,
    required this.priority,
    required this.workflowStep,
    required this.investigatorUserId,
    required this.adjusterUserId,
    required this.reporterName,
    required this.incidentDateUtc,
    required this.createdAtUtc,
    required this.investigationProgress,
  });

  @override
  List<Object?> get props => [
        claimId,
        claimNumber,
        policyNumber,
        claimType,
        claimStatus,
        priority,
        workflowStep,
        investigatorUserId,
        adjusterUserId,
        reporterName,
        incidentDateUtc,
        createdAtUtc,
        investigationProgress,
      ];
}
