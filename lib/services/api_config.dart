import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'https://fallback.com';
  static String get masterUrl =>
      dotenv.env['MASTER_API_URL'] ?? 'https://fallback.com';
  static String get apiKey => dotenv.env['API_KEY'] ?? '';
}
