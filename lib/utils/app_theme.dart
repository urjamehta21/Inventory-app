// lib/utils/app_theme.dart
import 'package:flutter/material.dart';
import '../models/product.dart';

class AppTheme {
  static const Color primary = Color(0xFF0A2540);
  static const Color accent = Color(0xFF00D4AA);
  static const Color accentOrange = Color(0xFFFF6B35);
  static const Color surface = Color(0xFF0F3460);
  static const Color cardBg = Color(0xFF162040);
  static const Color textPrimary = Color(0xFFEEF2FF);
  static const Color textSecondary = Color(0xFF8B9BC8);
  static const Color success = Color(0xFF00D4AA);
  static const Color warning = Color(0xFFFFB800);
  static const Color danger = Color(0xFFFF4757);
  static const Color stockNormal = Color(0xFF00D4AA);
  static const Color stockWarning = Color(0xFFFFB800);
  static const Color stockLow = Color(0xFFFF6B35);
  static const Color stockOut = Color(0xFFFF4757);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Sora',
      scaffoldBackgroundColor: primary,
      colorScheme: ColorScheme.dark(
        primary: accent,
        secondary: accentOrange,
        surface: cardBg,
        onPrimary: primary,
        onSurface: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: textPrimary,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: 'Sora',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),
      cardTheme: CardTheme(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
            fontFamily: 'Sora',
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: danger),
        ),
        labelStyle: const TextStyle(color: textSecondary, fontFamily: 'Sora'),
        hintStyle: TextStyle(color: textSecondary.withOpacity(0.6), fontFamily: 'Sora'),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardBg,
        selectedItemColor: accent,
        unselectedItemColor: textSecondary,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontFamily: 'Sora', fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontFamily: 'Sora', fontSize: 11),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: accent.withOpacity(0.2),
        labelStyle: const TextStyle(fontFamily: 'Sora', fontSize: 12, color: textPrimary),
        side: BorderSide(color: Colors.white.withOpacity(0.1)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: primary,
        elevation: 4,
      ),
      dividerTheme: DividerThemeData(color: Colors.white.withOpacity(0.07)),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: textPrimary, fontFamily: 'Sora', fontWeight: FontWeight.w700),
        headlineMedium: TextStyle(color: textPrimary, fontFamily: 'Sora', fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: textPrimary, fontFamily: 'Sora', fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: textPrimary, fontFamily: 'Sora', fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: textPrimary, fontFamily: 'Sora'),
        bodyMedium: TextStyle(color: textSecondary, fontFamily: 'Sora'),
        labelLarge: TextStyle(color: textPrimary, fontFamily: 'Sora', fontWeight: FontWeight.w600),
      ),
    );
  }
}

extension StockStatusColors on StockStatus {
  Color get color {
    switch (this) {
      case StockStatus.normal:
        return AppTheme.stockNormal;
      case StockStatus.warning:
        return AppTheme.stockWarning;
      case StockStatus.low:
        return AppTheme.stockLow;
      case StockStatus.outOfStock:
        return AppTheme.stockOut;
    }
  }

  String get label {
    switch (this) {
      case StockStatus.normal:
        return 'In Stock';
      case StockStatus.warning:
        return 'Low Stock';
      case StockStatus.low:
        return 'Critical';
      case StockStatus.outOfStock:
        return 'Out of Stock';
    }
  }

  IconData get icon {
    switch (this) {
      case StockStatus.normal:
        return Icons.check_circle_rounded;
      case StockStatus.warning:
        return Icons.warning_amber_rounded;
      case StockStatus.low:
        return Icons.error_rounded;
      case StockStatus.outOfStock:
        return Icons.remove_circle_rounded;
    }
  }
}
