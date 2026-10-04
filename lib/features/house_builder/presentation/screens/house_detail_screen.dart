import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import '../../domain/models/house_model.dart';
import '../viewmodels/house_viewmodel.dart';
import '../../domain/models/appointment_model.dart';

class HouseDetailScreen extends StatelessWidget {
  final HouseModel house;

  const HouseDetailScreen({super.key, required this.house});

  // ฟังก์ชันแสดงหน้าต่างฟอร์ม
  void _showContactDialog(BuildContext context, HouseViewModel viewModel) {
    final formKey = GlobalKey<FormState>();
    final dateController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('นัดหมาย: ${house.name}'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('กรุณากรอกข้อมูลเพื่อให้ผู้รับเหมาติดต่อกลับ'),
                const SizedBox(height: 16),
                TextFormField(
                  controller: dateController,
                  decoration: const InputDecoration(
                    labelText: 'วันที่สะดวก (เช่น 15 ต.ค.)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'กรุณาระบุวันที่' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'เบอร์โทรศัพท์',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.length < 9 ? 'กรุณากรอกเบอร์โทรที่ถูกต้อง' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final newAppointment = AppointmentModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  houseName: house.name,
                  date: dateController.text,
                  phone: phoneController.text,
                );
                
                // เรียกใช้ API บันทึกข้อมูล
                final error = await viewModel.addAppointment(newAppointment); 
                
                if (!context.mounted) return;
                
                if (error != null) {
                  // ถ้าพัง โชว์สีแดง
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(error), backgroundColor: Colors.red),
                  );
                } else {
                  // ถ้าสำเร็จ ปิดหน้าต่างและโชว์สีเขียว
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ บันทึกข้อมูลนัดหมายสำเร็จ!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            child: const Text('ยืนยันนัดหมาย'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ดึงข้อมูลและเช็คสถานะการจองจากฐานข้อมูล API โดยตรง
    final viewModel = context.watch<HouseViewModel>();
    final isAlreadyBooked = viewModel.appointments.any((appt) => appt.houseName == house.name);
    
    return Scaffold(
      appBar: AppBar(title: Text(house.name)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.network(house.imageUrl, height: 250, fit: BoxFit.cover),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(house.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('รับเหมาโดย: ${house.contractorName}', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('ราคาเริ่มต้น:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(
                          '฿${(house.startingPrice / 1000000).toStringAsFixed(1)} ล้านบาท',
                          style: const TextStyle(fontSize: 20, color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('รายละเอียด', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(house.description, style: const TextStyle(fontSize: 16, height: 1.5)),
                ],
              ),
            ),
          ),
          
          // ปุ่มด้านล่างที่ได้รับการแก้ไขโครงสร้างแล้ว
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
            ),
            child: ElevatedButton(
              onPressed: isAlreadyBooked 
                  ? null // ถ้าจองแล้ว ล็อคปุ่มกดไม่ได้
                  : () => _showContactDialog(context, viewModel), // ถ้ายังไม่ได้จอง กดเปิด Dialog
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: isAlreadyBooked ? Colors.grey.shade400 : Colors.blueGrey,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                isAlreadyBooked ? 'ติดต่อผู้รับเหมาแล้ว' : 'ติดต่อผู้รับเหมา', 
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
              ),
            ),
          ),
        ],
      ),
    );
  }
}