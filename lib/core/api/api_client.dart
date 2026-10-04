import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  final _storage = const FlutterSecureStorage();

  // กำหนด Base URL ศูนย์กลาง
  String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api'; 
    } else {
      return 'http://10.0.2.2:8000/api';
    }
  }

  // ตัวจัดการ Header และ Token อัตโนมัติ
  Future<Map<String, String>> getHeaders() async {
    final token = await _storage.read(key: 'access_token'); 
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token', 
    };
  }
}