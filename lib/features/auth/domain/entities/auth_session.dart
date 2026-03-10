import "package:equatable/equatable.dart";

class AuthSession extends Equatable {
  final String accessToken;
  final String refreshToken;
  final DateTime accessTokenExpiresAtUtc;
  final DateTime refreshTokenExpiresAtUtc;
  final String email;
  final String fullName;
  final List<String> roles;
  final List<String> permissions;

  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiresAtUtc,
    required this.refreshTokenExpiresAtUtc,
    required this.email,
    required this.fullName,
    required this.roles,
    required this.permissions,
  });

  @override
  List<Object?> get props => [
        accessToken,
        refreshToken,
        accessTokenExpiresAtUtc,
        refreshTokenExpiresAtUtc,
        email,
        fullName,
        roles,
        permissions,
      ];
}
