import 'auth_service.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository(this._authService);

  Future<void> logout() async {
    await _authService.logout();
  }
}