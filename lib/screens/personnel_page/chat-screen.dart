import 'package:flutter/material.dart';
import 'package:bricorasy/services/socket_service.dart';
import 'package:bricorasy/models/message_model.dart';

class Chatscreen extends StatefulWidget {
  const Chatscreen({super.key, required this.username, required this.receiver, this.img});
  final String username;
  final String receiver;
  final Image? img;

  @override
  State<Chatscreen> createState() => _ChatscreenState();
}

class _ChatscreenState extends State<Chatscreen> {
  final TextEditingController _controller = TextEditingController();
  List<Message> messages = [];

  @override
  void initState() {
    super.initState();

    // Connect socket
    final socketService = SocketService();
    socketService.connect();

    // Setup listeners
    socketService.onPreviousMessages = (data) {
      setState(() {
        messages = data
            .map((item) => Message.fromJson(item, item['sender'] == widget.username))
            .toList();
      });
    };

    socketService.onMessageReceived = (data) {
      final incoming = Message.fromJson(data, data['sender'] == widget.username);
      setState(() {
        messages.add(incoming);
      });
    };

    // Join chat to fetch previous messages
    socketService.joinChat(sender: widget.username, receiver: widget.receiver);
  }

  void sendMessage() {
    String text = _controller.text.trim();
    if (text.isNotEmpty) {
      final message = Message(
        content: text,
        sender: widget.username,
        receiver: widget.receiver,
        timestamp: DateTime.now(),
        isMe: true,
      );

      SocketService().sendMessage(message.toJson());

      setState(() {
        messages.add(message);
        _controller.clear();
      });
    }
  }

  Widget buildMessage(Message message) {
    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: message.isMe ? const Color(0xFF3D4C5E) : const Color(0xFFE5E5EA),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message.content,
          style: TextStyle(
            color: message.isMe ? Colors.white : Colors.black87,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    SocketService().dispose();
    _controller.dispose();
    super.dispose();
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
              onTap: () => Navigator.pop(context),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0XFF3D4C5E),
                  shape: BoxShape.circle,
                ),
                margin: const EdgeInsets.only(left: 10),
                padding: const EdgeInsets.all(6),
                child: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 18),
              ),
            ),
            const SizedBox(width: 20),
            ClipOval(
              child: widget.img ??
                  Image.asset(
                    'assets/images/profil.png',
                    width: 35,
                    height: 35,
                    fit: BoxFit.cover,
                  ),
            ),
            const SizedBox(width: 10),
            Text(
              widget.receiver,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(5),
        decoration: const BoxDecoration(color: Color(0XFFFAFBFA)),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: messages.length,
                reverse: false,
                itemBuilder: (context, index) => buildMessage(messages[index]),
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
