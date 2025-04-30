import 'package:bricorasy/screens/personnel_page/chat-screen.dart';
import '../../widgets/custom_container_ann.dart';
import '../../widgets/nav_bar_home.dart';
import '../../widgets/searchBar.dart';
import 'package:flutter/material.dart';
import 'bricole-screen.dart';

class Homescreen extends StatelessWidget {
  const Homescreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.only(top: 15),
              decoration: const BoxDecoration(color: Color(0XFFF3F6F4)),
              child: ListView(
                padding: EdgeInsets.only(top: 15, left: 0, right: 0, bottom: 5),
                children: [
                  Searchbar(),
                  const SizedBox(height: 10),
                  NavBarHome(),
                  const SizedBox(height: 10),
                  CustomContainerAnn(
                    title: 'Nettoyage Maison',
                    description:
                        'je cherche a netoyer ma maison, si quelqu\'un est interesse',
                    localisation: 'Bejaia,Bejaia',
                    img: Image.asset('assets/images/E04.png'),
                    page: Bricolescreen(
                      chat: Chatscreen(username: 'Aklil Youba'),
                      img: Image.asset('assets/images/E04.png'),
                      loc: 'Bejaia',
                      prix: '2000',
                      title: 'Nettoyage Maiso',
                      username: 'Aklil Youba',
                      description:
                          'je cherche a netoyer maijosaioj oiisjoi édjiokédjoi djojikédjoi,k ioé&d maison, si quelqu\'un est interesse',
                    ),
                  ),
                  CustomContainerAnn(
                    title: 'Nettoyage Maison',
                    description:
                        'je cherche a netoyer maijosaioj oiisjoi édjiokédjoi djojikédjoi,k ioé&d maison, si quelqu\'un est interesse',
                    img: Image.asset('assets/images/E02.png'),
                    page: Bricolescreen(
                      chat: Chatscreen(username: 'Aklil Youba'),
                      loc: 'Bejaia',
                      prix: '2000',
                      title: 'Nettoyage Maiso',
                      username: 'Aklil Youba',
                      description:
                          'je cherche a netoyer maijosaioj oiisjoi édjiokédjoi djojikédjoi,k ioé&d maison, si quelqu\'un est interesse',
                    ),
                    localisation: 'Bejaia,Bejaia',
                  ),
                  CustomContainerAnn(
                    title: 'Nettoyage Maison',
                    description:
                        'je cherche a netoyer ma maison, si quelqu\'un est interesse',
                    localisation: 'Bejaia,Bejaia',
                    img: Image.asset('assets/images/E04.png'),
                    page: Bricolescreen(
                      chat: Chatscreen(username: 'Aklil Youba'),
                      img: Image.asset('assets/images/E04.png'),
                      loc: 'Bejaia',
                      prix: '2000',
                      title: 'Nettoyage Maison',
                      username: 'Aklil Youba',
                      description:
                          'je cherche a netoyer maijosaioj oiisjoi édjiokédjoi djojikédjoi,k ioé&d maison, si quelqu\'un est interesse',
                    ),
                  ),
                  CustomContainerAnn(
                    title: 'Nettoyage Maison',
                    description:
                        'je cherche a netoyer maijosaioj oiisjoi édjiokédjoi djojikédjoi,k ioé&d maison, si quelqu\'un est interesse',
                    img: Image.asset('assets/images/E02.png'),
                    page: Bricolescreen(
                      chat: Chatscreen(username: 'Aklil Youba'),
                      loc: 'Bejaia',
                      prix: '2000',
                      title: 'Nettoyage Maiso',
                      username: 'Aklil Youba',
                      description:
                          'je cherche a netoyer maijosaioj oiisjoi édjiokédjoi djojikédjoi,k ioé&d maison, si quelqu\'un est interesse',
                    ),
                    localisation: 'Bejaia,Bejaia',
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 60,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 2.0,
                    spreadRadius: 1.0,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
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
        ],
      ),
    );
  }
}
