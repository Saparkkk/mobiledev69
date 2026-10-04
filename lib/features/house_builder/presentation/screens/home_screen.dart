import 'package:flutter/material.dart';
import 'package:mobiledev69/core/auth/auth_provider.dart';
import 'package:mobiledev69/features/house_builder/presentation/screens/house_detail_screen.dart';
import 'package:mobiledev69/features/house_builder/presentation/screens/login_screen.dart';
import 'package:provider/provider.dart';
import '../viewmodels/house_viewmodel.dart';
import 'appointment_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // สั่งให้โหลดข้อมูลทันทีที่เปิดหน้านี้
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HouseViewModel>().fetchHouses();
    });
  }

  @override
  Widget build(BuildContext context) {
    // ติดตามการเปลี่ยนแปลงของข้อมูลใน ViewModel
    final viewModel = context.watch<HouseViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการแบบบ้าน'),
        actions: [
          // ปุ่มเข้าไปดูและลบการนัดหมาย
          IconButton(
            icon: const Icon(Icons.calendar_month, color: Colors.blue),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AppointmentScreen()),
              );
            },
          ),
          // ปุ่ม Logout
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      // 🟢 นำ Column มาครอบเพื่อให้วางช่องค้นหาไว้ด้านบนของรายการบ้านได้
      body: Column(
        children: [
          // แถบเครื่องมือค้นหาและเรียงลำดับ
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) => viewModel.updateSearchQuery(value),
                    decoration: InputDecoration(
                      hintText: 'ค้นหาชื่อบ้าน, ผู้รับเหมา...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: viewModel.sortOption,
                      items: ['ชื่อ (A-Z)', 'ราคา (น้อย-มาก)', 'ราคา (มาก-น้อย)']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14))))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) viewModel.updateSortOption(value);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // พื้นที่แสดงรายการบ้าน (ใช้ Expanded เพื่อให้กินพื้นที่ที่เหลือทั้งหมด)
          Expanded(child: _buildBody(viewModel)),
        ],
      ),
    );
  }

  Widget _buildBody(HouseViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorMessage != null) {
      return Center(
        child: Text(viewModel.errorMessage!, 
          style: const TextStyle(color: Colors.red, fontSize: 16)
        ),
      );
    }

    // 🟢 เปลี่ยนจาก viewModel.houses มาเรียกใช้ filteredAndSortedHouses แทน
    final displayList = viewModel.filteredAndSortedHouses;

    if (displayList.isEmpty) {
      return const Center(child: Text('ไม่พบข้อมูลแบบบ้านที่ค้นหา'));
    }

    return ListView.builder(
      itemCount: displayList.length,
      itemBuilder: (context, index) {
        final house = displayList[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                house.imageUrl, 
                width: 70, 
                height: 70, 
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => 
                  Container(width: 70, height: 70, color: Colors.grey.shade300, child: const Icon(Icons.home)),
              ),
            ),
            title: Text(house.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('ราคาเริ่มต้น: ฿${house.startingPrice.toStringAsFixed(2)}\nผู้รับเหมา: ${house.contractorName}'),
            isThreeLine: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HouseDetailScreen(house: house), 
                ),
              );
            },
          ),
        );
      },
    );
  }
}