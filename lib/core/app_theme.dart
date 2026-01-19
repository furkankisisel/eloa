import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Modern Eloa tema sistemi
/// Mistik ve premium bir görünüm için tasarlandı
class AppTheme {
  // Renk Paleti
  static const Color primaryDark = Color(0xFF0D0D1A);
  static const Color surfaceDark = Color(0xFF1A1A2E);
  static const Color cardDark = Color(0xFF16213E);
  static const Color cardLight = Color(0xFF1F2940);

  // Vurgu Renkleri
  static const Color accentGold = Color(0xFFFFD93D);
  static const Color accentCoral = Color(0xFFE94560);
  static const Color accentPurple = Color(0xFF9C27B0);
  static const Color accentTeal = Color(0xFF00BFA5);
  static const Color accentBlue = Color(0xFF4FC3F7);

  // Metin Renkleri
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textMuted = Color(0xFF707070);
  static const Color glassBorder = Color(0x33FFFFFF); // rgba(255,255,255,0.2)

  // Gradient'ler
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A0A2E), Color(0xFF16213E), Color(0xFF0F0F23)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
  );

  static const LinearGradient coralGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE94560), Color(0xFFFF6B6B)],
  );

  static const LinearGradient purpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
  );

  static const LinearGradient mysticalGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1A0A2E),
      Color(0xFF16213E),
      Color(0xFF0F0F23),
    ],
  );

  // Glassmorphism Decoration
  static BoxDecoration glassDecoration({
    Color? borderColor,
    double borderRadius = 20,
    double opacity = 0.1,
  }) {
    return BoxDecoration(
      color: Colors.white.withOpacity(opacity),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? Colors.white.withOpacity(0.2),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 20,
          spreadRadius: 0,
        ),
      ],
    );
  }

  // Kart Decoration
  static BoxDecoration cardDecoration({
    Color? color,
    Color? borderColor,
    double borderRadius = 16,
    List<BoxShadow>? boxShadow,
  }) {
    return BoxDecoration(
      color: color ?? cardDark,
      borderRadius: BorderRadius.circular(borderRadius),
      border:
          borderColor != null ? Border.all(color: borderColor, width: 1) : null,
      boxShadow: boxShadow ??
          [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
    );
  }

  // Vurgu Kartı (Altın border)
  static BoxDecoration accentCardDecoration({
    Color accentColor = accentGold,
    double borderRadius = 16,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          cardDark,
          cardLight.withOpacity(0.8),
        ],
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: accentColor.withOpacity(0.4),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: accentColor.withOpacity(0.15),
          blurRadius: 15,
          spreadRadius: 1,
        ),
      ],
    );
  }

  // Ana Tema
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: accentGold,
      scaffoldBackgroundColor: primaryDark,
      fontFamily: GoogleFonts.poppins().fontFamily,
      colorScheme: const ColorScheme.dark(
        primary: accentGold,
        secondary: accentCoral,
        surface: surfaceDark,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onSurface: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.playfairDisplay(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: accentGold,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineLarge: GoogleFonts.playfairDisplay(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 16,
          color: textSecondary,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14,
          color: textSecondary,
        ),
        bodySmall: GoogleFonts.poppins(
          fontSize: 12,
          color: textMuted,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentGold,
          foregroundColor: Colors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: BorderSide(color: Colors.white.withOpacity(0.3)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        selectedItemColor: accentGold,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 12,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardDark,
        hintStyle: TextStyle(color: textMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentGold),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.white.withOpacity(0.1),
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cardLight,
        contentTextStyle: GoogleFonts.poppins(color: textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

/// Kategori renkleri için extension
extension CategoryColors on String {
  Color get categoryColor {
    switch (this) {
      case 'kariyer_ve_basari':
        return AppTheme.accentGold;
      case 'ask_ve_iliskiler':
        return AppTheme.accentCoral;
      case 'saglik_ve_canlilik':
        return AppTheme.accentTeal;
      case 'zeka_ve_dusunce':
        return AppTheme.accentBlue;
      case 'maddi_durum':
        return const Color(0xFFFFD700);
      case 'kisilik_karakter':
        return AppTheme.accentPurple;
      case 'psikoloji_ruhsal':
        return const Color(0xFF7E57C2);
      case 'seyahat_degisim':
        return const Color(0xFF26C6DA);
      case 'ozel_yetenekler':
        return const Color(0xFFFF9800);
      case 'uyarilar_tehlikeler':
        return const Color(0xFFF44336);
      case 'zamanlama_yas':
        return const Color(0xFF78909C);
      case 'aile_sosyal':
        return const Color(0xFF66BB6A);
      default:
        return AppTheme.accentGold;
    }
  }

  IconData get categoryIcon {
    switch (this) {
      case 'kariyer_ve_basari':
        return Icons.work_outline;
      case 'ask_ve_iliskiler':
        return Icons.favorite_border;
      case 'saglik_ve_canlilik':
        return Icons.spa_outlined;
      case 'zeka_ve_dusunce':
        return Icons.psychology_outlined;
      case 'maddi_durum':
        return Icons.monetization_on_outlined;
      case 'kisilik_karakter':
        return Icons.person_outline;
      case 'psikoloji_ruhsal':
        return Icons.self_improvement;
      case 'seyahat_degisim':
        return Icons.flight_outlined;
      case 'ozel_yetenekler':
        return Icons.auto_awesome;
      case 'uyarilar_tehlikeler':
        return Icons.warning_amber_outlined;
      case 'zamanlama_yas':
        return Icons.schedule;
      case 'aile_sosyal':
        return Icons.people_outline;
      default:
        return Icons.auto_awesome;
    }
  }
}
