import 'package:bricorasy/widgets/custom_container_artisan.dart';
import 'package:bricorasy/widgets/nav_bar_artisan.dart';
import 'package:bricorasy/widgets/searchBar.dart';
import 'package:flutter/material.dart';

class Artisantscreen extends StatelessWidget {
  const Artisantscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Color(0XFFFFFFFF)),
      child: ListView(
        children: [
          Searchbar(),
          NavBarArtisan(),
          CustomContainerArtisan(
            fullname: 'aklil Youba',
            job: 'Developper Web',
            localisation: 'Bejaia',
          ),
          CustomContainerArtisan(
            fullname: 'Aklil Youba',
            job: 'Developper web',
            localisation: 'Bejaia',
          ),
          CustomContainerArtisan(
            fullname: 'Aklil youba',
            job: 'Developper Web',
            localisation: 'bejaia',
          ),
        ],
      ),
    );
  }
}
