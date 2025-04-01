import 'package:bricorasy/widgets/Navigation_Body_acceuil.dart';
import 'package:bricorasy/widgets/custom_container.dart';
import 'package:bricorasy/widgets/searchBar.dart';
import 'package:flutter/material.dart';

//custom container contient les contenaires pour les differentes annonces
//navigationbody : pour la bar de navigation
//searchbar :tban

class CurrencyConverter extends StatefulWidget {
  const CurrencyConverter({super.key});

  @override
  State<CurrencyConverter> createState() => _CurrencyConverterState();
}

class _CurrencyConverterState extends State<CurrencyConverter> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text("Welcom to BricoRasy")),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Searchbar(),
          NavigationBodyAcceuil(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(10),
              children: [
                first_screen_containers(),
                first_screen_containers(),
                first_screen_containers(),
                first_screen_containers(),
                first_screen_containers(),
                first_screen_containers(),
                first_screen_containers(),
                first_screen_containers(),
                first_screen_containers(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
