import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // دالة مساعدة لإنشاء تنسيق حقول النصوص (Input Decoration) لضمان وضوح الأرقام
  static InputDecorationTheme _inputTheme(bool isDark) {
    return InputDecorationTheme(
      filled: true,
      // خلفية واضحة للحقل تختلف عن خلفية الشاشة
      fillColor: isDark ? const Color(0xFF2A2D31) : const Color(0xFFF0F2F5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? const Color(0xFFD1E4FF) : const Color(0xFF0061A4), width: 2),
      ),
      // لون النص التوضيحي (Label)
      labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
      hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
    );
  }

  // 🎨 نظام ألوان Material 3 للوضع الفاتح
  static final lightTheme = ThemeData(
    useMaterial3: true,
    // تطبيق خط Poppins المطلوب في الخطة 
    textTheme: GoogleFonts.poppinsTextTheme(),
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blueAccent,
      brightness: Brightness.light,
      primary: const Color(0xFF0061A4),
      surface: const Color(0xFFFDFBFF),
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 2,
    ),
    // إضافة تنسيق الحقول لحل مشكلة اختفاء الأرقام
    inputDecorationTheme: _inputTheme(false),
    cardTheme: CardThemeData(
      elevation: 0,
      color: const Color(0xFFF3F4F9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );

  // 🌙 نظام ألوان Material 3 للوضع المظلم
  static final darkTheme = ThemeData(
    useMaterial3: true,
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blueAccent,
      brightness: Brightness.dark,
      primary: const Color(0xFFD1E4FF),
      surface: const Color(0xFF1A1C1E),
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Color(0xFF1A1C1E),
    ),
    // إضافة تنسيق الحقول للوضع المظلم
    inputDecorationTheme: _inputTheme(true),
    cardTheme: CardThemeData(
      elevation: 0,
      color: const Color(0xFF222226),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}