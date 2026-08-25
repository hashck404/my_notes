import 'package:flutter/material.dart';
import 'package:my_notes/app_theme/app_pallete.dart';

class DarkTheme {
  static final darkTheme = ThemeData.dark().copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color.fromARGB(255, 247, 110, 83),
      surface: Color.fromARGB(255, 23, 23, 23),
    ),

    primaryColor: Color.fromARGB(255, 247, 110, 83),
    iconTheme: IconThemeData(color: Colors.white),
    scaffoldBackgroundColor: Color(0xFF1F1F1F),
    textTheme: ThemeData.dark().textTheme.apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: Color(0xFF242424),
      surfaceTintColor: Colors.transparent,

      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),

      contentTextStyle: TextStyle(color: Colors.white70, fontSize: 16),

      iconColor: Colors.white,

      barrierColor: Colors.black54,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromARGB(255, 23, 23, 23),
      foregroundColor: Colors.grey,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
  );
}
