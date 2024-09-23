import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  // Ensure Flutter engine is initialized before any async operations
  WidgetsFlutterBinding.ensureInitialized();
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();  // Ensures initialization happens once
  }


  // Initialize SharedPreferences (if you need it at the start of the app)
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // After initialization, run the app within ProviderScope
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      title: 'Flutter Login',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Center(child: LoginPage()),
    );
  }
}
