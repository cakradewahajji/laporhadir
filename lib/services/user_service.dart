import 'package:dio/dio.dart';
import 'api_config.dart';

class UserService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': ApiConfig.apiKey,
      },
    ),
  );

  // Memanggil endpoint /users/me untuk mendapatkan data user
  Future<Response> getUserData(String token) async {
    return _dio.get(
      '/users/me',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }
}
