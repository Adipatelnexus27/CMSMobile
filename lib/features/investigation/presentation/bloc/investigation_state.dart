import "package:equatable/equatable.dart";

import "../../domain/entities/investigation_detail.dart";

enum InvestigationStatus { initial, loading, ready, submitting, failure }

class InvestigationState extends Equatable {
  final InvestigationStatus status;
  final InvestigationDetail? detail;
  final String? errorMessage;
  final String? successMessage;

  const InvestigationState({
    required this.status,
    this.detail,
    this.errorMessage,
    this.successMessage,
  });

  const InvestigationState.initial()
      : status = InvestigationStatus.initial,
        detail = null,
        errorMessage = null,
        successMessage = null;

  InvestigationState copyWith({
    InvestigationStatus? status,
    InvestigationDetail? detail,
    bool clearDetail = false,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
  }) {
    return InvestigationState(
      status: status ?? this.status,
      detail: clearDetail ? null : (detail ?? this.detail),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [status, detail, errorMessage, successMessage];
}
