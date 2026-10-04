import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dartz/dartz.dart';
import '../../domain/contracts/house_repository.dart';
import '../../domain/models/house_model.dart';
import '../../domain/models/appointment_model.dart';
import 'package:flutter/foundation.dart';

// 🟢 1. Import flutter_secure_storage สำหรับดึง Token
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HouseRepositoryImpl implements HouseRepository {
  // 🟢 2. ประกาศตัวแปร storage ไว้ดึงข้อมูล
  final _storage = const FlutterSecureStorage();

  String get _baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api'; 
    } else {
      return 'http://10.0.2.2:8000/api';
    }
  }

  // 🟢 3. สร้างฟังก์ชันตัวช่วยสำหรับเตรียม Headers และดึง Token อัตโนมัติ
  Future<Map<String, String>> _getHeaders() async {
    // อ่าน Token จากเครื่อง (ต้องใช้คีย์ 'access_token' ให้ตรงกับตอนล็อกอิน)
    final token = await _storage.read(key: 'access_token'); 

    print('🔑 Token ในเครื่องตอนนี้คือ: $token');
    
    return {
      'Content-Type': 'application/json',
      // ถ้ามี Token อยู่ในเครื่อง ให้แนบไปด้วย
      if (token != null) 'Authorization': 'Bearer $token', 
    };
  }

  @override
  Future<Either<String, List<HouseModel>>> getHouses() async {
    final String apiUrl = '$_baseUrl/houses/';

    try {
      // 🟢 4. ใส่ headers: await _getHeaders() ในคำสั่ง http.get
      final response = await http.get(
        Uri.parse(apiUrl), 
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
        final List<HouseModel> houses = jsonList.map((json) => HouseModel(
          id: json['id'].toString(),
          name: json['name'],
          style: json['style'],
          startingPrice: json['starting_price'].toDouble(),
          contractorName: json['contractor_name'],
          imageUrl: json['image_url'],
          description: json['description'],
        )).toList();
        return Right(houses);
      } else {
        return Left('ดึงข้อมูลไม่สำเร็จ (Error: ${response.statusCode})');
      }
    } catch (e) {
      return Left('ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้: $e');
    }
  }

  Future<Either<String, List<AppointmentModel>>> getAppointments() async {
    try {
      // 🟢 4. ใส่ headers ด้วย
      final response = await http.get(
        Uri.parse('$_baseUrl/appointments/'),
        headers: await _getHeaders(),
      );
      
      print('Fetch Status Code: ${response.statusCode}');
      print('Fetch Response: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
        final List<AppointmentModel> appointments = jsonList.map((json) => AppointmentModel(
          id: json['id'].toString(),
          houseName: json['houseName'] ?? json['house_name'] ?? '',
          date: json['date'] ?? '',
          phone: json['phone'] ?? '',
        )).toList();
        return Right(appointments);
      }
      
      return Left('ดึงข้อมูลไม่สำเร็จ (Error Code: ${response.statusCode})');
    } catch (e) {
      return Left('เน็ตหลุด หรือติดต่อเซิร์ฟเวอร์ไม่ได้');
    }
  }

  Future<Either<String, void>> createAppointment(AppointmentModel appt) async {
    try {
      // 🟢 4. เปลี่ยนมาใช้ _getHeaders() 
      final response = await http.post(
        Uri.parse('$_baseUrl/appointments/'),
        headers: await _getHeaders(),
        body: jsonEncode(appt.toJson()),
      );
      if (response.statusCode == 201 || response.statusCode == 200) return const Right(null);
      return Left('บันทึกข้อมูลไม่สำเร็จ (Error: ${response.statusCode})');
    } catch (e) {
      return Left('เน็ตหลุด หรือติดต่อเซิร์ฟเวอร์ไม่ได้');
    }
  }

  Future<Either<String, void>> updateAppointment(String id, AppointmentModel appt) async {
    try {
      // 🟢 4. เปลี่ยนมาใช้ _getHeaders() 
      final response = await http.put(
        Uri.parse('$_baseUrl/appointments/$id/'),
        headers: await _getHeaders(),
        body: jsonEncode(appt.toJson()),
      );
      if (response.statusCode == 200) return const Right(null);
      return Left('แก้ไขข้อมูลไม่สำเร็จ');
    } catch (e) {
      return Left('เน็ตหลุด หรือติดต่อเซิร์ฟเวอร์ไม่ได้');
    }
  }

  Future<Either<String, void>> deleteAppointment(String id) async {
    try {
      final url = Uri.parse('$_baseUrl/appointments/$id/');
      // 🟢 4. เปลี่ยนมาใช้ _getHeaders() 
      final response = await http.delete(
        url,
        headers: await _getHeaders(),
      );

      print('Delete URL: $url');
      print('Delete Status Code: ${response.statusCode}');

      if (response.statusCode == 204 || response.statusCode == 200) {
        return const Right(null);
      }
      return Left('ลบไม่สำเร็จ (Error Code: ${response.statusCode})');
      
    } catch (e) {
      return Left('เน็ตหลุด หรือติดต่อเซิร์ฟเวอร์ไม่ได้');
    }
  }
}