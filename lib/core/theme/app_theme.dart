import 'package:flutter/material.dart';
import 'package:moovapp/core/theme/app_colors.dart';

class AppTheme {
  // Thème principal de l'application
  static ThemeData get lightTheme {
    return ThemeData(
      // 1. Définir le schéma de couleurs
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        primary: AppColors.primaryBlue,
        secondary: AppColors.premiumOrange,
        background: AppColors.background,
        error: AppColors.error,
      ),

      // 2. Thème de l'AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
        iconTheme: IconThemeData(color: AppColors.white),
      ),

      // 3. Thème des boutons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // 4. Thème des champs de texte (TextField)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
        prefixIconColor: Colors.grey[600],
      ),

      // 5. Thème des cartes (corrigé : pas de ThemeData imbriqué)
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
    ), 
), 

      // 6. Fond général de l'application
      scaffoldBackgroundColor: AppColors.background,
      
      // 7. Police de caractères (Optionnel)
      // fontFamily: 'Inter',
      
      useMaterial3: true,
    );
  }
}

