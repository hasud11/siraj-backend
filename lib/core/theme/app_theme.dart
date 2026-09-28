import 'package:flutter/material.dart';

class AppTheme {
  // ============================================================
  // ألوان سِراج
  // ============================================================

  static const Color navy = Color(0xFF252442);
  static const Color deepNavy = Color(0xFF19182F);

  static const Color purple = Color(0xFF6C4BC1);
  static const Color lightPurple = Color(0xFF8B72D9);

  static const Color gold = Color(0xFFE6B86A);
  static const Color cream = Color(0xFFF8F2E8);

  static const Color background = Color(0xFFF6F3F8);
  static const Color card = Color(0xFFFFFFFF);

  static const Color textDark = Color(0xFF292640);
  static const Color textMuted = Color(0xFF777389);

  // ============================================================
  // الثيم الرئيسي
  // ============================================================

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      scaffoldBackgroundColor: background,

      colorScheme: const ColorScheme.light(
        primary: purple,
        secondary: gold,
        surface: card,
        onPrimary: Colors.white,
        onSecondary: navy,
        onSurface: textDark,
      ),

      // ========================================================
      // AppBar
      // ========================================================

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textDark,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),

      // ========================================================
      // النصوص
      // ========================================================

      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),

        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),

        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),

        headlineMedium: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),

        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),

        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),

        bodyLarge: TextStyle(
          fontSize: 16,
          color: textDark,
          height: 1.6,
        ),

        bodyMedium: TextStyle(
          fontSize: 14,
          color: textMuted,
          height: 1.5,
        ),

        bodySmall: TextStyle(
          fontSize: 12,
          color: textMuted,
        ),
      ),

      // ========================================================
      // الأزرار
      // ========================================================

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: navy,
          foregroundColor: Colors.white,

          elevation: 0,

          minimumSize:
              const Size(double.infinity, 54),

          padding:
              const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 15,
          ),

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(18),
          ),

          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ========================================================
      // حقول الإدخال
      // ========================================================

      inputDecorationTheme:
          InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,

        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 17,
        ),

        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(18),

          borderSide: BorderSide.none,
        ),

        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(18),

          borderSide:
              const BorderSide(
            color: Color(0xFFE9E4ED),
          ),
        ),

        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(18),

          borderSide:
              const BorderSide(
            color: purple,
            width: 1.5,
          ),
        ),

        hintStyle: const TextStyle(
          color: textMuted,
          fontSize: 14,
        ),
      ),

      // ========================================================
      // البطاقات
      // ========================================================

      cardTheme: CardThemeData(
        color: Colors.white,

        elevation: 0,

        margin: EdgeInsets.zero,

        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(22),

          side:
              const BorderSide(
            color: Color(0xFFEAE5EE),
          ),
        ),
      ),

      // ========================================================
      // Bottom Navigation
      // ========================================================

      navigationBarTheme:
          NavigationBarThemeData(
        backgroundColor: Colors.white,

        elevation: 0,

        height: 72,

        indicatorColor:
            const Color(0xFFE9E1F7),

        labelTextStyle:
            WidgetStateProperty.all(
          const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),

        iconTheme:
            WidgetStateProperty.all(
          const IconThemeData(
            size: 23,
          ),
        ),
      ),

      // ========================================================
      // Divider
      // ========================================================

      dividerTheme:
          const DividerThemeData(
        color: Color(0xFFEAE5EE),
        thickness: 1,
      ),
    );
  }

  // ============================================================
  // ثيم الواجهات الداكنة
  // ============================================================

  static const LinearGradient sirajGradient =
      LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      Color(0xFF393656),
      Color(0xFF211F3D),
    ],
  );

  // ============================================================
  // الظل الموحد للبطاقات
  // ============================================================

  static List<BoxShadow> get softShadow {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.06),
        blurRadius: 18,
        offset: const Offset(0, 7),
      ),
    ];
  }
}