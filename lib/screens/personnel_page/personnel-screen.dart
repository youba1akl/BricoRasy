import 'package:bricorasy/widgets/poste_custom.dart';
import 'package:flutter/material.dart';

class PersonnelScreen extends StatefulWidget {
  const PersonnelScreen({super.key});

  @override
  State<PersonnelScreen> createState() => _PersonnelScreenState();
}

class _PersonnelScreenState extends State<PersonnelScreen> {
  String currentView = 'messages';

  void toggleView(String view) {
    setState(() {
      currentView = view;
    });
  }

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
                'My Activity',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Contenu principal
          Positioned.fill(
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
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  Row(
                    children: [
                      buildToggleButton('messages', 'Messages'),
                      const SizedBox(width: 5),
                      buildToggleButton('postes', 'Poste'),
                      const SizedBox(width: 5),
                      buildToggleButton('annonces', 'Annonce'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          if (currentView == 'messages') ...[
                            PosteCustom(),
                            PosteCustom(),
                            PosteCustom(),
                            PosteCustom(),
                            PosteCustom(),
                            PosteCustom(),
                            PosteCustom(),
                            PosteCustom(),
                          ] else if (currentView == 'postes') ...[
                            PosteCustom(),
                            PosteCustom(),
                            PosteCustom(),
                            PosteCustom(),
                            PosteCustom(),
                            PosteCustom(),
                            PosteCustom(),
                            PosteCustom(),
                          ] else if (currentView == 'annonces') ...[
                            PosteCustom(),
                            PosteCustom(),
                            PosteCustom(),
                            PosteCustom(),
                            PosteCustom(),
                            PosteCustom(),
                            PosteCustom(),
                            PosteCustom(),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Bouton dynamique
  Widget buildToggleButton(String viewKey, String label) {
    bool isSelected = currentView == viewKey;
    return Expanded(
      child: GestureDetector(
        onTap: () => toggleView(viewKey),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0XFF102542) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(width: 1.5, color: const Color(0XFF102542)),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0XFF102542),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
