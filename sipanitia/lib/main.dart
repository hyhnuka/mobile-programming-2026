import 'package:flutter/material.dart';
import 'package:sipanitia/services/notification_service.dart';
import 'package:sipanitia/views/login_page.dart'; 
import 'package:sipanitia/views/register_page.dart'; // Pastikan import ini ada
import 'package:firebase_core/firebase_core.dart'; 
import 'firebase_options.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SiPanitia',
      debugShowCheckedModeBanner: false,
      // Gunakan initialRoute, hapus properti 'home' di bawah
      initialRoute: '/login', 
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0288D1)),
        useMaterial3: true,
      ),
    );
  }
}