class Message {
  final String content;
  final String sender;
  final String receiver;
  final DateTime timestamp;
  final bool isMe;

  Message({
    required this.content,
    required this.sender,
    required this.receiver,
    required this.timestamp,
    required this.isMe,
  });

  factory Message.fromJson(Map<String, dynamic> json, bool isMe) {
    return Message(
      content: json['content'],
      sender: json['sender'],
      receiver: json['receiver'],
      timestamp: DateTime.parse(json['timestamp']),
      isMe: isMe,
    );
  }

  Map<String, dynamic> toJson() => {
        'content': content,
        'sender': sender,
        'receiver': receiver,
        'timestamp': timestamp.toIso8601String(),
      };
}
