import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../services/user_service.dart'; // Pastikan path sudah sesuai

class UserProvider with ChangeNotifier {
  // Data user
  String guid = '';
  String email = '';
  String name = '';
  String fpid = '';
  String uuid = '';
  String? fullname;
  String nip = '';
  String? pangkat;
  String? jabatan;
  List<String> roles = [];
  Map<String, List<String>> ruang = {'pribadi': [], 'kerja': []};

  // Getter untuk profile
  Map<String, dynamic> get profile {
    return {
      'guid': guid,
      'email': email,
      'name': name,
      'fpid': fpid,
      'uuid': uuid,
      'fullname': fullname,
      'nip': nip,
      'pangkat': pangkat,
      'jabatan': jabatan,
      'roles': roles,
      'ruang': ruang,
    };
  }

  // Getter untuk username
  String get username {
    if (email == 'developer@bssn.go.id') {
      return 'bashir.arrohman';
    }
    if (email.contains('@')) {
      return email.substring(0, email.indexOf('@'));
    }
    return email;
  }

  bool get isSynchronized => email.isNotEmpty;

  // Mengambil data user dari API menggunakan UserService
  Future<void> synchronizeUser(String token) async {
    if (token.isEmpty) {
      print("Token kosong, user belum terautentikasi.");
      return;
    }
    try {
      final userService = UserService();
      final response = await userService.getUserData(token);
      print("Response /users/me: ${response.data}");

      final data = response.data['data'];
      guid = data['guid'] ?? '';
      email = data['email'] ?? '';
      name = data['name'] ?? '';
      fpid = data['fpid'] ?? '';
      uuid = data['uuid'] ?? '';
      // Jika tidak ada fullname, gunakan name sebagai fallback
      fullname = data['fullname'] ?? data['name'] ?? '';
      nip = data['nip'] ?? '';
      pangkat = data['pangkat'];
      jabatan = data['jabatan'];
      roles = List<String>.from(data['roles'] ?? []);

      final permissions = data['permissions'];
      ruang['pribadi'] = List<String>.from(permissions['ruang-pribadi'] ?? []);

      final ruangKerjaDynamic = permissions['ruang-kerja'];
      if (roles.contains('super.admin')) {
        List<String> kerja = [];
        if (ruangKerjaDynamic is Map) {
          ruangKerjaDynamic.forEach((key, value) {
            if (value is List) {
              kerja.addAll(List<String>.from(value));
            }
          });
        } else if (ruangKerjaDynamic is List) {
          kerja = List<String>.from(ruangKerjaDynamic);
        }
        ruang['kerja'] = kerja;
      } else {
        if (ruangKerjaDynamic is List) {
          ruang['kerja'] = List<String>.from(ruangKerjaDynamic);
        }
      }

      print("User fullname: $fullname");
      notifyListeners();
    } catch (e) {
      print("Error synchronizeUser: $e");
    }
  }
}
