import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart'; 
import 'providers/product_provider.dart';
import 'screens/home_screen.dart';

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
        ChangeNotifierProvider(create: (_) => ProductProvider()),
      ],
      // نستخدم Consumer هنا لكي يتم إعادة بناء MaterialApp 
      // فقط عندما يتغير الـ themeMode في الـ ProductProvider
      child: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          return MaterialApp(
            title: 'Inventory Manager',
            debugShowCheckedModeBanner: false,
            
            // إعدادات الثيم من ملف AppTheme
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            
            // التعديل الجوهري: ربط التطبيق بحالة الثيم الموجودة في الـ Provider
            themeMode: productProvider.themeMode, 
            
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}