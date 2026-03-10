import "dart:convert";

import "package:shared_preferences/shared_preferences.dart";

class SessionStorage {
  static const _sessionKey = "cms_mobile_auth_session";

  Future<void> saveSession(Map<String, dynamic> json) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_sessionKey, jsonEncode(json));
  }

  Future<Map<String, dynamic>?> loadSession() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_sessionKey);
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  Future<void> clearSession() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_sessionKey);
  }
}
