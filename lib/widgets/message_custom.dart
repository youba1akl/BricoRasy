import 'package:bricorasy/screens/personnel_page/chat-screen.dart';
import 'package:flutter/material.dart';

class MessageCustom extends StatefulWidget {
  const MessageCustom({super.key});

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
          MaterialPageRoute(builder: (context) => Chatscreen()),
        );
      },
      child: Container(
        padding: EdgeInsets.all(5),
        height: 90,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Flexible(
              flex: 1,
              child: ClipOval(
                child: Image.asset(
                  'assets/images/exemple.png',
                  fit: BoxFit.cover,
                ),
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
                    'Aklil Youba',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'nouveaux messages',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
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
