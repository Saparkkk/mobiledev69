import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthProvider extends ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool _isAuthenticated = false;
  bool _isLoading = true;
  String? _accessToken;
  String? _idToken;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get accessToken => _accessToken;
  String? get idToken => _idToken;

  AuthProvider() {
    checkAuthStatus();
  }

  /// 1. เช็ก Token จากเครื่องเมื่อเปิดแอปขึ้นมาครั้งแรก
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      _accessToken = await _storage.read(key: 'access_token');
      _idToken = await _storage.read(key: 'id_token');

      // ถ้ามี access_token แสดงว่าล็อกอินอยู่
      _isAuthenticated = _accessToken != null && _accessToken!.isNotEmpty;
    } catch (e) {
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners(); // แจ้ง Router ให้รับทราบสถานะปัจจุบัน
    }
  }

  /// 2. เรียกใช้เมื่อทำ OIDC Login สำเร็จ
  Future<void> saveTokens({
    required String accessToken,
    String? idToken,
  }) async {
    _accessToken = accessToken;
    _idToken = idToken;
    _isAuthenticated = true;

    // บันทึกลงเครื่องอย่างปลอดภัย
    await _storage.write(key: 'access_token', value: accessToken);
    if (idToken != null) {
      await _storage.write(key: 'id_token', value: idToken);
    }

    notifyListeners(); // 🟢 สั่งให้ GoRouter ทำการ Redirect เปลี่ยนหน้าจออัตโนมัติ
  }

  /// 3. เรียกใช้เมื่อต้องการออกจากระบบ (Logout)
  Future<void> logout() async {
  // 1. ลบ Token ใน flutter_secure_storage ของ Flutter
    await _storage.deleteAll();

    // 2. Redirect ไปทำลาย Session Cookie ฝั่ง Django Server
    // เมื่อ Django เคลียร์ Session เสร็จ จะ Redirect กลับมาที่หน้า Flutter (http://localhost:50000/)
    html.window.location.href = 'http://127.0.0.1:8000/api/logout/';
  }
}