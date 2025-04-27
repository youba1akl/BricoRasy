import 'package:flutter/material.dart';
import 'package:bricorasy/screens/home/tools_list_screen.dart';  // ← correct import

class NavBarHome extends StatefulWidget {
  const NavBarHome({super.key});

  @override
  State<NavBarHome> createState() => _NavBarHomeState();
}

class _NavBarHomeState extends State<NavBarHome> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      width: double.infinity,
      margin: const EdgeInsets.only(top: 0, bottom: 10, left: 10, right: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            backgroundColor: const Color(0XFF999999),
            type: BottomNavigationBarType.fixed,
            iconSize: 0,
            selectedFontSize: 0,
            currentIndex: _selectedIndex == -1 ? 0 : _selectedIndex,
            onTap: (index) {
              if (index == 3) {
                // When "Objet" is tapped, push the actual ToolsListScreen:
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ToolsListScreen(),
                  ),
                );
              } else {
                // otherwise just update your selected index
                _onItemTapped(index);
              }
            },
            enableFeedback: false,
            items: [
              BottomNavigationBarItem(
                icon: Container(
                  height: 35,
                  width: double.infinity,
                  margin: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: _selectedIndex == 0
                        ? const Color(0XFFBFBFBF)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Tout',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  height: 35,
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 5, bottom: 5),
                  decoration: BoxDecoration(
                    color: _selectedIndex == 1
                        ? const Color(0XFFBFBFBF)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Bricole',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  height: 35,
                  width: double.infinity,
                  margin: const EdgeInsets.all(5),
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: _selectedIndex == 2
                        ? const Color(0XFFBFBFBF)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Professinel',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  height: 35,
                  width: double.infinity,
                  margin: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: _selectedIndex == 3
                        ? const Color(0XFFBFBFBF)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Objet',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                label: '',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
