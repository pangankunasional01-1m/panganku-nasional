import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design System — PanganKu Nasional
/// Karakter: terpercaya, hangat, modern, bernuansa pertanian Indonesia.
class AppTheme {
  // ── Brand ──────────────────────────────────────────────────────────────
  static const Color brandPrimary = Color(0xFF2E7D32); // Green 700 - WCAG AA on cream
  static const Color brandPrimaryDark = Color(0xFF1B5E20);
  static const Color brandPrimaryLight = Color(0xFF4CAF50);
  static const Color brandPrimarySoft = Color(0xFFE8F5E9);
  static const Color brandSecondary = Color(0xFFF2B84B); // Amber 500
  static const Color brandSecondarySoft = Color(0xFFFCEFD0);
  static const Color brandAccent = Color(0xFFF26B3A); // Deep Orange 500
  static const Color brandAccentSoft = Color(0xFFFCE3D7);

  static const Color bgCream = Color(0xFFFBF7EF);
  static const Color textDark = Color(0xFF2B2118);
  static const Color surface = Color(0xFFFFFFFF);

  static const Color statusSuccess = Color(0xFF1B9E56); // Green 600
  static const Color statusWarning = Color(0xFFE8A33D); // Amber 600
  static const Color statusDanger = Color(0xFFD94436); // Red 600
  static const Color statusInfo = Color(0xFF2E7D32); // Green 700

  static const Color neutral50 = Color(0xFFFBF7EF);
  static const Color neutral100 = Color(0xFFF7F3E9);
  static const Color neutral200 = Color(0xFFE2D5C3);
  static const Color neutral300 = Color(0xFFC9B7A1);
  static const Color neutral400 = Color(0xFF8E7C68);
  static const Color neutral500 = Color(0xFF5A4A3A);

  static const Color darkBg = Color(0xFF1E1912);
  static const Color darkSurface = Color(0xFF2A231B);
  static const Color darkText = Color(0xFFF5F0E5);
  static const Color darkMuted = Color(0xFFB8A992);
  static const Color darkBorder = Color(0xFF3B3226);

  // ── Shadows ────────────────────────────────────────────────────────────
  static const Shadow shadowSoft = Shadow(
    color: Color(0x1A000000),
    offset: Offset(0, 4),
    blurRadius: 12,
  );
  static const Shadow shadowActive = Shadow(
    color: Color(0x1A2E7D4F),
    offset: Offset(0, 8),
    blurRadius: 20,
  );

  /// Bayangan lembut dua lapis (ambient + kontak) agar kartu terasa "mengambang".
  static List<BoxShadow> softShadow([double alpha = 0.06]) => [
        BoxShadow(
          color: textDark.withValues(alpha: alpha),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: textDark.withValues(alpha: 0.03),
          blurRadius: 3,
          offset: const Offset(0, 1),
        ),
      ];

  /// Cahaya berwarna di bawah tombol / elemen aktif.
  static List<BoxShadow> glow(Color c) => [
        BoxShadow(
          color: c.withValues(alpha: 0.32),
          blurRadius: 22,
          offset: const Offset(0, 10),
        ),
      ];

  static BoxDecoration cardDecoration({
    Color? color,
    double radius = 20,
    Gradient? gradient,
    List<BoxShadow>? shadows,
  }) {
    return BoxDecoration(
      color: gradient == null ? (color ?? surface) : null,
      gradient: gradient,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: shadows ?? softShadow(),
      border: Border.all(color: neutral200.withValues(alpha: 0.45), width: 1),
    );
  }

