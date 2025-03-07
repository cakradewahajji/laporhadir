import 'package:dio/dio.dart';
import 'api_config.dart';

class AuthService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': ApiConfig.apiKey,
      },
    ),
  );

  Future<Response> login(String email, String password) async {
    // Jika email tidak mengandung @, tambahkan domain default
    if (!email.contains('@')) {
      email = '$email@bssn.go.id';
    }
    final credentials = {'email': email, 'password': password};
    return _dio.post('/auth/login', data: credentials);
  }

  Future<Response> verify(String otp, String token) async {
    final otpToken = {'otp': otp};
    return _dio.post(
      '/auth/verify',
      data: otpToken,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<Response> resend(String token) async {
    return _dio.get(
      '/auth/resend',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }
}
