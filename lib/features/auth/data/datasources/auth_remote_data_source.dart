import "../../../../core/network/api_client.dart";
import "../models/auth_session_model.dart";

class AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSource(this._apiClient);

  Future<AuthSessionModel> login({required String email, required String password}) async {
    final response = await _apiClient.postJson(
      "/auth/login",
      payload: {
        "email": email,
        "password": password,
      },
    );

    return AuthSessionModel.fromJson(response);
  }
}
