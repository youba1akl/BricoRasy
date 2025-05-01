import '../../widgets/message_custom.dart';
import '../../widgets/poste_custom.dart';
import 'package:flutter/material.dart';

class PersonnelScreen extends StatefulWidget {
  const PersonnelScreen({super.key});

  @override
  State<PersonnelScreen> createState() => _PersonnelScreenState();
}

class _PersonnelScreenState extends State<PersonnelScreen> {
  String currentView = 'messages';
  String userRole =
      'simple'; // Change cela pour 'client' selon l'utilisateur connecté

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
          Positioned.fill(
            top: 60,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(color: Color(0XFFFAFBFA)),
              padding: EdgeInsets.only(top: 8, left: 8, right: 8),
              child: Column(
                children: [
                  Row(
                    children: [
                      buildToggleButton('messages', 'Messages'),
                      const SizedBox(width: 5),
                      if (userRole == 'artisan') ...[
                        buildToggleButton('postes', 'Poste'),
                        const SizedBox(width: 5),
                      ],
                      buildToggleButton('annonces', 'Annonce'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (currentView == 'messages') ...[
                            const Text(
                              'Messages',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            MessageCustom(
                              img: Image.asset('assets/images/exemple.png'),
                              username: 'Aklil Youba',
                              lastmssg: 'nouveaux messages',
                            ),
                            MessageCustom(
                              username: 'Aklil Youba',
                              lastmssg: 'nouveaux messages',
                            ),
                            // Ajoute ici les autres messages
                          ] else if (currentView == 'postes' &&
                              userRole == 'artisan') ...[
                            const Text(
                              'Postes',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            PosteCustom(
                              img: Image.asset('assets/images/E02.png'),
                              aime: '30',
                              comment: '40',
                            ),
                            PosteCustom(
                              img: Image.asset('assets/images/E02.png'),
                              aime: '30',
                              comment: '40',
                            ),
                            // Ajoute ici les autres postes
                          ] else if (currentView == 'annonces') ...[
                            const Text(
                              'Annonces',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            PosteCustom(
                              img: Image.asset('assets/images/E02.png'),
                              aime: '30',
                              comment: '40',
                            ),
                            PosteCustom(
                              img: Image.asset('assets/images/E02.png'),
                              aime: '30',
                              comment: '40',
                            ),
                            // Ajoute ici les autres annonces
                          ],
                        ],
                      ),
                    ),
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
                'My Activity',
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
