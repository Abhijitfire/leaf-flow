import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'color_schemes.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: lightColorScheme,
      // Force stark high-contrast text on all typography elements
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
        displayLarge: GoogleFonts.manrope(color: lightColorScheme.onSurface, fontWeight: FontWeight.w800, letterSpacing: -1.0),
        displayMedium: GoogleFonts.manrope(color: lightColorScheme.onSurface, fontWeight: FontWeight.w800, letterSpacing: -0.5),
        displaySmall: GoogleFonts.manrope(color: lightColorScheme.onSurface, fontWeight: FontWeight.bold),
        headlineMedium: GoogleFonts.manrope(color: lightColorScheme.onSurface, fontWeight: FontWeight.w900, letterSpacing: -0.5),
        titleLarge: GoogleFonts.manrope(color: lightColorScheme.onSurface, fontWeight: FontWeight.bold),
        titleMedium: GoogleFonts.manrope(color: lightColorScheme.onSurface, fontWeight: FontWeight.w700),
        bodyLarge: GoogleFonts.inter(color: lightColorScheme.onSurface, fontWeight: FontWeight.w500),
        bodyMedium: GoogleFonts.inter(color: lightColorScheme.onSurface),
        labelSmall: GoogleFonts.inter(color: lightColorScheme.onSurface, fontWeight: FontWeight.w600, letterSpacing: 1.2),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: lightColorScheme.surface,
        foregroundColor: lightColorScheme.onSurface,
        scrolledUnderElevation: 0,
      ),
      scaffoldBackgroundColor: lightColorScheme.surface,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(64, 56),
          elevation: 2,
          shadowColor: lightColorScheme.primary.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Rounded rectangle, not pill
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0, 
        color: lightColorScheme.surfaceContainerHighest, // Solid color, no opacity
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: lightColorScheme.outline.withValues(alpha: 0.2)), // Soft border for depth
        ),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightColorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: lightColorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: lightColorScheme.surface,
        indicatorColor: lightColorScheme.primaryContainer,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: lightColorScheme.onPrimaryContainer);
          }
          return IconThemeData(color: lightColorScheme.onSurfaceVariant);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(color: lightColorScheme.onSurface, fontWeight: FontWeight.bold);
          }
          return TextStyle(color: lightColorScheme.onSurfaceVariant);
        }),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: darkColorScheme,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.manrope(color: darkColorScheme.onSurface, fontWeight: FontWeight.w800, letterSpacing: -1.0),
        displayMedium: GoogleFonts.manrope(color: darkColorScheme.onSurface, fontWeight: FontWeight.w800, letterSpacing: -0.5),
        displaySmall: GoogleFonts.manrope(color: darkColorScheme.onSurface, fontWeight: FontWeight.bold),
        headlineMedium: GoogleFonts.manrope(color: darkColorScheme.onSurface, fontWeight: FontWeight.w900, letterSpacing: -0.5),
        titleLarge: GoogleFonts.manrope(color: darkColorScheme.onSurface, fontWeight: FontWeight.bold),
        titleMedium: GoogleFonts.manrope(color: darkColorScheme.onSurface, fontWeight: FontWeight.w700),
        bodyLarge: GoogleFonts.inter(color: darkColorScheme.onSurface, fontWeight: FontWeight.w500),
        bodyMedium: GoogleFonts.inter(color: darkColorScheme.onSurface),
        labelSmall: GoogleFonts.inter(color: darkColorScheme.onSurface, fontWeight: FontWeight.w600, letterSpacing: 1.2),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: darkColorScheme.surface,
        foregroundColor: darkColorScheme.onSurface,
        scrolledUnderElevation: 0,
      ),
      scaffoldBackgroundColor: darkColorScheme.surface,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(64, 56),
          elevation: 4,
          shadowColor: darkColorScheme.primary.withValues(alpha: 0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: darkColorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: darkColorScheme.outline.withValues(alpha: 0.2)),
        ),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkColorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: darkColorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkColorScheme.surface,
        indicatorColor: darkColorScheme.primaryContainer,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: darkColorScheme.onPrimaryContainer);
          }
          return IconThemeData(color: darkColorScheme.onSurfaceVariant);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(color: darkColorScheme.onSurface, fontWeight: FontWeight.bold);
          }
          return TextStyle(color: darkColorScheme.onSurfaceVariant);
        }),
      ),
    );
  }
}
