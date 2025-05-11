import 'package:flutter/material.dart';
import 'package:bricorasy/widgets/reviw_card.dart';

/// Simple model pour un message
class SimpleMessage {
  final String username;
  final String content;

  SimpleMessage({required this.username, required this.content});
}

/// Widget qui affiche une liste de [SimpleMessage]
class MessageListView extends StatelessWidget {
  final List<SimpleMessage> messages;

  const MessageListView({Key? key, required this.messages}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const Center(child: Text('Aucun message.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];
        return MessageCard(username: msg.username, content: msg.content);
      },
    );
  }
}
