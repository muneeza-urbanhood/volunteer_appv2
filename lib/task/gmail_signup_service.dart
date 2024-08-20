import 'auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GmailSignUpService {
  final AuthService _authService = AuthService();

  Future<User?> signUpWithGoogle({required String role, required String name}) async {
    return await _authService.signUpWithGoogle(role, name);
  }
}
