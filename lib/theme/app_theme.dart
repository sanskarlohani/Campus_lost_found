import 'package:flutter/material.dart';

class AppColors {
  static const purple80 = Color(0xFFD0BCFF);
  static const purpleGrey80 = Color(0xFFCCC2DC);
  static const pink80 = Color(0xFFEFB8C8);

  static const purple40 = Color(0xFF6650a4);
  static const purpleGrey40 = Color(0xFF625b71);
  static const pink40 = Color(0xFF7D5260);
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.light(
      primary: AppColors.purple40,
      secondary: AppColors.pink40,
      surface: Colors.white,
      background: Colors.white,
      error: Colors.red.shade400,
    ),
    useMaterial3: true,
  );

  static ThemeData darkTheme = ThemeData(
    colorScheme: ColorScheme.dark(
      primary: AppColors.purple80,
      secondary: AppColors.pink80,
      surface: Colors.grey.shade900,
      background: Colors.black,
      error: Colors.red.shade400,
    ),
    useMaterial3: true,
  );
}