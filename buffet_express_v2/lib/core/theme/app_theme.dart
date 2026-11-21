import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color darkGreen = Color(0xFF1E3D32);
  static const Color lightBeige = Color(0xFFF9F6F0);
  static const Color orangeAccent = Color(0xFFE07A5F);

  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: lightBeige,
      // TRUCO: Usamos fontFamily en lugar de textTheme para evitar el choque de tipos
      fontFamily: GoogleFonts.inter().fontFamily,
      colorScheme: ColorScheme.fromSeed(seedColor: darkGreen),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
