import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart'; 
import 'providers/product_provider.dart';
import 'services/auth_service.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyBGEaEu1gjZl0fgrhO60dJpCht8ezcNK8Q",
          authDomain: "inventory-manager-fa2b5.firebaseapp.com",
          projectId: "inventory-manager-fa2b5",
          storageBucket: "inventory-manager-fa2b5.firebasestorage.app",
          messagingSenderId: "1092178028396",
          appId: "1:1092178028396:web:3ab9fe564e70439184f549",
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint("Firebase Initialization Error: $e");
  }

  runApp(const InventoryApp());
}

class InventoryApp extends StatelessWidget {
  const InventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // تعريف الـ Provider ليكون متاحاً في كل التطبيق [cite: 39]
        ChangeNotifierProvider(create: (_) => ProductProvider()),
      ],
      child: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          return MaterialApp(
            title: 'Inventory Manager',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            // ربط حالة الثيم بالمزود [cite: 42]
            themeMode: productProvider.themeMode, 
            
            // استخدام StreamBuilder لمراقبة حالة المستخدم لحظياً [cite: 35, 43]
            home: StreamBuilder(
              stream: AuthService().user, 
              builder: (context, snapshot) {
                // إذا كان Firebase يتحقق من المستخدم
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(body: Center(child: CircularProgressIndicator()));
                }
                
                // إذا وجد مستخدم مسجل [cite: 46]
                if (snapshot.hasData) {
  // بدلاً من الاستدعاء المباشر، نستخدم هذا الكود:
  final provider = Provider.of<ProductProvider>(context, listen: false);
  
  // نستخدم التوقيت الصغير لضمان عدم حدوث تصادم في البناء
  WidgetsBinding.instance.addPostFrameCallback((_) {
    provider.startListeningToProducts();
  });

  return const HomeScreen();
}
                
                // إذا لم يكن مسجلاً، توجه لشاشة تسجيل الدخول
                return const LoginScreen();
              },
            ),
          );
        },
      ),
    );
  }
}