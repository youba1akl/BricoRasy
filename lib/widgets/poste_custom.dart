import 'package:bricorasy/screens/artisan/comment-screen.dart';
import 'package:bricorasy/widgets/home_scaffold.dart';
import 'package:flutter/material.dart';

class PosteCustom extends StatefulWidget {
  const PosteCustom({super.key});

  @override
  State<PosteCustom> createState() => _PosteCustomState();
}

class _PosteCustomState extends State<PosteCustom> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 5),
      padding: EdgeInsets.all(5),
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(0XFF335090),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
            offset: const Offset(0, 1),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomeScaffold()),
              );
            },
            child: Container(
              height: 190,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(7),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: Image.asset('assets/images/work.png', fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(10),
                child: Row(
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {},
                          child: Icon(
                            Icons.favorite_border,
                            size: 25,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 3),
                        Text('59', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                    SizedBox(width: 10),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Commentscreen(),
                              ),
                            );
                          },
                          child: Icon(
                            Icons.mode_comment_outlined,
                            size: 25,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 3),
                        Text('20', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                    SizedBox(width: 7),
                    Row(
                      children: [
                        GestureDetector(
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
                                        leading: const Icon(
                                          Icons.bookmark_border,
                                        ),
                                        title: const Text('Saved'),
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                      ListTile(
                                        leading: const Icon(
                                          Icons.share_outlined,
                                        ),
                                        title: const Text('Partager'),
                                        onTap: () {
                                          Navigator.pop(context);
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
                                        },
                                      ),
                                    ],
                                  ),
                            );
                          },
                          child: Icon(
                            Icons.more_vert,
                            size: 25,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
