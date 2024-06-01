import 'package:flutter/material.dart';
import 'package:flutter_studypal/pages/auth/login_page.dart';
import 'package:flutter_studypal/pages/chat_screen.dart';
import 'package:flutter_studypal/pages/main_screen.dart';
import 'package:flutter_studypal/pages/onboarding_page.dart';
import 'package:flutter_studypal/pages/auth/register_page.dart';
import 'package:flutter_studypal/pages/auth/register_page2.dart';
import 'package:flutter_studypal/pages/splash_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter_studypal/utils/theme_provider.dart';  // Pastikan ini diimpor dengan benar

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeModel(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
      builder: (context, theme, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: theme.primaryColor,
            brightness: theme.isDarkMode ? Brightness.dark : Brightness.light,
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashPage(),
            '/home': (context) => const MainScreen(),
            '/onboarding': (context) => const Onboarding(),
            '/register': (context) => const RegisterPage(),
            '/login': (context) => const LoginPage(),
            '/chat': (context) => const ChatPage(),
          },
        );
      },
    );
  }
}
