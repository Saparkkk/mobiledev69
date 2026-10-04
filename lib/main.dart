import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/auth/auth_provider.dart';
import 'features/house_builder/data/repositories/house_repository_impl.dart';
import 'features/house_builder/presentation/viewmodels/house_viewmodel.dart';
import 'router/app_router.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // สร้าง ViewModel และฉีด Repository เข้าไป (Dependency Injection)
        ChangeNotifierProvider(
          create: (_) => HouseViewModel(repository: HouseRepositoryImpl()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ดึง Provider มาสร้าง Router แค่ครั้งเดียว
    final authProvider = context.read<AuthProvider>();
    final appRouter = createAppRouter(authProvider);
    
    return MaterialApp.router(
      routerConfig: appRouter,
      title: 'House Builder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey), 
        useMaterial3: true,
      ),
    );
  }
}