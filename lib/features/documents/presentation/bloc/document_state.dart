import "package:equatable/equatable.dart";

import "../../domain/entities/claim_document.dart";

enum DocumentStatus { initial, loading, ready, submitting, failure }

class DocumentState extends Equatable {
  final DocumentStatus status;
  final List<ClaimDocument> documents;
  final String? errorMessage;
  final String? successMessage;
  final bool latestOnly;

  const DocumentState({
    required this.status,
    required this.documents,
    required this.latestOnly,
    this.errorMessage,
    this.successMessage,
  });

  const DocumentState.initial()
      : status = DocumentStatus.initial,
        documents = const [],
        latestOnly = true,
        errorMessage = null,
        successMessage = null;

  DocumentState copyWith({
    DocumentStatus? status,
    List<ClaimDocument>? documents,
    bool? latestOnly,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
  }) {
    return DocumentState(
      status: status ?? this.status,
      documents: documents ?? this.documents,
      latestOnly: latestOnly ?? this.latestOnly,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [status, documents, latestOnly, errorMessage, successMessage];
}
