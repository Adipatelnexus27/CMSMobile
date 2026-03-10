import "../../domain/entities/investigation_detail.dart";
import "../../domain/repositories/investigation_repository.dart";
import "../datasources/investigation_remote_data_source.dart";

class InvestigationRepositoryImpl implements InvestigationRepository {
  final InvestigationRemoteDataSource _remoteDataSource;

  InvestigationRepositoryImpl(this._remoteDataSource);

  @override
  Future<InvestigationDetail> getInvestigation({
    required String claimId,
    required String accessToken,
  }) {
    return _remoteDataSource.getInvestigation(claimId: claimId, accessToken: accessToken);
  }

  @override
  Future<void> updateProgress({
    required String claimId,
    required int progressPercent,
    required String accessToken,
  }) {
    return _remoteDataSource.updateProgress(
      claimId: claimId,
      progressPercent: progressPercent,
      accessToken: accessToken,
    );
  }

  @override
  Future<void> addNote({
    required String claimId,
    required String noteText,
    int? progressPercentSnapshot,
    required String accessToken,
  }) {
    return _remoteDataSource.addNote(
      claimId: claimId,
      noteText: noteText,
      progressPercentSnapshot: progressPercentSnapshot,
      accessToken: accessToken,
    );
  }

  @override
  Future<void> uploadDocument({
    required String claimId,
    required String filePath,
    required String fileName,
    required String documentCategory,
    required String accessToken,
  }) {
    return _remoteDataSource.uploadDocument(
      claimId: claimId,
      filePath: filePath,
      fileName: fileName,
      documentCategory: documentCategory,
      accessToken: accessToken,
    );
  }
}
