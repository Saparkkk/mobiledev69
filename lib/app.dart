import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'router/app_router.dart';
import 'core/auth/auth_provider.dart';
import 'features/house_builder/data/repositories/house_repository_impl.dart';
import 'features/house_builder/presentation/viewmodels/house_viewmodel.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // แก้ไขให้รับค่าแบบ repository: ให้ถูกต้อง และลบอันที่ซ้ำออก
        ChangeNotifierProvider(
          create: (_) => HouseViewModel(repository: HouseRepositoryImpl()),
        ),
      ],
      // ใช้ Builder เพื่อให้มองเห็น Provider ที่เพิ่งสร้างด้านบน
      child: Builder(
        builder: (context) {
          final authProvider = context.read<AuthProvider>();
          final appRouter = createAppRouter(authProvider);

          return MaterialApp.router(
            title: 'House Builder',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey), 
              useMaterial3: true,
            ),
            routerConfig: appRouter, // ใช้ Router ตัวจริง
          );
        },
      ),
    );
  }
}