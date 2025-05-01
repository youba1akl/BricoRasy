import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rechercher un service'),
        backgroundColor: Colors.lightBlue,
      ),
      body: Center(
        child: Text('Écran de recherche prêt!'),
      ),
    );
  }
}
