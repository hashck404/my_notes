import 'package:flutter/material.dart';
import 'package:my_notes/app_theme/app_pallete.dart';

class LightTheme {
  static final lightTheme = ThemeData.light().copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 247, 110, 83),
      surface: const Color(0xFFF7F7F7),
      brightness: Brightness.light,
    ),

    primaryColor: const Color.fromARGB(255, 247, 110, 83),

    iconTheme: const IconThemeData(color: Colors.black87),

    scaffoldBackgroundColor: const Color(0xFFF5F5F5),

    textTheme: ThemeData.light().textTheme.apply(
      bodyColor: Colors.black87,
      displayColor: Colors.black87,
    ),

    dialogTheme: const DialogThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: Colors.black87,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: TextStyle(color: Colors.black54, fontSize: 16),
      iconColor: Colors.black87,
      barrierColor: Colors.black26,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black54,
      titleTextStyle: TextStyle(
        color: Colors.black87,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
      iconTheme: IconThemeData(color: Colors.black87),
    ),
  );
}
