import "dart:convert";
import "dart:io";

import "package:file_picker/file_picker.dart";
import "package:http/http.dart" as http;

import "../../../core/config/api_config.dart";

class ClaimApiClient {
  Future<Map<String, dynamic>> registerClaim({
    required String policyNumber,
    required String claimType,
    required String reporterName,
    required DateTime incidentDateUtc,
    required String incidentLocation,
    required String incidentDescription,
    List<String> relatedClaimIds = const [],
    String? accessToken,
  }) async {
    final uri = Uri.parse("${ApiConfig.baseApiUrl}/claims/register");

    final response = await http.post(
      uri,
      headers: _jsonHeaders(accessToken),
      body: jsonEncode({
        "policyNumber": policyNumber,
        "claimType": claimType,
        "reporterName": reporterName,
        "incidentDateUtc": incidentDateUtc.toUtc().toIso8601String(),
        "incidentLocation": incidentLocation,
        "incidentDescription": incidentDescription,
        "relatedClaimIds": relatedClaimIds,
      }),
    );

    final Map<String, dynamic> body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(body["message"] ?? "Claim registration failed.");
    }

    return body;
  }

  Future<void> uploadDocument({
    required String claimId,
    required PlatformFile file,
    String? accessToken,
  }) async {
    final uri = Uri.parse("${ApiConfig.baseApiUrl}/claims/$claimId/documents");

    final request = http.MultipartRequest("POST", uri);
    if (accessToken != null && accessToken.trim().isNotEmpty) {
      request.headers[HttpHeaders.authorizationHeader] = "Bearer $accessToken";
    }

    if (file.path == null) {
      throw Exception("File path is missing for selected document.");
    }

    request.files.add(await http.MultipartFile.fromPath("file", file.path!, filename: file.name));

    final streamedResponse = await request.send();
    if (streamedResponse.statusCode < 200 || streamedResponse.statusCode >= 300) {
      final responseText = await streamedResponse.stream.bytesToString();
      throw Exception(responseText.isNotEmpty ? responseText : "Document upload failed.");
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
}
