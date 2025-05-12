// lib/services/socket_service.dart
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:bricorasy/services/auth_services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SocketService {
  static IO.Socket? _socket;

  /// Récupère ou crée le socket, avec le JWT en header
  static IO.Socket get socket {
    if (_socket == null) {
      final token = AuthService.token;
      final url = dotenv.env['API_BASE_URL'] ?? '';
      _socket = IO.io(
        url,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .setExtraHeaders({'authorization': 'Bearer $token'})
            .build(),
      );
    }
    return _socket!;
  }

  /// À appeler après le login pour initialiser la connexion
  static void init() {
    socket.connect();
    socket.onConnect((_) => print('🟢 Socket connected: ${socket.id}'));
    socket.onDisconnect((_) => print('🔴 Socket disconnected'));
  }

  /// À appeler à la fermeture de l’app si besoin
  static void dispose() {
    _socket?.dispose();
    _socket = null;
  }
}
