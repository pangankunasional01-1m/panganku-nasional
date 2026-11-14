import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// GoPay-style color palette for Pangan app
class GoPayColors {
  // Singleton pattern
  static final GoPayColors _instance = GoPayColors._internal();
  factory GoPayColors() => _instance;
  GoPayColors._internal();

  // Brand colors (adapted from DESIGN_SYSTEM)
  final Color brandPrimary = const Color(0xFF2E7D4F); // Dark green
  final Color brandSecondary = const Color(0xFFF2B84B); // Gold
  final Color brandAccent = const Color(0xFFF26B3A); // Orange accent
  final Color brandLightGreen = const Color(0xFFC8E6C9); // Light green for backgrounds
  final Color brandLightGold = const Color(0xFFFFF3E0); // Light gold for surfaces

  // Neutral colors
  final Color neutral100 = const Color(0xFFF7F3E9);
  final Color neutral200 = const Color(0xFFE2D5C3);
  final Color neutral300 = const Color(0xFFC9B7A1);
  final Color neutral400 = const Color(0xFF8E7C68);
  final Color neutral500 = const Color(0xFF5A4A3A);
  final Color onPrimary = const Color(0xFFFFFFFF); // White on primary

  // Status colors
  final Color statusSuccess = const Color(0xFF1B9E56);
  final Color statusWarning = const Color(0xFFE8A33D);
  final Color statusDanger = const Color(0xFFD94436);
  final Color statusInfo = const Color(0xFF2E7D4F);

  // UI colors
  final Color textDark = const Color(0xFF2B2118);
  final Color textBody = const Color(0xFF2B2118);
  final Color textSecondary = const Color(0xFF5A4A3A);
  final Color textTertiary = const Color(0xFF8E7C68);
  final Color bgCream = const Color(0xFFFBF7EF);
  final Color surfaceWhite = const Color(0xFFFFFFFF);
  final Color dividerLight = const Color(0xFFE0E0E0);
}

/// Extension for GoPay colors on ThemeData
extension GoPayColorScheme on ThemeData {
  ColorScheme get goPayScheme => ColorScheme(
brightness: Brightness.light,
      primary: GoPayColors().brandPrimary,
      onPrimary: GoPayColors().onPrimary,
      secondary: GoPayColors().brandSecondary,
      onSecondary: GoPayColors().brandPrimary,
      surface: GoPayColors().bgCream,
      onSurface: GoPayColors().textDark,
      error: GoPayColors().statusDanger,
      onError: GoPayColors().onPrimary,
    );
}

/// GoPay-style text theme
class GoPayTextTheme {
  // Poppins - Display/Headings
  static TextStyle displayLarge() => GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: GoPayColors().textDark,
      );

  static TextStyle displayMedium() => GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: GoPayColors().textDark,
      );

  static TextStyle headlineSmall() => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: GoPayColors().textDark,
      );

  // Inter - Body text
  static TextStyle bodyLarge() => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: GoPayColors().textBody,
      );

  static TextStyle bodyMedium() => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: GoPayColors().textSecondary,
      );

  static TextStyle bodySmall() => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: GoPayColors().textTertiary,
      );

  // Big numbers - Tabular figures
  static TextStyle bigNumber() => GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: GoPayColors().brandPrimary,
        fontFeatures: [FontFeature.tabularFigures()],
      );

  static TextStyle bigNumberSmall() => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: GoPayColors().brandPrimary,
        fontFeatures: [FontFeature.tabularFigures()],
      );

  // Button text
  static TextStyle buttonLarge() => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: GoPayColors().onPrimary,
      );

  static TextStyle buttonSmall() => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: GoPayColors().onPrimary,
      );
}

/// Shadow styles for GoPay-inspired UI
class GoPayShadows {
  static BoxShadow cardShadow() => BoxShadow(
        color: Colors.black.withValues(alpha: 0.04),
        blurRadius: 8,
        offset: const Offset(0, 2),
      );

  static BoxShadow cardElevated() => BoxShadow(
        color: Colors.black.withValues(alpha: 0.08),
        blurRadius: 12,
        offset: const Offset(0, 4),
      );

  static BoxShadow buttonShadow() => BoxShadow(
        color: GoPayColors().brandPrimary.withValues(alpha: 0.15),
        blurRadius: 6,
        offset: const Offset(0, 2),
      );
}

/// Border radius utilities
class GoPayRadius {
  static const double small = 8.0;
  static const double medium = 12.0;
  static const double card = 16.0;
  static const double pill = 20.0;
  static const double header = 32.0;
  static const double circle = 28.0;
}

/// GoPay gradient decoration for headers
BoxDecoration goPayGradientHeader() => BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [GoPayColors().brandPrimary, GoPayColors().brandSecondary],
        stops: [0.0, 0.6],
      ),
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(GoPayRadius.header)),
    );

/// Subtle texture/pattern for GoPay header background
BoxDecoration goPaySubtlePattern() => BoxDecoration(
      color: GoPayColors().brandPrimary,
    );

/// Extension to access GoPayColors from BuildContext
extension GoPayContext on BuildContext {
  GoPayColors get goPayColors => GoPayColors();
}