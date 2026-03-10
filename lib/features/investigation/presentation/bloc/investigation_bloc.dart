import "package:flutter_bloc/flutter_bloc.dart";

import "../../domain/usecases/add_investigation_note_usecase.dart";
import "../../domain/usecases/get_investigation_usecase.dart";
import "../../domain/usecases/update_investigation_progress_usecase.dart";
import "../../domain/usecases/upload_investigation_document_usecase.dart";
import "investigation_event.dart";
import "investigation_state.dart";

class InvestigationBloc extends Bloc<InvestigationEvent, InvestigationState> {
  final GetInvestigationUseCase _getInvestigationUseCase;
  final UpdateInvestigationProgressUseCase _updateProgressUseCase;
  final AddInvestigationNoteUseCase _addNoteUseCase;
  final UploadInvestigationDocumentUseCase _uploadDocumentUseCase;

  InvestigationBloc({
    required GetInvestigationUseCase getInvestigationUseCase,
    required UpdateInvestigationProgressUseCase updateProgressUseCase,
    required AddInvestigationNoteUseCase addNoteUseCase,
    required UploadInvestigationDocumentUseCase uploadDocumentUseCase,
  })  : _getInvestigationUseCase = getInvestigationUseCase,
        _updateProgressUseCase = updateProgressUseCase,
        _addNoteUseCase = addNoteUseCase,
        _uploadDocumentUseCase = uploadDocumentUseCase,
        super(const InvestigationState.initial()) {
    on<InvestigationLoaded>(_onLoaded);
    on<InvestigationProgressUpdated>(_onProgressUpdated);
    on<InvestigationNoteSubmitted>(_onNoteSubmitted);
    on<InvestigationDocumentUploaded>(_onDocumentUploaded);
    on<InvestigationMessageCleared>(_onMessageCleared);
  }

  Future<void> _onLoaded(InvestigationLoaded event, Emitter<InvestigationState> emit) async {
    emit(state.copyWith(status: InvestigationStatus.loading, clearError: true, clearSuccess: true));

    try {
      final detail = await _getInvestigationUseCase(
        claimId: event.claimId,
        accessToken: event.accessToken,
      );

      emit(
        state.copyWith(
          status: InvestigationStatus.ready,
          detail: detail,
          clearError: true,
          clearSuccess: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: InvestigationStatus.failure,
          errorMessage: error.toString(),
          clearSuccess: true,
        ),
      );
    }
  }

  Future<void> _onProgressUpdated(
    InvestigationProgressUpdated event,
    Emitter<InvestigationState> emit,
  ) async {
    emit(state.copyWith(status: InvestigationStatus.submitting, clearError: true, clearSuccess: true));

    try {
      await _updateProgressUseCase(
        claimId: event.claimId,
        progressPercent: event.progressPercent,
        accessToken: event.accessToken,
      );

      final detail = await _getInvestigationUseCase(
        claimId: event.claimId,
        accessToken: event.accessToken,
      );

      emit(
        state.copyWith(
          status: InvestigationStatus.ready,
          detail: detail,
          successMessage: "Investigation progress updated.",
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: InvestigationStatus.failure,
          errorMessage: error.toString(),
          clearSuccess: true,
        ),
      );
    }
  }

  Future<void> _onNoteSubmitted(
    InvestigationNoteSubmitted event,
    Emitter<InvestigationState> emit,
  ) async {
    emit(state.copyWith(status: InvestigationStatus.submitting, clearError: true, clearSuccess: true));

    try {
      await _addNoteUseCase(
        claimId: event.claimId,
        noteText: event.noteText,
        progressPercentSnapshot: event.progressPercentSnapshot,
        accessToken: event.accessToken,
      );

      final detail = await _getInvestigationUseCase(
        claimId: event.claimId,
        accessToken: event.accessToken,
      );

      emit(
        state.copyWith(
          status: InvestigationStatus.ready,
          detail: detail,
          successMessage: "Investigation note added.",
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: InvestigationStatus.failure,
          errorMessage: error.toString(),
          clearSuccess: true,
        ),
      );
    }
  }

  Future<void> _onDocumentUploaded(
    InvestigationDocumentUploaded event,
    Emitter<InvestigationState> emit,
  ) async {
    emit(state.copyWith(status: InvestigationStatus.submitting, clearError: true, clearSuccess: true));

    try {
      await _uploadDocumentUseCase(
        claimId: event.claimId,
        filePath: event.filePath,
        fileName: event.fileName,
        documentCategory: event.documentCategory,
        accessToken: event.accessToken,
      );

      final detail = await _getInvestigationUseCase(
        claimId: event.claimId,
        accessToken: event.accessToken,
      );

      emit(
        state.copyWith(
          status: InvestigationStatus.ready,
          detail: detail,
          successMessage: "Investigation document uploaded.",
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: InvestigationStatus.failure,
          errorMessage: error.toString(),
          clearSuccess: true,
        ),
      );
    }
  }

  void _onMessageCleared(InvestigationMessageCleared event, Emitter<InvestigationState> emit) {
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }
}
