import 'package:flutter/material.dart';

/// Hệ thống màu sắc, typography và style dùng chung cho toàn bộ ứng dụng.
/// Phong cách: hiện đại, tối giản, gradient xanh dương – tím, bo góc mềm.
class AppTheme {
  AppTheme._();

  // ---------------------------------------------------------------------------
  // Màu sắc
  // ---------------------------------------------------------------------------
  static const Color primary = Color(0xFF5B5FEF);
  static const Color primaryDark = Color(0xFF3F3CBB);
  static const Color blue = Color(0xFF3B82F6);
  static const Color violet = Color(0xFF8B5CF6);
  static const Color accent = Color(0xFF0EA5E9);
  static const Color background = Color(0xFFF5F6FE);
  static const Color surfaceSoft = Color(0xFFF3F4FF);
  static const Color textPrimary = Color(0xFF1B1F3B);
  static const Color textSecondary = Color(0xFF6B7194);
  static const Color textMuted = Color(0xFFA0A5C2);
  static const Color border = Color(0xFFE4E6F5);
  static const Color danger = Color(0xFFF43F5E);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);

  // ---------------------------------------------------------------------------
  // Gradient
  // ---------------------------------------------------------------------------
  /// Gradient thương hiệu chính (xanh dương → tím).
  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = brandGradient;

  static const LinearGradient authGradient = LinearGradient(
    colors: [Color(0xFF1E3A8A), Color(0xFF4F46E5), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dangerGradient = LinearGradient(
    colors: [Color(0xFFFB7185), Color(0xFFE11D48)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient skyGradient = LinearGradient(
    colors: [Color(0xFF38BDF8), Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFF8F9FF), Color(0xFFEFF0FE)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Trả về gradient tương ứng với một màu nhấn (dùng cho avatar, icon...).
  static LinearGradient gradientFor(Color color) {
    if (color == danger) return dangerGradient;
    if (color == accent) return skyGradient;
    return brandGradient;
  }

  // ---------------------------------------------------------------------------
  // Bóng đổ
  // ---------------------------------------------------------------------------
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: const Color(0xFF3B3F8F).withValues(alpha: 0.07),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ];

  static List<BoxShadow> glowShadow([Color color = primary]) => [
        BoxShadow(
          color: color.withValues(alpha: 0.35),
          blurRadius: 22,
          offset: const Offset(0, 10),
        ),
      ];

  // ---------------------------------------------------------------------------
  // Bo góc
  // ---------------------------------------------------------------------------
  static const double radiusSm = 12;
  static const double radiusMd = 16;
  static const double radiusLg = 22;
  static const double radiusXl = 28;

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMd),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: primary,
      onPrimary: Colors.white,
      secondary: violet,
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: textPrimary,
      error: danger,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      splashFactory: InkSparkle.splashFactory,
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: textPrimary,
          letterSpacing: -0.4,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.2,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 15.5,
          color: textPrimary,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: textPrimary,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 12.5,
          color: textSecondary,
          height: 1.4,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.2,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceSoft,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
        hintStyle: const TextStyle(color: textMuted, fontSize: 14),
        labelStyle: const TextStyle(color: textSecondary, fontSize: 14),
        floatingLabelStyle: const TextStyle(
          color: primary,
          fontWeight: FontWeight.w600,
        ),
        prefixIconColor: WidgetStateColor.resolveWith(
          (states) =>
              states.contains(WidgetState.focused) ? primary : textMuted,
        ),
        suffixIconColor: textMuted,
        border: _inputBorder(Colors.transparent),
        enabledBorder: _inputBorder(Colors.transparent),
        focusedBorder: _inputBorder(primary, width: 1.6),
        errorBorder: _inputBorder(danger.withValues(alpha: 0.6)),
        focusedErrorBorder: _inputBorder(danger, width: 1.6),
        errorStyle: const TextStyle(fontSize: 12, color: danger),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          backgroundColor: Colors.white,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          side: const BorderSide(color: border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
        extendedTextStyle: const TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w700,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1B1F3B),
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        elevation: 6,
        insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXl),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: textPrimary,
          letterSpacing: -0.2,
        ),
        contentTextStyle: const TextStyle(
          fontSize: 14.5,
          color: textSecondary,
          height: 1.55,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceSoft,
        side: BorderSide.none,
        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textSecondary,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: primary),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: const Color(0xFF1B1F3B),
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}
