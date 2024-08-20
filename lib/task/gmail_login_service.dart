import 'auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GmailLoginService {
  final AuthService _authService = AuthService();

  Future<User?> loginWithGoogle({required String role}) async {
    return await _authService.loginWithGoogle(role);
  }
}
