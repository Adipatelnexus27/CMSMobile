import "dart:convert";
import "dart:io";

import "package:http/http.dart" as http;

import "../../../core/config/api_config.dart";

class AssignedClaimApiClient {
  Future<List<Map<String, dynamic>>> getAssignedClaims({
    required String assigneeUserId,
    required String role,
    String? accessToken,
  }) async {
    final uri = Uri.parse(
      "${ApiConfig.baseApiUrl}/claims/assigned?assigneeUserId=${Uri.encodeQueryComponent(assigneeUserId)}&role=${Uri.encodeQueryComponent(role)}",
    );

    final response = await http.get(uri, headers: _jsonHeaders(accessToken));
    final body = _tryDecodeJson(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractErrorMessage(body, "Unable to load assigned claims."));
    }

    if (body is! List) {
      throw Exception("Assigned claims response format is invalid.");
    }

    return body
        .whereType<Map>()
        .map(
          (item) => item.map(
            (key, value) => MapEntry(key.toString(), value),
          ),
        )
        .toList(growable: false);
  }

  Future<void> updateClaimStatus({
    required String claimId,
    required String claimStatus,
    String? accessToken,
  }) async {
    final uri = Uri.parse("${ApiConfig.baseApiUrl}/claims/$claimId/status");

    final response = await http.put(
      uri,
      headers: _jsonHeaders(accessToken),
      body: jsonEncode({"claimStatus": claimStatus}),
    );

    final body = _tryDecodeJson(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractErrorMessage(body, "Unable to update claim status."));
    }
  }

  Future<void> updateWorkflowStep({
    required String claimId,
    required String workflowStep,
    String? accessToken,
  }) async {
    final uri = Uri.parse("${ApiConfig.baseApiUrl}/claims/$claimId/workflow-step");

    final response = await http.put(
      uri,
      headers: _jsonHeaders(accessToken),
      body: jsonEncode({"workflowStep": workflowStep}),
    );

    final body = _tryDecodeJson(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractErrorMessage(body, "Unable to update workflow step."));
    }
  }

  Map<String, String> _jsonHeaders(String? accessToken) {
    final headers = <String, String>{
      HttpHeaders.contentTypeHeader: "application/json",
    };

    if (accessToken != null && accessToken.trim().isNotEmpty) {
      headers[HttpHeaders.authorizationHeader] = "Bearer $accessToken";
    }

    return headers;
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
}
