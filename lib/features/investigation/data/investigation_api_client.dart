import "dart:convert";
import "dart:io";

import "package:file_picker/file_picker.dart";
import "package:http/http.dart" as http;

import "../../../core/config/api_config.dart";

class InvestigationApiClient {
  Future<Map<String, dynamic>> getInvestigation({
    required String claimId,
    required String accessToken,
  }) async {
    final uri = Uri.parse("${ApiConfig.baseApiUrl}/claims/$claimId/investigation");

    final response = await http.get(uri, headers: _jsonHeaders(accessToken));
    final body = _decodeBody(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractMessage(body, "Unable to load investigation."));
    }

    if (body is! Map<String, dynamic>) {
      throw Exception("Invalid investigation response format.");
    }

    return body;
  }

  Future<void> updateInvestigationProgress({
    required String claimId,
    required int progressPercent,
    required String accessToken,
  }) async {
    final uri = Uri.parse("${ApiConfig.baseApiUrl}/claims/$claimId/investigation/progress");

    final response = await http.put(
      uri,
      headers: _jsonHeaders(accessToken),
      body: jsonEncode({"progressPercent": progressPercent}),
    );

    final body = _decodeBody(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractMessage(body, "Unable to update investigation progress."));
    }
  }

  Future<void> addInvestigatorNote({
    required String claimId,
    required String noteText,
    int? progressPercentSnapshot,
    required String accessToken,
  }) async {
    final uri = Uri.parse("${ApiConfig.baseApiUrl}/claims/$claimId/investigation/notes");

    final payload = <String, dynamic>{
      "noteText": noteText,
      "progressPercentSnapshot": progressPercentSnapshot,
    };

    final response = await http.post(
      uri,
      headers: _jsonHeaders(accessToken),
      body: jsonEncode(payload),
    );

    final body = _decodeBody(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractMessage(body, "Unable to add investigator note."));
    }
  }

  Future<void> uploadInvestigationDocument({
    required String claimId,
    required PlatformFile file,
    required String documentCategory,
    required String accessToken,
  }) async {
    if (file.path == null || file.path!.trim().isEmpty) {
      throw Exception("Selected file path is missing.");
    }

    final uri = Uri.parse("${ApiConfig.baseApiUrl}/claims/$claimId/investigation/documents");

    final request = http.MultipartRequest("POST", uri);
    request.headers[HttpHeaders.authorizationHeader] = "Bearer $accessToken";
    request.fields["documentCategory"] = documentCategory;
    request.files.add(await http.MultipartFile.fromPath("file", file.path!, filename: file.name));

    final response = await request.send();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = await response.stream.bytesToString();
      final decoded = _decodeBody(body);
      throw Exception(_extractMessage(decoded, "Unable to upload investigation document."));
    }
  }

  Map<String, String> _jsonHeaders(String accessToken) {
    return <String, String>{
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: "Bearer $accessToken",
    };
  }

  dynamic _decodeBody(String body) {
    if (body.trim().isEmpty) {
      return null;
    }

    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }

  String _extractMessage(dynamic body, String fallback) {
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
}
