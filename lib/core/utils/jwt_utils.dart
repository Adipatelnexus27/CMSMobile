import "dart:convert";

class JwtUtils {
  const JwtUtils._();

  static String? extractUserId(String token) {
    final parts = token.split(".");
    if (parts.length < 2) {
      return null;
    }

    try {
      final payload = String.fromCharCodes(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final map = jsonDecode(payload);
      if (map is! Map<String, dynamic>) {
        return null;
      }

      const userIdKeys = [
        "nameid",
        "sub",
        "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier"
      ];

      for (final key in userIdKeys) {
        final value = map[key];
        if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }
      }
    } catch (_) {
      return null;
    }

    return null;
  }
}
