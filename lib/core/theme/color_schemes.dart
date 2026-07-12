import 'package:flutter/material.dart';

// Top Dribbble AgTech Inspiration:
// Primary: Deep Forest Green (Stability, Nature)
// Secondary/Accent: Vibrant Emerald/Lime (Action, Health, Progress)
// Surfaces: Clean Whites / Obsidian Dark Mode

const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF2C4A3B), // Deep Olive
  onPrimary: Color(0xFFF4F1EA), // Natural Beige
  primaryContainer: Color(0xFF88A65E), // Tea Green
  onPrimaryContainer: Color(0xFF1A2016),
  
  secondary: Color(0xFF88A65E), // Tea Green
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFF0F4ED), // Light Moss
  onSecondaryContainer: Color(0xFF2C4A3B),
  
  tertiary: Color(0xFFA3B8B8), // Morning Fog
  onTertiary: Color(0xFF111111),
  tertiaryContainer: Color(0xFFE2E8E8),
  onTertiaryContainer: Color(0xFF2C4A3B),
  
  error: Color(0xFFE05244), // Vibrant Coral
  onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFFFADCD9),
  onErrorContainer: Color(0xFF5E1B1B),
  
  surface: Color(0xFFFFFFFF), // Stark White
  onSurface: Color(0xFF111111), // Stark dark text
  
  surfaceContainerHighest: Color(0xFFF0F4ED), // Light Moss for cards
  onSurfaceVariant: Color(0xFF485440), // Sage grey for subtitles
  
  outline: Color(0xFFA3B8B8), // Morning Fog outline
  shadow: Color(0xFF000000),
);

const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFF88A65E), // Tea Green for primary text/buttons in dark mode
  onPrimary: Color(0xFF2C3A1E), 
  primaryContainer: Color(0xFF2C4A3B), // Deep Olive
  onPrimaryContainer: Color(0xFFF4F1EA),
  
  secondary: Color(0xFFA3B8B8), // Morning Fog
  onSecondary: Color(0xFF1A2016),
  secondaryContainer: Color(0xFF3D4C2F), // Dark leafy green 
  onSecondaryContainer: Color(0xFFF0F4ED),
  
  tertiary: Color(0xFFF4F1EA), // Natural Beige
  onTertiary: Color(0xFF4C3610),
  tertiaryContainer: Color(0xFFD6A754),
  onTertiaryContainer: Color(0xFFFFFFFF),
  
  error: Color(0xFFF7D9D9),
  onError: Color(0xFF5E1B1B),
  errorContainer: Color(0xFFE05244),
  onErrorContainer: Color(0xFFFFFFFF),
  
  surface: Color(0xFF111111), // Stark dark background
  onSurface: Color(0xFFF4F1EA), // Natural Beige text
  
  surfaceContainerHighest: Color(0xFF1A2016), // Very dark olive for cards
  onSurfaceVariant: Color(0xFFA3B8B8), // Morning Fog for subtitles
  
  outline: Color(0xFF485440),
  shadow: Color(0xFF000000),
);
