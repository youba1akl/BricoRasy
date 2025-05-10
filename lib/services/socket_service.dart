import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;

  late IO.Socket socket;

  Function(List<dynamic>)? onPreviousMessages;
  Function(Map<String, dynamic>)? onMessageReceived;

  SocketService._internal();

  void connect() {
    socket = IO.io(
      'http://10.0.2.2:5000',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket.connect();

    socket.onConnect((_) => print('✅ Connected to socket'));
    socket.onDisconnect((_) => print('❌ Disconnected'));

    socket.on('receivePreviousMessages', (data) {
      if (onPreviousMessages != null && data is List) {
        onPreviousMessages!(data);
      }
    });

    socket.on('receiveMessage', (data) {
      if (onMessageReceived != null && data is Map<String, dynamic>) {
        onMessageReceived!(Map<String, dynamic>.from(data));
      }
    });
  }

  void joinChat({required String sender, required String receiver}) {
    socket.emit('joinChat', {'sender': sender, 'receiver': receiver});
  }

  void sendMessage(Map<String, dynamic> message) {
    socket.emit('sendMessage', message);
  }

  void dispose() {
    socket.dispose();
  }
}
