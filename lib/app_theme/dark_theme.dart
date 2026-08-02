import 'package:flutter/material.dart';

class DarkTheme {
  static final darkTheme = ThemeData.dark().copyWith(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
    scaffoldBackgroundColor: Color(0xFF1F1F1F),
  );
}
