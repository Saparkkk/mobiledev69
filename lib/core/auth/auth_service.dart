import 'dart:html' as html; // สำหรับ Flutter Web
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> logout() async {
    // 🟢 Step 1: ลบ Token ใน flutter_secure_storage
    await _storage.deleteAll();

    // 🟢 Step 2: Redirect ไปลบ Session Cookie ใน Django
    // เมื่อ Django ลบ Session เสร็จ จะ Redirect กลับมาที่หน้าเว็บ Flutter
    const String djangoLogoutUrl = 'http://127.0.0.1:8000/admin/logout/?next=http://localhost:50000/';
    html.window.location.href = djangoLogoutUrl;
  }
}