/// Centralized API configuration for MindMirror.
///
/// Change [baseUrl] to toggle between local dev and Docker deployment.
class ApiConfig {
  /// Local development: FastAPI backend running on the host machine
  static const String baseUrl = 'https://jrlun.onrender.com';

  // Endpoint paths
  static const String entriesPath = '/api/v1/entries';
  static const String insightPath = '/api/v1/insights/current';
}
