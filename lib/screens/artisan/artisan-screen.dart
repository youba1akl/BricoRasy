import 'dart:convert';
import 'package:bricorasy/models/artisan.model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:bricorasy/screens/artisan/artisan-profil-screen.dart';
import '../../widgets/custom_container_artisan.dart';
import '../../widgets/nav_bar_artisan.dart';
import '../../widgets/searchBar.dart';

class Artisantscreen extends StatefulWidget {
  const Artisantscreen({super.key});

  @override
  State<Artisantscreen> createState() => _ArtisantscreenState();
}

class _ArtisantscreenState extends State<Artisantscreen> {
  List<Artisan> artisans = [];

  @override
  void initState() {
    super.initState();
    loadArtisans();
  }

  Future<void> loadArtisans() async {
    final String response = await rootBundle.loadString(
      'assets/json/artisan.json',
    );
    final List<dynamic> data = json.decode(response);
    setState(() {
      artisans = data.map((e) => Artisan.fromJson(e)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Color(0XFFFAFBFA)),
      child: ListView(
        padding: EdgeInsets.only(top: 10,bottom: 5),
        children: [
          const Searchbar(),
          const NavBarArtisan(),
          ...artisans.map((artisan) {
            return CustomContainerArtisan(
              fullname: artisan.fullname,
              job: artisan.job,
              localisation: artisan.adress,
              rating: artisan.rating,
              img: Image.asset(artisan.image),
              page: Artisanprofilscreen(
                username: artisan.fullname,
                job: artisan.job,
                like: artisan.like,
                loc: artisan.adress,
                rating: artisan.rating,
                img: Image.asset(artisan.image),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
