// lib/widgets/message_custom.dart
import 'package:flutter/material.dart';

class MessageCustom extends StatelessWidget {
  final String username;
  final String lastmssg;
  final VoidCallback onTap;

  const MessageCustom({
    super.key,
    required this.username,
    required this.lastmssg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0XFFFAFBFA),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundImage: AssetImage(
                'assets/images/profil.png',
              ), // avatar par défaut
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastmssg,
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
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
