import "package:flutter_bloc/flutter_bloc.dart";

import "../../domain/usecases/get_assigned_claims_usecase.dart";
import "assigned_claims_event.dart";
import "assigned_claims_state.dart";

class AssignedClaimsBloc extends Bloc<AssignedClaimsEvent, AssignedClaimsState> {
  final GetAssignedClaimsUseCase _getAssignedClaimsUseCase;

  AssignedClaimsBloc(this._getAssignedClaimsUseCase) : super(const AssignedClaimsState.initial()) {
    on<AssignedClaimsRequested>(_onAssignedClaimsRequested);
  }

  Future<void> _onAssignedClaimsRequested(
    AssignedClaimsRequested event,
    Emitter<AssignedClaimsState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AssignedClaimsStatus.loading,
        role: event.role,
        clearError: true,
      ),
    );

    try {
      final claims = await _getAssignedClaimsUseCase(
        accessToken: event.accessToken,
        role: event.role,
      );

      emit(
        state.copyWith(
          status: AssignedClaimsStatus.success,
          claims: claims,
          role: event.role,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AssignedClaimsStatus.failure,
          claims: const [],
          role: event.role,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
