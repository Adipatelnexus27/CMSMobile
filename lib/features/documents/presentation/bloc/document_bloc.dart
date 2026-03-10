import "package:flutter_bloc/flutter_bloc.dart";

import "../../domain/usecases/get_claim_documents_usecase.dart";
import "../../domain/usecases/upload_document_usecase.dart";
import "document_event.dart";
import "document_state.dart";

class DocumentBloc extends Bloc<DocumentEvent, DocumentState> {
  final GetClaimDocumentsUseCase _getClaimDocumentsUseCase;
  final UploadDocumentUseCase _uploadDocumentUseCase;

  DocumentBloc({
    required GetClaimDocumentsUseCase getClaimDocumentsUseCase,
    required UploadDocumentUseCase uploadDocumentUseCase,
  })  : _getClaimDocumentsUseCase = getClaimDocumentsUseCase,
        _uploadDocumentUseCase = uploadDocumentUseCase,
        super(const DocumentState.initial()) {
    on<DocumentListRequested>(_onListRequested);
    on<DocumentUploadRequested>(_onUploadRequested);
    on<DocumentMessageCleared>(_onMessageCleared);
  }

  Future<void> _onListRequested(DocumentListRequested event, Emitter<DocumentState> emit) async {
    emit(
      state.copyWith(
        status: DocumentStatus.loading,
        latestOnly: event.latestOnly,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      final documents = await _getClaimDocumentsUseCase(
        claimId: event.claimId,
        latestOnly: event.latestOnly,
        accessToken: event.accessToken,
      );

      emit(
        state.copyWith(
          status: DocumentStatus.ready,
          documents: documents,
          latestOnly: event.latestOnly,
          clearError: true,
          clearSuccess: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: DocumentStatus.failure,
          documents: const [],
          latestOnly: event.latestOnly,
          errorMessage: error.toString(),
          clearSuccess: true,
        ),
      );
    }
  }

  Future<void> _onUploadRequested(DocumentUploadRequested event, Emitter<DocumentState> emit) async {
    emit(state.copyWith(status: DocumentStatus.submitting, clearError: true, clearSuccess: true));

    try {
      await _uploadDocumentUseCase(
        claimId: event.claimId,
        filePath: event.filePath,
        fileName: event.fileName,
        documentCategory: event.documentCategory,
        documentGroupId: event.documentGroupId,
        accessToken: event.accessToken,
      );

      final documents = await _getClaimDocumentsUseCase(
        claimId: event.claimId,
        latestOnly: event.latestOnly,
        accessToken: event.accessToken,
      );

      emit(
        state.copyWith(
          status: DocumentStatus.ready,
          documents: documents,
          latestOnly: event.latestOnly,
          successMessage: "Document uploaded successfully.",
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: DocumentStatus.failure,
          errorMessage: error.toString(),
          clearSuccess: true,
        ),
      );
    }
  }

  void _onMessageCleared(DocumentMessageCleared event, Emitter<DocumentState> emit) {
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }
}