  static LinearGradient get primaryGradient => const LinearGradient(
        colors: [Color(0xFF4CAF50), Color(0xFF1B5E20)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get accentGradient => const LinearGradient(
        colors: [Color(0xFFF58455), Color(0xFFD9532A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get creamGradient => const LinearGradient(
        colors: [bgCream, neutral100],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  // ── Tipografi ──────────────────────────────────────────────────────────
  static TextStyle poppins({double? fontSize, FontWeight? weight, Color? color, double? height}) {
    return GoogleFonts.poppins(fontSize: fontSize, fontWeight: weight, color: color, height: height);
  }

  static TextStyle inter({double? fontSize, FontWeight? weight, Color? color, double? height}) {
    return GoogleFonts.inter(fontSize: fontSize, fontWeight: weight, color: color, height: height);
  }

  static TextTheme _textTheme(Color text, Color muted) => TextTheme(
        displayLarge: poppins(fontSize: 40, weight: FontWeight.w700, color: text),
        displayMedium: poppins(fontSize: 32, weight: FontWeight.w700, color: text),
        headlineMedium: poppins(fontSize: 24, weight: FontWeight.w600, color: text),
        titleLarge: poppins(fontSize: 20, weight: FontWeight.w600, color: text),
        titleMedium: poppins(fontSize: 18, weight: FontWeight.w500, color: text),
        bodyLarge: inter(fontSize: 16, weight: FontWeight.w400, color: text, height: 1.5),
        bodyMedium: inter(fontSize: 14, weight: FontWeight.w400, color: text, height: 1.5),
        bodySmall: inter(fontSize: 12, weight: FontWeight.w400, color: muted, height: 1.4),
        labelLarge: poppins(fontSize: 16, weight: FontWeight.w600, color: text),
      );

  static InputDecorationTheme _inputTheme(Color fill, Color border, Color focus, Color muted) {
    OutlineInputBorder b(Color c, [double w = 1.5]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: c, width: w),
        );
    return InputDecorationTheme(
      filled: true,
      fillColor: fill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: inter(fontSize: 14, color: muted.withValues(alpha: 0.7)),
      labelStyle: inter(fontSize: 14, color: muted),
      prefixIconColor: muted,
      border: b(border),
      enabledBorder: b(border),
      focusedBorder: b(focus, 2),
      errorBorder: b(statusDanger),
      focusedErrorBorder: b(statusDanger, 2),
    );
  }

  static ThemeData lightTheme(BuildContext context) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: bgCream,
      colorScheme: const ColorScheme.light(
        primary: brandPrimary,
        secondary: brandSecondary,
        surface: surface,
        onSurface: textDark,
      ),
      textTheme: _textTheme(textDark, neutral500),
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: bgCream,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        foregroundColor: textDark,
        titleTextStyle: poppins(fontSize: 20, weight: FontWeight.w600, color: textDark),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brandPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: poppins(fontSize: 16, weight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: brandPrimary,
          side: const BorderSide(color: brandPrimary, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: poppins(fontSize: 16, weight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.zero,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: textDark,
        contentTextStyle: inter(fontSize: 14, weight: FontWeight.w500, color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: brandPrimary),
      inputDecorationTheme: _inputTheme(surface, neutral200, brandPrimary, neutral400),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      colorScheme: const ColorScheme.dark(
        primary: brandPrimaryLight,
        secondary: brandSecondary,
        surface: darkSurface,
        onSurface: darkText,
      ),
      textTheme: _textTheme(darkText, darkMuted),
      appBarTheme: AppBarTheme(
        backgroundColor: darkBg,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        foregroundColor: darkText,
        titleTextStyle: poppins(fontSize: 20, weight: FontWeight.w600, color: darkText),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: _inputTheme(darkSurface, darkBorder, brandPrimaryLight, darkMuted),
    );
  }
}

/// Angka dengan lebar tetap (tabular) supaya nominal rapi sejajar.
/// [color] null → mengikuti warna teks tema (aman untuk mode gelap).
TextStyle tabularNumber({
  required double fontSize,
  FontWeight weight = FontWeight.w600,
  Color? color,
}) {
  return AppTheme.inter(
    fontSize: fontSize,
    weight: weight,
    color: color,
  ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
}

/// Teks dengan gradient
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Gradient? gradient;

  const GradientText({super.key, required this.text, required this.style, this.gradient});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => (gradient ?? AppTheme.primaryGradient).createShader(bounds),
      blendMode: BlendMode.srcIn,
      child: Text(text, style: style.copyWith(color: Colors.white)),
    );
  }
}
