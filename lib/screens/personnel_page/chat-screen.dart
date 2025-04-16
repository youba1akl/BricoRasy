import 'package:flutter/material.dart';

class Chatscreen extends StatefulWidget {
  const Chatscreen({super.key});

  @override
  State<Chatscreen> createState() => _ChatscreenState();
}

class _ChatscreenState extends State<Chatscreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> messages = [
    {"text": "Salut !", "isMe": false},
    {"text": "Salut, ça va ?", "isMe": true},
    {"text": "Oui, bien et toi ?", "isMe": false},
  ];

  void sendMessage() {
    String text = _controller.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        messages.add({"text": text, "isMe": true});
        _controller.clear();
      });
    }
  }

  Widget buildMessage(String text, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF3D4C5E) : const Color(0xFFE5E5EA),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black87,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0XFF3D4C5E),
                  shape: BoxShape.circle,
                ),
                margin: const EdgeInsets.only(left: 5),
                padding: const EdgeInsets.all(6),
                child: const Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 20),
            ClipOval(
              child: Image.asset(
                'assets/images/exemple.png',
                width: 35,
                height: 35,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              "Aklil Youba",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: messages.length,
                reverse: false,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return buildMessage(message["text"], message["isMe"]);
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F1F1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: "Écrire un message...",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF3D4C5E),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: sendMessage,
                      icon: const Icon(Icons.send, color: Colors.white),
                    ),
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