import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/product_provider.dart';
import 'screens/home_screen.dart';

void main() {

  WidgetsFlutterBinding.ensureInitialized()

  if(kIsWasm){
    Firebase.initializeApp(
      options: const FirebaseOptions(apiKey: "AIzaSyBGEaEu1gjZl0fgrhO60dJpCht8ezcNK8Q",
  authDomain: "inventory-manager-fa2b5.firebaseapp.com",
  projectId: "inventory-manager-fa2b5",
  storageBucket: "inventory-manager-fa2b5.firebasestorage.app",
  messagingSenderId: "1092178028396",
  appId: "1:1092178028396:web:3ab9fe564e70439184f549"));
  runApp(const InventoryApp());
  }else{
    Firebase.initializeApp();
  }
  
}

class InventoryApp extends StatelessWidget {
  const InventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
