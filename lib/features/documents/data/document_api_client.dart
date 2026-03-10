import "dart:convert";
import "dart:io";
import "dart:typed_data";

import "package:file_picker/file_picker.dart";
import "package:http/http.dart" as http;

import "../../../core/config/api_config.dart";

class DocumentPreviewResponse {
  final Uint8List bytes;
  final String contentType;
  final String fileName;

  const DocumentPreviewResponse({
    required this.bytes,
    required this.contentType,
    required this.fileName,
  });
}

class DocumentApiClient {
  Future<List<Map<String, dynamic>>> getClaimDocuments({
    required String claimId,
    required bool latestOnly,
    required String accessToken,
  }) async {
    final uri = Uri.parse(
      "${ApiConfig.baseApiUrl}/documents/claims/$claimId?latestOnly=$latestOnly",
    );

    final response = await http.get(uri, headers: _jsonHeaders(accessToken));
    final body = _tryDecodeJson(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractErrorMessage(body, "Unable to load documents."));
    }

    if (body is! List) {
      throw Exception("Document response format is invalid.");
    }

    return body
        .whereType<Map>()
        .map((item) => item.map((key, value) => MapEntry(key.toString(), value)))
        .toList(growable: false);
  }

  Future<List<Map<String, dynamic>>> getDocumentVersions({
    required String claimDocumentId,
    required String accessToken,
  }) async {
    final uri = Uri.parse("${ApiConfig.baseApiUrl}/documents/$claimDocumentId/versions");

    final response = await http.get(uri, headers: _jsonHeaders(accessToken));
    final body = _tryDecodeJson(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractErrorMessage(body, "Unable to load document versions."));
    }

    if (body is! List) {
      throw Exception("Document versions response format is invalid.");
    }

    return body
        .whereType<Map>()
        .map((item) => item.map((key, value) => MapEntry(key.toString(), value)))
        .toList(growable: false);
  }

  Future<void> uploadDocument({
    required String claimId,
    required PlatformFile file,
    required String documentCategory,
    String? documentGroupId,
    required String accessToken,
  }) async {
    if (file.path == null || file.path!.trim().isEmpty) {
      throw Exception("Selected file path is missing.");
    }

    final uri = Uri.parse("${ApiConfig.baseApiUrl}/documents/claims/$claimId/upload");

    final request = http.MultipartRequest("POST", uri);
    request.headers[HttpHeaders.authorizationHeader] = "Bearer $accessToken";
    request.fields["documentCategory"] = documentCategory;
    if (documentGroupId != null && documentGroupId.trim().isNotEmpty) {
      request.fields["documentGroupId"] = documentGroupId.trim();
    }
    request.files.add(await http.MultipartFile.fromPath("file", file.path!, filename: file.name));

    final response = await request.send();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = await response.stream.bytesToString();
      final decoded = _tryDecodeJson(body);
      throw Exception(_extractErrorMessage(decoded, "Unable to upload document."));
    }
  }

  Future<DocumentPreviewResponse> previewDocument({
    required String claimDocumentId,
    required String accessToken,
  }) async {
    final uri = Uri.parse("${ApiConfig.baseApiUrl}/documents/$claimDocumentId/preview");

    final response = await http.get(
      uri,
      headers: {HttpHeaders.authorizationHeader: "Bearer $accessToken"},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final decoded = _tryDecodeJson(response.body);
      throw Exception(_extractErrorMessage(decoded, "Unable to preview document."));
    }

    final contentType = response.headers[HttpHeaders.contentTypeHeader] ?? "application/octet-stream";
    final disposition = response.headers["content-disposition"] ?? "";
    final fileName = _extractFileName(disposition) ?? "document-preview";

    return DocumentPreviewResponse(
      bytes: response.bodyBytes,
      contentType: contentType,
      fileName: fileName,
    );
  }

  Map<String, String> _jsonHeaders(String accessToken) {
    return <String, String>{
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: "Bearer $accessToken",
    };
  }

  dynamic _tryDecodeJson(String body) {
    if (body.trim().isEmpty) {
      return null;
    }

    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }

  String _extractErrorMessage(dynamic body, String fallback) {
    if (body is Map<String, dynamic>) {
      final message = body["message"];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }

      final title = body["title"];
      if (title is String && title.trim().isNotEmpty) {
        return title;
      }
    }

    return fallback;
  }

  String? _extractFileName(String dispositionHeader) {
    final regex = RegExp(r'filename=\"?([^\";]+)\"?', caseSensitive: false);
    final match = regex.firstMatch(dispositionHeader);
    return match?.group(1);
  }
}
