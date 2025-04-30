import 'package:flutter/material.dart';
import '../screens/add_anno/add-anno-screen.dart';
import '../screens/artisan/artisan-screen.dart';
import '../screens/home/home-screen.dart';
import '../screens/personnel_page/personnel-screen.dart';
import '../screens/profil_page/profil-screen.dart';

class HomeScaffold extends StatefulWidget {
  const HomeScaffold({super.key});
  @override
  _HomeScaffoldState createState() => _HomeScaffoldState();
}

class _HomeScaffoldState extends State<HomeScaffold> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    const Homescreen(),
    const Artisantscreen(),
    const AddAnnoScreen(),
    const PersonnelScreen(),
    Profilscreen(username: 'Aklil Youba', job: 'Developper Web'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _pages[_selectedIndex]),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0XFFFFFFFF),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
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
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(5, (index) {
            IconData iconData;
            IconData outlinedIcon;

            switch (index) {
              case 0:
                iconData = Icons.home;
                outlinedIcon = Icons.home_outlined;
                break;
              case 1:
                iconData = Icons.manage_accounts;
                outlinedIcon = Icons.manage_accounts_outlined;
                break;
              case 2:
                iconData = Icons.add_box;
                outlinedIcon = Icons.add_box_outlined;
                break;
              case 3:
                iconData = Icons.layers;
                outlinedIcon = Icons.layers_outlined;
                break;
              case 4:
              default:
                iconData = Icons.person;
                outlinedIcon = Icons.person_outline;
                break;
            }

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = index;
                });
                _onItemTapped(index);
              },
              child: Icon(
                _selectedIndex == index ? iconData : outlinedIcon,
                color: _selectedIndex == index ? Colors.black : Colors.grey,
                size: 30,
              ),
            );
          }),
        ),
      ),
    );
  }
}
