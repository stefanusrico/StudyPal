import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeModel extends ChangeNotifier {
  bool _isDarkMode = false;
  Color _primaryColor = Color.fromARGB(255, 174, 196, 250); // Default to blue color

  bool get isDarkMode => _isDarkMode;
  Color get primaryColor => _primaryColor;

  ThemeModel() {
    _loadPreferences();
  }

  void _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _primaryColor = _getColorFromString(prefs.getString('primaryColor') ?? 'blue');
    notifyListeners();
  }

  void toggleDarkMode(bool isDark) async {
    _isDarkMode = isDark;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', _isDarkMode);
  }

  void updatePrimaryColor(Color color) async {
    _primaryColor = color;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('primaryColor', color.toString());
  }

  Color _getColorFromString(String colorString) {
    switch (colorString) {
      case 'custom1':
        return Color.fromARGB(255, 174, 196, 250);
      case 'custom2':
        return Color.fromARGB(255, 124, 129, 250);
      case 'blue':
      default:
        return Color.fromARGB(255, 174, 196, 250);// Default to blue
    }
  }
}
