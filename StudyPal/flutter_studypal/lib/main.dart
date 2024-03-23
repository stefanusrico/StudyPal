import 'package:flutter/material.dart';
import 'package:flutter_studypal/pages/onboarding_page.dart';
import 'package:flutter_studypal/pages/register_page.dart';
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
        '/onboarding': (context) => const Onboarding(),
        '/register': (context) => const RegisterPage(),
        // '/login': (context) => const Login(),
      },
    );
  }
}
