import 'package:bricorasy/screens/home/bricole-screen.dart';
import 'package:bricorasy/screens/home/pro-screen.dart';
import 'package:bricorasy/widgets/custom_container_ann.dart';
import 'package:bricorasy/widgets/nav_bar_home.dart';
import 'package:bricorasy/widgets/searchBar.dart';
import 'package:flutter/material.dart';

class Homescreen extends StatelessWidget {
  const Homescreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 80,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color.fromARGB(242, 248, 248, 248),
              ),
              padding: EdgeInsets.only(bottom: 15),
              child: const Text(
                'Welcome to BricoRasy',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: ListView(
                children: [
                  Searchbar(),
                  NavBarHome(),
                  CustomContainerAnn(
                    title: 'Nettoyage Maison',
                    description:
                        'je cherche a netoyer ma maison, si quelqu\'un est interesse',
                    localisation: 'Bejaia,Bejaia',
                    page: BricoleScreen(),
                  ),
                  CustomContainerAnn(
                    title: 'Nettoyage Maison',
                    description:
                        'je cherche a netoyer maijosaioj oiisjoi édjiokédjoi djojikédjoi,k ioé&d  maison, si quelqu\'un est interesse',
                    localisation: 'Bejaia,Bejaia',
                    page: Proscreen(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
