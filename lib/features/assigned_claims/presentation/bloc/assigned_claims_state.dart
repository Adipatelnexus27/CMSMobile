import "package:equatable/equatable.dart";

import "../../domain/entities/assigned_claim.dart";

enum AssignedClaimsStatus { initial, loading, success, failure }

class AssignedClaimsState extends Equatable {
  final AssignedClaimsStatus status;
  final List<AssignedClaim> claims;
  final String role;
  final String? errorMessage;

  const AssignedClaimsState({
    required this.status,
    required this.claims,
    required this.role,
    this.errorMessage,
  });

  const AssignedClaimsState.initial()
      : status = AssignedClaimsStatus.initial,
        claims = const [],
        role = "Investigator",
        errorMessage = null;

  AssignedClaimsState copyWith({
    AssignedClaimsStatus? status,
    List<AssignedClaim>? claims,
    String? role,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AssignedClaimsState(
      status: status ?? this.status,
      claims: claims ?? this.claims,
      role: role ?? this.role,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, claims, role, errorMessage];
}
