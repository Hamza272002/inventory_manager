import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // مراقبة حالة المستخدم (Auth State)
  Stream<User?> get user => _auth.authStateChanges();

  // تسجيل الدخول
  Future<UserCredential> login(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // تسجيل الخروج
  Future<void> logout() async {
    await _auth.signOut();
  }
}