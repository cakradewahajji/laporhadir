import 'package:dio/dio.dart';
import 'api_config.dart';

class MasterApiService {
  static final Dio _dio = Dio();

  static Future<List<dynamic>> getMasterData() async {
    final String url = '${ApiConfig.baseUrl}/master-data';
    try {
      final response = await _dio.get(url);
      // Jika response berhasil, response.data biasanya sudah ter-decode
      if (response.statusCode == 200) {
        // Asumsikan response.data adalah list
        return response.data as List<dynamic>;
      } else {
        throw Exception(
          'Gagal memuat data master. Code: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow; // lempar lagi error supaya bisa ditangani di tempat pemanggilan
    }
  }
}
