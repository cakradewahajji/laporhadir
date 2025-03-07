import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get baseUrl {
    if (dotenv.isInitialized) {
      return dotenv.env['API_BASE_URL'] ?? 'https://api.bssn.go.id/';
    } else {
      return 'https://api.bssn.go.id/';
    }
  }

  static String get apiKey {
    if (dotenv.isInitialized) {
      return dotenv.env['API_KEY'] ?? '';
    } else {
      return '';
    }
  }
}
