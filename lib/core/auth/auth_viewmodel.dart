import 'package:flutter/foundation.dart';
import 'auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repository;
  bool _isAuthenticated = true;

  bool get isAuthenticated => _isAuthenticated;

  AuthViewModel(this._repository);

  Future<void> logout() async {
    await _repository.logout();
    _isAuthenticated = false;
    notifyListeners(); // แจ้งเตือน UI ให้เปลี่ยนสถานะ
  }
}