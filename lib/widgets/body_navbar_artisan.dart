import 'package:flutter/material.dart';

class body_navbar_artisan extends StatefulWidget {
  const body_navbar_artisan({super.key});

  @override
  State<body_navbar_artisan> createState() => _body_navbar_artisanState();
}

class _body_navbar_artisanState extends State<body_navbar_artisan> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62.5,
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BottomNavigationBar(
          backgroundColor: const Color.fromARGB(255, 217, 231, 238),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: SizedBox.shrink(), label: "Tout"),
            BottomNavigationBarItem(
              icon: SizedBox.shrink(),
              label: "Bien Note",
            ),
            BottomNavigationBarItem(icon: SizedBox.shrink(), label: "Mal Note"),
          ],
        ),
      ),
    );
  }
}
