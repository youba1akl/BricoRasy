import 'package:flutter/material.dart';

const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0XFF416FDF),
  onPrimary: Color(0Xffffffff),
  secondary: Color(0XFF6EAEE7),
  onSecondary: Color(0XFFFFFFFF),
  error: Color(0XFFBA1A1A),
  onError: Color(0XFFFFFFFF),
  background: Color(0XFFFCFDF6),
  onBackground: Color(0XFF1A1C18),
  shadow: Color(0XFF000000),
  outlineVariant: Color(0XFFC2C8BC),
  surface: Color(0XFFF9FAF3),
  onSurface: Color(0XFF1A1C18),
);

const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0XFF416FDF),
  onPrimary: Color(0XFFFFFFFF),
  secondary: Color(0XFF6EAEE7),
  onSecondary: Color(0XFFFFFFFF),
  error: Color(0XFFBA1A1A),
  onError: Color(0XFFFFFFFF),
  background: Color(0XFFFCFDF6),
  onBackground: Color(0XFF1A1C18),
  shadow: Color(0XFF000000),
  outlineVariant: Color(0XFFC2C8BC),
  surface: Color(0XFFF9FAF3),
  onSurface: Color(0XFF1A1C18),
);

ThemeData lightMode = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: lightColorScheme,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(lightColorScheme.primary),
      foregroundColor: 
      MaterialStateProperty.all<Color>(Colors.white),
      elevation: MaterialStateProperty.all<double>(5.0),
      padding: MaterialStateProperty.all<EdgeInsets>(
        const EdgeInsets.symmetric(horizontal: 20,vertical: 18)
      ),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
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
  colorScheme: darkColorScheme,
);