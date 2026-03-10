import "package:equatable/equatable.dart";

abstract class AssignedClaimsEvent extends Equatable {
  const AssignedClaimsEvent();

  @override
  List<Object?> get props => const [];
}

class AssignedClaimsRequested extends AssignedClaimsEvent {
  final String accessToken;
  final String role;

  const AssignedClaimsRequested({required this.accessToken, required this.role});

  @override
  List<Object?> get props => [accessToken, role];
}
