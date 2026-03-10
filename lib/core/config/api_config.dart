class ApiConfig {
  static const String baseApiUrl = String.fromEnvironment(
    "CMS_API_BASE_URL",
    defaultValue: "http://10.0.2.2:5000/api",
  );
}
