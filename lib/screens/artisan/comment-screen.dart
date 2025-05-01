import '../../widgets/message_custom.dart';
import 'package:flutter/material.dart';

class Commentscreen extends StatefulWidget {
  const Commentscreen({super.key, this.like, this.comment});
  final String? like;
  final String? comment;

  @override
  State<Commentscreen> createState() => _CommentscreenState();
}

class _CommentscreenState extends State<Commentscreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: Colors.white,
          centerTitle: true,
          title: const Text(
            'Poste',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close, color: Color(0XFF3D4C5E), size: 25),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(color: Color(0XFFF3F6F4)),
          child: Column(
            children: [
              Container(
                height: 250,
                decoration: const BoxDecoration(color: Color(0XFFFAFBFA)),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Image.asset(
                      'assets/images/E01.png',
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.cover,
                    ),
                    Image.asset(
                      'assets/images/E02.png',
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.cover,
                    ),
                    Image.asset(
                      'assets/images/E03.png',
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),

              // Boutons like / comment / more
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Icon(Icons.favorite_border, size: 25, color: Colors.black),
                    const SizedBox(width: 5),
                    Text(widget.like!),
                    const SizedBox(width: 15),
                    Icon(
                      Icons.mode_comment_outlined,
                      size: 25,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 5),
                    Text(widget.comment!),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          builder:
                              (context) => Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: Icon(Icons.bookmark_border),
                                    title: Text('Saved'),
                                    onTap: () => Navigator.pop(context),
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.share_outlined),
                                    title: Text('Partager'),
                                    onTap: () => Navigator.pop(context),
                                  ),
                                  ListTile(
                                    leading: Icon(
                                      Icons.flag_outlined,
                                      color: Colors.red,
                                    ),
                                    title: Text(
                                      'Signaler',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    onTap: () => Navigator.pop(context),
                                  ),
                                ],
                              ),
                        );
                      },
                      child: Icon(Icons.more_vert, color: Colors.black),
                    ),
                  ],
                ),
              ),

              // Liste de commentaires
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  children: [
                    MessageCustom(
                      img: Image.asset('assets/images/exemple.png'),
                      username: 'Aklil Youba',
                      lastmssg: 'nouveaux messages',
                    ),
                    MessageCustom(
                      username: 'Aklil Youba',
                      lastmssg: 'nouveaux messages',
                    ),
                    MessageCustom(
                      img: Image.asset('assets/images/exemple.png'),
                      username: 'Aklil Youba',
                      lastmssg: 'nouveaux messages',
                    ),
                    MessageCustom(
                      username: 'Aklil Youba',
                      lastmssg: 'nouveaux messages',
                    ),
                  ],
                ),
              ),

              // Zone d'écriture
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F1F1),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const TextField(
                          decoration: InputDecoration(
                            hintText: "Écrire un commentaire...",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0XFF102542),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: () {
                          // Envoyer le commentaire
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
