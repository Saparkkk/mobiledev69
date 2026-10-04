import 'package:go_router/go_router.dart';
import 'package:mobiledev69/core/auth/auth_provider.dart';

// สมมติว่ามี 2 หน้านี้ (แก้ไข import ให้ตรงกับชื่อไฟล์จริงของคุณ)
import '../features/house_builder/presentation/screens/login_screen.dart';
import '../features/house_builder/presentation/screens/home_screen.dart';

GoRouter createAppRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: '/',
    // สั่งให้ Router รีเฟรชตัวเองทันทีที่สถานะล็อกอินเปลี่ยน (ตอน login/logout)
    refreshListenable: authProvider, 
    
    // 🛡️ หัวใจสำคัญ: Route Guard
    redirect: (context, state) {
      final isLoggedIn = authProvider.isAuthenticated;
      final isGoingToLogin = state.matchedLocation == '/login';

      // 1. ถ้ายังไม่ล็อกอิน และไม่ได้อยู่หน้าล็อกอิน -> เด้งไปบังคับล็อกอิน
      if (!isLoggedIn && !isGoingToLogin) {
        return '/login';
      }

      // 2. ถ้าล็อกอินแล้ว แต่เผลอกดมาหน้าล็อกอิน -> เด้งกลับไปหน้าแรก
      if (isLoggedIn && isGoingToLogin) {
        return '/';
      }

      // 3. ปล่อยผ่านให้เข้าหน้าตามปกติ
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(), // หน้าเนื้อหาหลักของคุณ
      ),
    ],
  );
}