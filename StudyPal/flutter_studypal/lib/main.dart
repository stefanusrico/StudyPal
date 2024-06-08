import 'package:flutter/material.dart';
import 'package:flutter_studypal/models/socket_manager.dart';
import 'package:flutter_studypal/pages/main_screen.dart';
import 'package:flutter_studypal/pages/splash_page.dart';
import 'package:flutter_studypal/pages/auth/login_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter_studypal/utils/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');
  bool isLoggedIn = token != null;

  SocketManager.initSocket();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeModel(),
      child: MyApp(isLoggedIn: isLoggedIn),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

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
          initialRoute: isLoggedIn ? '/home' : '/splash',
          routes: {
            '/splash': (context) => const SplashPage(),
            '/home': (context) => const MainScreen(),
            '/login': (context) => const LoginPage(),
          },
        );
      },
    );
  }
}
