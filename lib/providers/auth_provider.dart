import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import 'package:dio/dio.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  Map<String, dynamic>? authentication;
  bool loading = false;
  String? message;
  String? error;
  List<dynamic> contacts = [];

  // Getter: apakah user sudah terautentikasi
  bool get isAuthenticated => authentication != null;
  // Token jika sudah ada autentikasi
  String get token => authentication?['access_token'] ?? '';

  // Misalnya, cek apakah ada kontak dengan tipe phone
  bool get hasPhoneNumber {
    return contacts.any((contact) => contact['type'] == 'phone');
  }

  // Muat data autentikasi dari local storage (misalnya menggunakan SharedPreferences)
  Future<void> mountLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final storedAuth = prefs.getString('authentication');
    if (storedAuth != null) {
      authentication = jsonDecode(utf8.decode(base64.decode(storedAuth)));
      // Jika menggunakan Dio interceptor atau service global,
      // Anda bisa set token di sana misalnya:
      // ApiService().setToken(token);
      notifyListeners();
    }
  }

  // Simpan autentikasi ke local storage
  Future<void> setAuthentication(Map<String, dynamic> authData) async {
    authentication = authData;
    final prefs = await SharedPreferences.getInstance();
    // Simpan sebagai base64 agar mirip dengan contoh Vue
    prefs.setString(
      'authentication',
      base64.encode(utf8.encode(jsonEncode(authData))),
    );
    notifyListeners();
  }

  // Reset state error/message
  void resetState() {
    error = null;
    message = null;
    notifyListeners();
  }

  // Method login
  Future<void> login(
    String email,
    String password,
    BuildContext context,
  ) async {
    loading = true;
    resetState();
    notifyListeners();

    try {
      final response = await _authService.login(email, password);
      // Jika API berhasil, simpan autentikasi
      await setAuthentication(response.data);
      // Cek status 2FA, jika perlu pindah ke screen OTP
      if (response.data['2fa_status'] == 'sent') {
        // Misalnya menggunakan Navigator untuk pindah ke OTP Screen
        Navigator.pushNamed(context, '/otp');
      } else {
        Navigator.pushNamed(context, '/dashboard');
      }
    } on DioError catch (e) {
      // Tangani error (misalnya error.response.data['error'] atau ['message'])
      error = e.response?.data['error'] ?? 'Login gagal';
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // Method verifikasi OTP
  Future<void> verify(String otp, BuildContext context) async {
    loading = true;
    resetState();
    notifyListeners();

    try {
      final response = await _authService.verify(otp, token);
      await setAuthentication(response.data);
      Navigator.pushNamed(context, '/dashboard');
    } on DioError catch (e) {
      error = e.response?.data['message'] ?? 'Verifikasi gagal';
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // Method resend OTP
  Future<void> resend() async {
    loading = true;
    resetState();
    notifyListeners();

    try {
      final response = await _authService.resend(token);
      message = response.data['message'];
    } on DioError catch (e) {
      error = e.response?.data['message'] ?? 'Gagal mengirim ulang OTP';
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
