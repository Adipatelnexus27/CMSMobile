import "../../domain/entities/claim_document.dart";
import "../../domain/repositories/document_repository.dart";
import "../datasources/document_remote_data_source.dart";

class DocumentRepositoryImpl implements DocumentRepository {
  final DocumentRemoteDataSource _remoteDataSource;

  DocumentRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<ClaimDocument>> getClaimDocuments({
    required String claimId,
    required bool latestOnly,
    required String accessToken,
  }) {
    return _remoteDataSource.getClaimDocuments(
      claimId: claimId,
      latestOnly: latestOnly,
      accessToken: accessToken,
    );
  }

  @override
  Future<void> uploadDocument({
    required String claimId,
    required String filePath,
    required String fileName,
    required String documentCategory,
    String? documentGroupId,
    required String accessToken,
  }) {
    return _remoteDataSource.uploadDocument(
      claimId: claimId,
      filePath: filePath,
      fileName: fileName,
      documentCategory: documentCategory,
      documentGroupId: documentGroupId,
      accessToken: accessToken,
    );
  }
}
