import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get baseUrl {
    if (dotenv.isInitialized) {
      return dotenv.env['API_BASE_URL'] ?? 'https://fallback.com';
    } else {
      return 'https://fallback.com';
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
