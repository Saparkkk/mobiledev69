import 'dart:convert';
import 'dart:html' as html; // สำหรับ Flutter Web
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:mobiledev69/core/auth/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  // ⚠️ 1. นำ Client ID และ Client SECRET มาใส่ที่นี่
  static const String clientId = '429588';
  static const String clientSecret = '32aad8a28cafa381c1ff1f2ce17e93ac6bececf0f4482056585da7ac';
  
  // ⚠️ 2. ต้องตรงกับ Redirect URIs ใน Django Admin
  static const String redirectUri = 'http://localhost:50000/callback';

  @override
  void initState() {
    super.initState();
    // เมื่อเปิดหน้าเว็บขึ้นมา ให้เช็กว่ามี Authorization Code แนบมาใน URL หรือไม่
    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkAuthorizationCode();
      });
    }
  }

  /// 🟢 ขั้นตอนที่ A: ดึง Authorization Code จาก URL
  Future<void> _checkAuthorizationCode() async {
    final Uri currentUrl = Uri.parse(html.window.location.href);
    final String? code = currentUrl.queryParameters['code'];

    if (code != null && code.isNotEmpty) {
      setState(() => _isLoading = true);
      await _exchangeCodeForToken(code);
    }
  }

  /// 🟢 ขั้นตอนที่ B: นำ Authorization Code ไปแลก OIDC Tokens
  Future<void> _exchangeCodeForToken(String code) async {
    try {
      final url = Uri.parse('http://127.0.0.1:8000/openid/token/');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'grant_type': 'authorization_code', // 🎯 แก้จุดนี้: ใช้ authorization_code ตามมาตรฐาน OIDC
          'code': code,
          'client_id': clientId,
          'client_secret': clientSecret,
          'redirect_uri': redirectUri,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final accessToken = data['access_token'];
        final idToken = data['id_token'];

        if (accessToken != null && mounted) {
          // ล้าง Parameter '?code=...' ออกจาก URL เพื่อความสะอาด
          html.window.history.replaceState({}, '', '/');

          // บันทึก Token ลง AuthProvider -> GoRouter จะเปลี่ยนหน้าหลักให้อัตโนมัติ
          await context.read<AuthProvider>().saveTokens(
                accessToken: accessToken,
                idToken: idToken,
              );
        }
      } else {
        throw Exception('แลก Token ไม่สำเร็จ: ${response.body}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาดในการรับ Token: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// 🟢 ขั้นตอนที่ C: กดปุ่มเพื่อ Redirect ไปยังหน้าล็อกอินของ Django OIDC
  void _loginWithOidc() {
    const baseUrl = 'http://127.0.0.1:8000';

    final authUrl = Uri.parse('$baseUrl/openid/authorize/').replace(
      queryParameters: {
        'response_type': 'code',
        'client_id': clientId,
        'redirect_uri': redirectUri,
        'scope': 'openid profile email',
        'prompt': 'login', // 🟢 เพิ่มบรรทัดนี้: บังคับ Django แสดงหน้า Login ใหม่เสมอ แม้มี Session ค้างอยู่
      },
    );

    html.window.location.href = authUrl.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.home_work, size: 80, color: Colors.blue),
              const SizedBox(height: 24),
              const Text(
                'เข้าสู่ระบบ (OIDC)',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              if (_isLoading)
                const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('กำลังยืนยันตัวตนกับระบบ OIDC...'),
                  ],
                )
              else
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.login),
                    label: const Text(
                      'เข้าสู่ระบบด้วย Django OIDC',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _loginWithOidc,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}