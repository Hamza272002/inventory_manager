import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../core/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _auth = AuthService();
  bool _isLoading = false;

  // دالة تسجيل الدخول
  void _login() async {
    setState(() => _isLoading = true);
    try {
      await _auth.login(_emailController.text.trim(), _passwordController.text.trim());
      // التنقل يتم تلقائياً عبر StreamBuilder في ملف main.dart
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("خطأ في تسجيل الدخول: ${e.toString()}")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // شعار أو عنوان التطبيق
              Icon(Icons.inventory_2_rounded, size: 80, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                "Inventory Manager",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "سجل الدخول لإدارة مخزونك",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
              const SizedBox(height: 40),

              // حقل البريد الإلكتروني
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "البريد الإلكتروني",
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // حقل كلمة المرور
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: "كلمة المرور",
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 32),

              // زر تسجيل الدخول
              FilledButton(
                onPressed: _isLoading ? null : _login,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text("تسجيل الدخول", style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}