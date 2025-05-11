import '../screens/personnel_page/chat-screen.dart';
import 'package:flutter/material.dart';

class MessageCustom extends StatefulWidget {
  const MessageCustom({super.key, this.username, this.lastmssg, this.img});
  final String? username;
  final String? lastmssg;
  final Image? img;

  @override
  State<MessageCustom> createState() => _MessageCustomState();
}

class _MessageCustomState extends State<MessageCustom> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Chatscreen(username: 'Aklil Youba'),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(5),
        height: 50,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Color(0XFFFAFBFA),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Flexible(
              flex: 1,
              child: ClipOval(
                child:
                    widget.img ??
                    Image.asset('assets/images/profil.png', fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 15),
            Flexible(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.username!,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.lastmssg!,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
