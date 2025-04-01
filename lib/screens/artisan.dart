import 'package:bricorasy/widgets/body_navbar_artisan.dart';
import 'package:bricorasy/widgets/customScaffold_artisan.dart';
import 'package:bricorasy/widgets/searchBar.dart';
import 'package:flutter/material.dart';

class Artisan extends StatefulWidget {
  const Artisan({super.key});

  @override
  State<Artisan> createState() => _ArtisanState();
}

class _ArtisanState extends State<Artisan> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text("Welcom to BricoRasy")),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Searchbar(),
          body_navbar_artisan(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(10),
              children: [
                customScaffold_artisan(),
                customScaffold_artisan(),
                customScaffold_artisan(),
                customScaffold_artisan(),
                customScaffold_artisan(),
                customScaffold_artisan(),
                customScaffold_artisan(),
                customScaffold_artisan(),
                customScaffold_artisan(),
                customScaffold_artisan(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
