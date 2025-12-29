import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary =
      Color(0xFF6C5DD3); // Updated to specific purple from image
  static const Color secondary = Color(0xFFFF6584);
  static const Color accent = Color(0xFF8B5CF6);

  // Base colors for backward compatibility with existing screens
  static const Color background = backgroundDark;
  static const Color surface = surfaceDark;
  static const Color textPrimary = textPrimaryDark;
  static const Color textSecondary = textSecondaryDark;

  // Dark Palette
  static const Color backgroundDark = Color(0xFF181A20); // Dark Gunmetal
  static const Color surfaceDark =
      Color(0xFF262A34); // Slightly lighter card color
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark =
      Color(0xFF757575); // Grey for subtitles

  // Light Palette
  static const Color backgroundLight = Color(0xFFF1F5F9);
  static const Color surfaceLight = Colors.white;
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);

  static const List<Color> primaryGradient = [
    primary,
    Color(0xFF8676FB)
  ]; // Smoother purple gradient

  static ThemeData get darkTheme {
    return _buildTheme(Brightness.dark);
  }

  static ThemeData get lightTheme {
    return _buildTheme(Brightness.light);
  }

  static ThemeData _buildTheme(Brightness brightness) {
    bool isDark = brightness == Brightness.dark;
    Color bg = isDark ? backgroundDark : backgroundLight;
    Color surfaceColor = isDark ? surfaceDark : surfaceLight;
    Color text = isDark ? textPrimaryDark : textPrimaryLight;
    Color subText = isDark ? textSecondaryDark : textSecondaryLight;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: bg,
      colorScheme: isDark
          ? const ColorScheme.dark(
              primary: primary, secondary: secondary, surface: surfaceDark)
          : const ColorScheme.light(
              primary: primary, secondary: secondary, surface: surfaceLight),
      textTheme: TextTheme(
        displayLarge:
            TextStyle(fontSize: 48, fontWeight: FontWeight.w800, color: text),
        displayMedium:
            TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: text),
        titleLarge:
            TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: text),
        bodyLarge: TextStyle(fontSize: 16, color: text, height: 1.6),
        bodyMedium: TextStyle(fontSize: 14, color: subText),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none),
        hintStyle: TextStyle(color: subText.withOpacity(0.5)),
      ),
    );
  }
}

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}
