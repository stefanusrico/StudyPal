import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class GlobalColors {
  static Color blackColor = const Color(0xff1A1717);
  static LinearGradient buttonGradient = const LinearGradient(
    colors: [Color(0xff92a3fd), Color(0xff9dceff)],
  );

  static HexColor textLogoColor = HexColor("#CC8FED");
  static HexColor textLogin = HexColor("#C58BF2");
  // static HexColor iconColor = HexColor("#86ABFF");
  static Color iconColor = const Color(0xff86abff).withAlpha(255);
}
