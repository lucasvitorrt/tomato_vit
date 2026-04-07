import 'package:flutter/material.dart';

class AppTheme {
  // Cores Principais
  static const Color vermelhoTomate = Color(0xFFD32F2F);
  static const Color verdeFolha = Color(0xFF2E7D32);
  static const Color fundoClaro = Color(0xFFF5F6FA);
  static const Color textoPrincipal = Color(0xFF212121);

  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: fundoClaro,
      colorScheme: ColorScheme.fromSeed(
        seedColor: verdeFolha,
        primary: verdeFolha,
        secondary: vermelhoTomate,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: verdeFolha,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: verdeFolha,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
