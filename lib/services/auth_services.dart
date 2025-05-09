// lib/services/auth_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl =
      "http://192.168.43.44:5000"; // <-- Remplacer par ton IP locale !!

  /// ────────────────────────────────────────────────────────
  /// Store the currently-logged-in user’s ID & phone here:
  static String? userId;
  static String? phone;

  /// Call this immediately after a successful login:
  static void setUser(String id, String userPhone) {
    userId = id;
    phone = userPhone;
  }

  /// ────────────────────────────────────────────────────────

  // Fonction pour envoyer OTP à l'email
  static Future<bool> sendOtp(String email) async {
    final url = Uri.parse('$baseUrl/api/users/send-otp');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      if (response.statusCode == 200) {
        print("OTP envoyé avec succès");
        return true;
      } else {
        print("Erreur envoi OTP: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Erreur de requête OTP: $e");
      return false;
    }
  }

  // Fonction pour vérifier OTP
  static Future<bool> verifyOtp(String email, String otp) async {
    final url = Uri.parse('$baseUrl/api/users/verify-otp');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "otp": otp}),
      );

      if (response.statusCode == 200) {
        print("OTP vérifié avec succès");
        return true;
      } else {
        print("OTP incorrect: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Erreur de requête vérification OTP: $e");
      return false;
    }
  }

  // Fonction pour login
  static Future<Map<String, dynamic>> loginUser(
    String email,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/api/users/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        // Connexion réussie
        final data = json.decode(response.body);

        // ←─── NEW: remember this user’s id & phone ────→
        setUser(data['_id'] as String, data['phone'] as String);

        return {'success': true, 'data': data};
      } else {
        final message =
            json.decode(response.body)['message'] ?? 'Erreur inconnue';
        return {'success': false, 'message': message};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur réseau: $e'};
    }
  }
}
