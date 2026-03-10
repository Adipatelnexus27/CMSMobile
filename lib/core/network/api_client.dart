import "dart:convert";
import "dart:io";

import "package:http/http.dart" as http;

import "../errors/app_exception.dart";

class ApiClient {
  final String baseUrl;
  final http.Client _httpClient;

  ApiClient({
    required this.baseUrl,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  Uri buildUri(String path, [Map<String, String>? queryParameters]) {
    final normalizedPath = path.startsWith("/") ? path : "/$path";
    return Uri.parse("$baseUrl$normalizedPath").replace(queryParameters: queryParameters);
  }

  Map<String, String> jsonHeaders({String? accessToken}) {
    final headers = <String, String>{"Content-Type": "application/json"};
    if (accessToken != null && accessToken.trim().isNotEmpty) {
      headers["Authorization"] = "Bearer ${accessToken.trim()}";
    }

    return headers;
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    required Map<String, dynamic> payload,
    String? accessToken,
  }) async {
    final response = await _httpClient.post(
      buildUri(path),
      headers: jsonHeaders(accessToken: accessToken),
      body: jsonEncode(payload),
    );

    return _parseJsonMapResponse(response);
  }

  Future<Map<String, dynamic>> getJsonMap(
    String path, {
    Map<String, String>? query,
    String? accessToken,
  }) async {
    final response = await _httpClient.get(
      buildUri(path, query),
      headers: jsonHeaders(accessToken: accessToken),
    );

    return _parseJsonMapResponse(response);
  }

  Future<List<dynamic>> getJsonList(
    String path, {
    Map<String, String>? query,
    String? accessToken,
  }) async {
    final response = await _httpClient.get(
      buildUri(path, query),
      headers: jsonHeaders(accessToken: accessToken),
    );

    final decoded = _parseResponse(response);
    if (decoded is List<dynamic>) {
      return decoded;
    }

    throw const AppException("Unexpected response format.");
  }

  Future<void> postNoContent(
    String path, {
    required Map<String, dynamic> payload,
    String? accessToken,
  }) async {
    final response = await _httpClient.post(
      buildUri(path),
      headers: jsonHeaders(accessToken: accessToken),
      body: jsonEncode(payload),
    );

    _ensureSuccess(response);
  }

  Future<void> putNoContent(
    String path, {
    required Map<String, dynamic> payload,
    String? accessToken,
  }) async {
    final response = await _httpClient.put(
      buildUri(path),
      headers: jsonHeaders(accessToken: accessToken),
      body: jsonEncode(payload),
    );

    _ensureSuccess(response);
  }

  Future<Map<String, dynamic>> postMultipart(
    String path, {
    required String filePath,
    required String fileFieldName,
    String? fileName,
    Map<String, String> fields = const {},
    String? accessToken,
  }) async {
    final request = http.MultipartRequest("POST", buildUri(path));
    if (accessToken != null && accessToken.trim().isNotEmpty) {
      request.headers[HttpHeaders.authorizationHeader] = "Bearer ${accessToken.trim()}";
    }

    request.fields.addAll(fields);
    request.files.add(
      await http.MultipartFile.fromPath(
        fileFieldName,
        filePath,
        filename: fileName,
      ),
    );

    final streamedResponse = await request.send();
    final responseBody = await streamedResponse.stream.bytesToString();
    final materializedResponse = http.Response(
      responseBody,
      streamedResponse.statusCode,
      headers: streamedResponse.headers,
      request: streamedResponse.request,
    );

    return _parseJsonMapResponse(materializedResponse);
  }

  dynamic _parseResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AppException(_extractErrorMessage(response));
    }

    if (response.body.trim().isEmpty) {
      return null;
    }

    try {
      return jsonDecode(response.body);
    } catch (_) {
      throw const AppException("Unable to parse server response.");
    }
  }

  Map<String, dynamic> _parseJsonMapResponse(http.Response response) {
    final decoded = _parseResponse(response);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    throw const AppException("Unexpected response format.");
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    throw AppException(_extractErrorMessage(response));
  }

  String _extractErrorMessage(http.Response response) {
    if (response.body.trim().isEmpty) {
      return "Request failed with status ${response.statusCode}.";
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final message = decoded["message"];
        if (message is String && message.trim().isNotEmpty) {
          return message;
        }

        final title = decoded["title"];
        if (title is String && title.trim().isNotEmpty) {
          return title;
        }
      }
    } catch (_) {
      return response.body;
    }

    return "Request failed with status ${response.statusCode}.";
  }
}
