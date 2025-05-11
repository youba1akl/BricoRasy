// lib/theme/theme.dart
import 'package:flutter/material.dart';

const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0XFF416FDF), // Original Blue
  onPrimary: Color(0Xffffffff),
  // You'll likely want to define these for your filter bar as per previous discussions
  // For example, if you want the lilac selected filter:
  primaryContainer: Color(0xFFEDE7F6),
  onPrimaryContainer: Color(0xFF3B3B58),
  // If primaryContainer/onPrimaryContainer are not set, Flutter will derive them.

  secondary: Color(0XFF6EAEE7),
  onSecondary: Color(0XFFFFFFFF),
  error: Color(0XFFBA1A1A),
  onError: Color(0XFFFFFFFF),
  shadow: Color(0XFF000000),
  outlineVariant: Color(0XFFC2C8BC),
  surface: Color(0XFFF9FAF3),
  onSurface: Color(0XFF1A1C18),
);

// IMPORTANT: Your original darkColorScheme was a copy of light.
// You MUST define actual dark theme colors here for it to look like a dark theme.
const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0XFF416FDF), // Example: Keep blue, or choose a dark theme appropriate primary
  onPrimary: Color(0XFFFFFFFF),

  // Define dark mode equivalents for filter bar if needed
  // primaryContainer: Color(0xFF3B3B58), // Example: Darker purple/blue for selected filter BG
  // onPrimaryContainer: Color(0xFFEDE7F6), // Example: Light text

  secondary: Color(0XFF6EAEE7), // Or dark theme equivalent
  onSecondary: Color(0XFFFFFFFF),
  error: Color(0xFFCF6679), // Darker error
  onError: Color(0xFF000000), // Light text on dark background
  shadow: Color(0xFF000000),
  outlineVariant: Color(0xFF4A4A4A), // Darker outline
  surface: Color(0xFF1E1E1E), // Dark surface for cards
  onSurface: Color(0xFFE1E1E1), // Light text on dark surfaces
);

ThemeData lightMode = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: lightColorScheme,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all<Color>(lightColorScheme.primary), // Uses the blue
      foregroundColor:
      WidgetStateProperty.all<Color>(Colors.white),
      elevation: WidgetStateProperty.all<double>(5.0),
      padding: WidgetStateProperty.all<EdgeInsets>(
        const EdgeInsets.symmetric(horizontal: 20,vertical: 18)
      ),
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        )
      ),
    )
  )
);

ThemeData darkMode = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: darkColorScheme, // Uses the (hopefully now distinct) darkColorScheme
  // Define elevatedButtonTheme for dark mode if needed
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all<Color>(darkColorScheme.primary),
      foregroundColor: WidgetStateProperty.all<Color>(darkColorScheme.onPrimary),
      // ... other button properties
    )
  )
);