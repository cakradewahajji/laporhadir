import 'package:dio/dio.dart';
import 'api_config.dart';

class KehadiranService {
  // Untuk staging, Anda bisa langsung tulis baseUrl: 'http://10.11.164.50/api'
  // atau gunakan ApiConfig jika Anda sudah punya
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.11.164.50/api', // Ganti sesuai staging / production
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': ApiConfig.apiKey,
      },
    ),
  );

  // GET data kehadiran
  Future<Response> getKehadiran(String token) async {
    return _dio.get(
      '/kehadiran',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }
}
