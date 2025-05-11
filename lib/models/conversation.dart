// lib/models/conversation.dart
class Conversation {
  final String annonceId;
  final String peerId;
  final String peerName;
  String lastMessage;

  Conversation({
    required this.annonceId,
    required this.peerId,
    required this.peerName,
    required this.lastMessage,
  });

  factory Conversation.fromJson(Map<String, dynamic> j) => Conversation(
        annonceId: j['annonceId'] as String,
        peerId: j['peerId'] as String,
        peerName: j['peerName'] as String,
        lastMessage: j['lastMessage'] as String,
      );
}
