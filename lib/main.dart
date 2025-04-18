import 'package:bricorasy/screens/artisan/artisan-profil-screen.dart';
import 'package:bricorasy/screens/artisan/comment-screen.dart';
import 'package:bricorasy/screens/sign_page/welcome-screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Welcomescreen(),
    );
  }
}
