// lib/main.dart
import 'package:bricorasy/theme/theme_provider.dart';
import 'package:bricorasy/theme/theme.dart' as app_theme;
import 'package:bricorasy/screens/sign_page/welcome-screen.dart'; // Your initial screen
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Good practice
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context); 

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BricoRasy',
      themeMode: themeProvider.themeMode,
      theme: app_theme.lightMode,       // From your theme.dart
      darkTheme: app_theme.darkMode,    // From your theme.dart
      home: const Welcomescreen(),
    );
  }
}