import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/contracts/house_repository.dart';
import '../../domain/models/house_model.dart';
import '../../domain/models/appointment_model.dart';

class HouseViewModel extends ChangeNotifier {
  final HouseRepository repository;

  // 1. Constructor แบบระบุชื่อตัวแปร (ช่วยแก้ Error ใน main.dart)
  HouseViewModel({required this.repository}) {
    _loadContactedHistory();
  }

  // --- ส่วนที่ 1: จัดการข้อมูลแบบบ้าน ---
  List<HouseModel> houses = [];
  bool isLoading = false;
  String? errorMessage;
  Set<String> contactedHouseIds = {};

  String _searchQuery = '';
  String _sortOption = 'ชื่อ (A-Z)'; // ค่าเริ่มต้น

  String get searchQuery => _searchQuery;
  String get sortOption => _sortOption;

  // 🟢 2. ฟังก์ชันอัปเดตคำค้นหา
  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // 🟢 3. ฟังก์ชันอัปเดตการเรียงลำดับ
  void updateSortOption(String option) {
    _sortOption = option;
    notifyListeners();
  }

  // 🟢 4. สร้าง List ใหม่ที่ผ่านการกรองและเรียงลำดับแล้ว (UI จะดึงตัวนี้ไปใช้)
  List<HouseModel> get filteredAndSortedHouses {
    // กรองตามชื่อบ้าน หรือ ชื่อผู้รับเหมา
    var filtered = houses.where((house) {
      final query = _searchQuery.toLowerCase();
      return house.name.toLowerCase().contains(query) || 
             house.contractorName.toLowerCase().contains(query);
    }).toList();

    // เรียงลำดับข้อมูล
    if (_sortOption == 'ราคา (น้อย-มาก)') {
      filtered.sort((a, b) => a.startingPrice.compareTo(b.startingPrice));
    } else if (_sortOption == 'ราคา (มาก-น้อย)') {
      filtered.sort((a, b) => b.startingPrice.compareTo(a.startingPrice));
    } else {
      // ค่าเริ่มต้น: เรียงตามตัวอักษร
      filtered.sort((a, b) => a.name.compareTo(b.name));
    }

    return filtered;
  }

  Future<void> fetchHouses() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final result = await repository.getHouses();

    result.fold(
      (error) => errorMessage = error,
      (data) => houses = data,
    );

    isLoading = false;
    notifyListeners();
  }

  // สร้างฟังก์ชันใหม่สำหรับดึงข้อมูลนัดหมาย
  // สร้างฟังก์ชันใหม่สำหรับดึงข้อมูลนัดหมาย
  Future<void> fetchAppointments() async {
    final result = await repository.getAppointments();
    
    // 🟢 เอาคำว่า return ออกไปเลย เพราะฟังก์ชันนี้เป็น void 
    result.fold(
      (error) => print(error),
      (data) {
        appointments = data;
        notifyListeners(); // สั่งให้อัปเดตหน้าจอด้วยรายการที่มี ID จริง
      },
    );
  }

  // --- ส่วนที่ 2: ประวัติการติดต่อ (ปุ่มเปลี่ยนสี) ---
  Future<void> _loadContactedHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('contacted_houses') ?? [];
    contactedHouseIds = history.toSet();
    notifyListeners();
  }

  Future<void> markAsContacted(String houseId) async {
    final prefs = await SharedPreferences.getInstance();
    contactedHouseIds.add(houseId);
    await prefs.setStringList('contacted_houses', contactedHouseIds.toList());
    notifyListeners();
  }

  bool isContacted(String houseId) {
    return contactedHouseIds.contains(houseId);
  }

  // --- ส่วนที่ 3: ระบบนัดหมาย (CRUD ยิงเข้า Backend) ---
  List<AppointmentModel> appointments = [];

  // ไม่ต้องใช้ _saveAppointmentsToPrefs หรือ loadAppointments แบบเดิมแล้ว
  // เพราะเดี๋ยวเราจะบันทึกขึ้น Backend เลย

  // 1. Create: จองคิวใหม่ (ส่งเข้า API)
  Future<String?> addAppointment(AppointmentModel appt) async {
    final result = await repository.createAppointment(appt);
    return result.fold(
      (error) => error,
      (_) {
        // 🟢 หลังจากยิงข้อมูลเข้า API สำเร็จ ให้สั่งโหลดข้อมูลใหม่ทั้งหมด
        // เพื่อล้าง ID จำลองทิ้ง และแทนที่ด้วย ID จริงจากเซิร์ฟเวอร์
        fetchAppointments(); 
        return null; // ไม่มี Error
      },
    );
  }

  // 2. Update: แก้ไขคิวนัด (ส่งเข้า API)
  Future<String?> updateAppointment(String id, AppointmentModel updatedAppointment) async {
    final result = await repository.updateAppointment(id, updatedAppointment);
    return result.fold(
      (error) => error,
      (_) {
        final index = appointments.indexWhere((app) => app.id == id);
        if (index != -1) {
          appointments[index] = updatedAppointment;
          notifyListeners();
        }
        return null;
      },
    );
  }

  // 3. Delete: ลบคิวนัด (ส่งเข้า API)
  Future<String?> deleteAppointment(String id) async {
    final result = await repository.deleteAppointment(id);
    return result.fold(
      (error) => error,
      (_) {
        appointments.removeWhere((app) => app.id == id);
        notifyListeners();
        return null;
      },
    );
  }
}