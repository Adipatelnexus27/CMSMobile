import "../../domain/entities/auth_session.dart";

class AuthSessionModel extends AuthSession {
  const AuthSessionModel({
    required super.accessToken,
    required super.refreshToken,
    required super.accessTokenExpiresAtUtc,
    required super.refreshTokenExpiresAtUtc,
    required super.email,
    required super.fullName,
    required super.roles,
    required super.permissions,
  });

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    return AuthSessionModel(
      accessToken: json["accessToken"]?.toString() ?? "",
      refreshToken: json["refreshToken"]?.toString() ?? "",
      accessTokenExpiresAtUtc: DateTime.parse(
        json["accessTokenExpiresAtUtc"]?.toString() ?? DateTime.now().toUtc().toIso8601String(),
      ).toUtc(),
      refreshTokenExpiresAtUtc: DateTime.parse(
        json["refreshTokenExpiresAtUtc"]?.toString() ?? DateTime.now().toUtc().toIso8601String(),
      ).toUtc(),
      email: json["email"]?.toString() ?? "",
      fullName: json["fullName"]?.toString() ?? "",
      roles: (json["roles"] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
      permissions: (json["permissions"] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "accessToken": accessToken,
      "refreshToken": refreshToken,
      "accessTokenExpiresAtUtc": accessTokenExpiresAtUtc.toUtc().toIso8601String(),
      "refreshTokenExpiresAtUtc": refreshTokenExpiresAtUtc.toUtc().toIso8601String(),
      "email": email,
      "fullName": fullName,
      "roles": roles,
      "permissions": permissions,
    };
  }
}
