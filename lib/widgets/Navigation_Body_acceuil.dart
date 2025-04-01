import 'package:flutter/material.dart';

class NavigationBodyAcceuil extends StatefulWidget {
  const NavigationBodyAcceuil({super.key});

  @override
  State<NavigationBodyAcceuil> createState() => _NavigationBodyAcceuilState();
}

class _NavigationBodyAcceuilState extends State<NavigationBodyAcceuil> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62.5,
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(2),
      child: ClipRRect(
        borderRadius:BorderRadius.circular(12),
        child: BottomNavigationBar(
          backgroundColor: const Color.fromARGB(255, 217, 231, 238),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: SizedBox.shrink(), label: "Tout"),
            BottomNavigationBarItem(icon: SizedBox.shrink(), label: "Bricole"),
            BottomNavigationBarItem(
              icon: SizedBox.shrink(),
              label: "Professionnel",
            ),
            BottomNavigationBarItem(icon: SizedBox.shrink(), label: "Article"),
          ],
        ),
      ),
    );
  }
}
