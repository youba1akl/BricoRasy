// lib/screens/personnel_page/chat-screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart';
import 'package:bricorasy/services/auth_services.dart';
import 'package:bricorasy/services/socket_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final String API_BASE_URL = dotenv.env['API_BASE_URL']!;

class Chatscreen extends StatefulWidget {
  final String username;
  final String peerId;
  final String annonceId;
  final String? initialMessage; // ← new

  const Chatscreen({
    super.key,
    required this.username,
    required this.peerId,
    required this.annonceId,
    this.initialMessage, // ← new
  });

  @override
  State<Chatscreen> createState() => _ChatscreenState();
}

class _ChatscreenState extends State<Chatscreen> {
  late Socket socket;
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> messages = [];
  bool _loadingHistory = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    socket = SocketService.socket;
    socket.emit('joinAnnonce', widget.annonceId);

    // If there is an initialMessage, send it right away:
    if (widget.initialMessage != null &&
        widget.initialMessage!.trim().isNotEmpty) {
      // wait a frame so context is available
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendText(widget.initialMessage!);
      });
    }

    socket.on('connect_error', (err) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur socket: $err'),
          backgroundColor: Colors.red,
        ),
      );
    });
    _loadHistory();
    socket.on('newMessage', (data) {
      if (data['annonceId'] == widget.annonceId) {
        setState(() {
          messages.add({
            'text': data['content'],
            'isMe': data['from'] == AuthService.currentUserId,
          });
        });
      }
    });
  }

  Future<void> _loadHistory() async {
    setState(() => _loadingHistory = true);
    try {
      final resp = await http.get(
        Uri.parse(
          '$API_BASE_URL/api/messages/${widget.annonceId}/${widget.peerId}',
        ),
        headers: AuthService.authHeader,
      );
      if (resp.statusCode == 200) {
        final List<dynamic> hist = jsonDecode(resp.body);
        setState(() {
          messages =
              hist
                  .map(
                    (m) => {
                      'text': m['content'] ?? '',
                      'isMe': m['from'] == AuthService.currentUserId,
                    },
                  )
                  .toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erreur ${resp.statusCode} au chargement de l’historique',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur réseau: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _loadingHistory = false);
    }
  }

  Future<void> _sendText(String text) async {
    if (text.trim().isEmpty) return;
    setState(() => _sending = true);
    try {
      // 1) Persist to backend
      final resp = await http.post(
        Uri.parse('$API_BASE_URL/api/messages'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
        body: jsonEncode({
          'annonceId': widget.annonceId,
          'to': widget.peerId,
          'content': text,
        }),
      );
      if (resp.statusCode != 201) {
        final error = jsonDecode(resp.body)['message'] ?? 'Erreur inattendue';
        throw error;
      }
      // 2) Add locally
      setState(() {
        messages.add({'text': text, 'isMe': true});
      });
      // 3) Notify peer via socket
      socket.emit('sendMessage', {
        'annonceId': widget.annonceId,
        'toUserId': widget.peerId,
        'content': text,
      });
      // clear input if it came from the user
      if (widget.initialMessage == null) {
        _controller.clear();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Échec envoi : $e')));
    } finally {
      setState(() => _sending = false);
    }
  }

  void sendMessage() => _sendText(_controller.text.trim());

  @override
  void dispose() {
    socket.emit('leaveAnnonce', widget.annonceId);
    super.dispose();
  }

  Widget buildMessage(String text, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
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
    final primary = Theme.of(context).primaryColor;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: onPrimary),
        backgroundColor: primary,
        title: Row(
          children: [
            const CircleAvatar(
              backgroundImage: AssetImage('assets/images/profil.png'),
            ),
            const SizedBox(width: 10),
            Text(widget.username, style: TextStyle(color: onPrimary)),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_loadingHistory) const LinearProgressIndicator(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: messages.length,
              itemBuilder:
                  (ctx, i) =>
                      buildMessage(messages[i]['text'], messages[i]['isMe']),
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
                        hintText: "Écrire un message…",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _sending ? null : sendMessage,
                  icon:
                      _sending
                          ? const CircularProgressIndicator(strokeWidth: 2)
                          : const Icon(Icons.send),
                  color: primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
