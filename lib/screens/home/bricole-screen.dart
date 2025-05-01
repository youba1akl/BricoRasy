import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

class Bricolescreen extends StatefulWidget {
  const Bricolescreen({
    super.key,
    this.username,
    this.img,
    this.title,
    this.loc,
    this.prix,
    this.description,
    this.chat,
  });

  final String? username;
  final Image? img;
  final String? title;
  final String? loc;
  final String? prix;
  final String? description;
  final Widget? chat;

  @override
  State<Bricolescreen> createState() => _BricolescreenState();
}

class _BricolescreenState extends State<Bricolescreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void scrollLeft() {
    _scrollController.animateTo(
      _scrollController.offset - MediaQuery.of(context).size.width,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void scrollRight() {
    _scrollController.animateTo(
      _scrollController.offset + MediaQuery.of(context).size.width,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void sendReport(String message) async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/api/reports'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "message": message,
        "annonceId": "ID_DE_L_ANNONCE", // à adapter
        "userId": "ID_UTILISATEUR", // facultatif
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Signalement envoyé")));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur d'envoi")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(color: Color(0XFFF3F6F4)),
          padding: EdgeInsets.all(5),
          child: Column(
            children: [
              // Partie image avec navigation horizontale
              Flexible(
                flex: 3,
                child: Stack(
                  children: [
                    Container(
                      margin: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: ListView(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                'assets/images/E02.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                'assets/images/E03.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Positioned(
                      top: 15,
                      left: 15,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.close,
                            size: 20,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 15,
                      right: 15,
                      child: GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            backgroundColor: Colors.white,
                            builder:
                                (context) => Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.share_outlined),
                                      title: const Text('Partager'),
                                      onTap: () {
                                        Navigator.pop(context);
                                        // Logique de partage
                                        Share.share(
                                          'Regarde cette annonce : [insère lien ou infos]',
                                        );
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(
                                        Icons.flag_outlined,
                                        color: Colors.red,
                                      ),
                                      title: const Text(
                                        'Signaler',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                      onTap: () {
                                        Navigator.pop(context);
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            TextEditingController
                                            _messageController =
                                                TextEditingController();

                                            return AlertDialog(
                                              title: const Text(
                                                'Signaler une annonce',
                                              ),
                                              content: TextField(
                                                controller: _messageController,
                                                maxLines: 4,
                                                decoration: const InputDecoration(
                                                  hintText:
                                                      'Décrivez le problème...',
                                                  border: OutlineInputBorder(),
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        context,
                                                      ),
                                                  child: const Text('Annuler'),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    final message =
                                                        _messageController.text
                                                            .trim();
                                                    if (message.isNotEmpty) {
                                                      // Envoie vers le backend
                                                      sendReport(message);
                                                      Navigator.pop(context);
                                                    }
                                                  },
                                                  child: const Text('Envoyer'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                          );
                        },

                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.keyboard_control,
                            size: 20,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 10,
                      top: MediaQuery.of(context).size.height * 0.2,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        ),
                        onPressed: scrollLeft,
                      ),
                    ),
                    Positioned(
                      right: 10,
                      top: MediaQuery.of(context).size.height * 0.2,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                        ),
                        onPressed: scrollRight,
                      ),
                    ),
                  ],
                ),
              ),

              // Infos sur l'annonce
              Flexible(
                flex: 4,

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.all(5),
                      padding: EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title ?? 'Titre inconnu',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            widget.description ?? 'Pas de description fournie.',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(5),
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 15,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Localisation',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Spacer(),
                          Text(
                            widget.loc ?? 'Localisation inconnue',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(5),
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 15,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            'Prix',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          const Spacer(),
                          const SizedBox(width: 5),
                          Text(
                            widget.prix ?? '0',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            'DZD',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Bas de page avec boutons
              Flexible(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 1,
                        spreadRadius: 0.25,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: ClipOval(
                          child:
                              widget.img ??
                              Image.asset(
                                'assets/images/profil.png',
                                fit: BoxFit.cover,
                              ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              widget.username ?? 'Utilisateur inconnu',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      // Logique d'appel
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: const BoxDecoration(
                                        color: Color(0XFF19A45F),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(20),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          Icon(
                                            Icons.phone,
                                            size: 18,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            'Appeler',
                                            style: TextStyle(
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      if (widget.chat != null) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => widget.chat!,
                                          ),
                                        );
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                          width: 2,
                                          color: Colors.black,
                                        ),
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(20),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          Icon(
                                            Icons.forum_outlined,
                                            size: 18,
                                            color: Colors.black,
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            'Message',
                                            style: TextStyle(
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
