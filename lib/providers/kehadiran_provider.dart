import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../services/kehadiran_service.dart';
import '../models/kehadiran_model.dart';

class KehadiranProvider with ChangeNotifier {
  List<KehadiranModel> kehadiranList = [];
  bool loading = false;
  String? errorMessage;

  Future<void> fetchKehadiran(String token) async {
    loading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await KehadiranService().getKehadiran(token);
      // Revisi: Periksa apakah response.data berupa Map, kemudian ambil list dari key "result"
      final Map<String, dynamic> responseMap = response.data;
      final List<dynamic> dataList = responseMap["result"] ?? [];
      kehadiranList =
          dataList.map((json) => KehadiranModel.fromJson(json)).toList();
      print("Berhasil memuat data kehadiran, total: ${kehadiranList.length}");
    } on DioError catch (e) {
      errorMessage =
          e.response?.data.toString() ?? 'Gagal memuat data kehadiran';
      print("fetchKehadiran DioError: $errorMessage");
    } catch (e) {
      errorMessage = e.toString();
      print("fetchKehadiran Error: $errorMessage");
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
