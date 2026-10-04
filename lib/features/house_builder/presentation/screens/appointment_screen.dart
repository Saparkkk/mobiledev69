import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/house_viewmodel.dart';
import '../../domain/models/appointment_model.dart';

class AppointmentScreen extends StatelessWidget {
  const AppointmentScreen({super.key});

  // ฟังก์ชัน Error Handling: โชว์ SnackBar เวลามีปัญหา
  void _showSnackBar(BuildContext context, String message, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // 🟢 ฟังก์ชันใหม่: แสดงหน้าต่างสำหรับแก้ไขข้อมูล (Update)
  void _showEditDialog(BuildContext context, AppointmentModel appt, HouseViewModel viewModel) {
    final formKey = GlobalKey<FormState>();
    // ดึงข้อมูลเดิมมาใส่ไว้ในช่องกรอกอัตโนมัติ
    final dateController = TextEditingController(text: appt.date);
    final phoneController = TextEditingController(text: appt.phone);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('แก้ไขนัดหมาย: ${appt.houseName}'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: dateController,
                  decoration: const InputDecoration(labelText: 'วันที่สะดวก', border: OutlineInputBorder()),
                  validator: (value) => value == null || value.isEmpty ? 'กรุณาระบุวันที่' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'เบอร์โทรศัพท์', border: OutlineInputBorder()),
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
                // สร้าง Model ใหม่ที่อัปเดตข้อมูลแล้ว
                final updatedAppt = AppointmentModel(
                  id: appt.id, // ใช้ ID เดิม
                  houseName: appt.houseName, // ชื่อบ้านเดิม
                  date: dateController.text, // วันที่ใหม่
                  phone: phoneController.text, // เบอร์โทรใหม่
                );

                // ยิง API อัปเดตข้อมูล
                final error = await viewModel.updateAppointment(appt.id, updatedAppt);
                
                if (!context.mounted) return;
                Navigator.pop(context); // ปิด Dialog

                if (error != null) {
                  _showSnackBar(context, error, true);
                } else {
                  _showSnackBar(context, 'อัปเดตข้อมูลสำเร็จ', false);
                }
              }
            },
            child: const Text('บันทึกการแก้ไข'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HouseViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('การนัดหมายของฉัน')),
      body: viewModel.appointments.isEmpty
          ? const Center(child: Text('ยังไม่มีข้อมูลการนัดหมาย'))
          : ListView.builder(
              itemCount: viewModel.appointments.length,
              itemBuilder: (context, index) {
                final appt = viewModel.appointments[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(appt.houseName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('วันที่: ${appt.date}\nโทร: ${appt.phone}'),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 🟢 ปุ่ม Edit (แก้ไข)
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showEditDialog(context, appt, viewModel),
                        ),
                        // 🔴 ปุ่ม Delete (ลบ)
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('ยืนยันการลบ'),
                                content: const Text('คุณต้องการลบการนัดหมายนี้ใช่หรือไม่?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('ลบ', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              final error = await viewModel.deleteAppointment(appt.id);
                              if (error != null) {
                                _showSnackBar(context, error, true);
                              } else {
                                _showSnackBar(context, 'ลบข้อมูลสำเร็จ', false);
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}