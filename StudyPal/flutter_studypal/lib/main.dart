import 'package:flutter/material.dart';
import 'package:flutter_studypal/pages/auth/login_page.dart';
import 'package:flutter_studypal/pages/main_screen.dart';
import 'package:flutter_studypal/pages/onboarding_page.dart';
import 'package:flutter_studypal/pages/auth/register_page.dart';
import 'package:flutter_studypal/pages/auth/register_page2.dart';
import 'package:flutter_studypal/pages/splash_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashPage(),
        '/home': (context) => const MainScreen(),
        '/onboarding': (context) => const Onboarding(),
        '/register': (context) => const RegisterPage(),
        '/login': (context) => const LoginPage(),
      },
    );
  }
}
