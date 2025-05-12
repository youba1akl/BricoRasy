// lib/services/auth_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart'; // For kDebugMode
import 'package:flutter/material.dart'; // For BuildContext in logoutUser
import 'package:http/http.dart' as http;

// Assuming Welcomescreen is your initial screen after logout
import 'package:bricorasy/screens/sign_page/welcome-screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// --- Helper Model for Logged-In User Data ---
class LoggedInUser {
  final String id;
  final String fullname;
  final String email;
  final String phone;
  final String role; // 'simple' or 'artisan'
  final String? profilePicture;
  final String? job;
  final String? localisation;
  final DateTime? birthdate;
  final String? genre;

  LoggedInUser({
    required this.id,
    required this.fullname,
    required this.email,
    required this.phone,
    required this.role,
    this.profilePicture,
    this.job,
    this.localisation,
    this.birthdate,
    this.genre,
  });

  factory LoggedInUser.fromJson(Map<String, dynamic> json) {
    return LoggedInUser(
      id: json['_id'] as String,
      fullname: json['fullname'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      role: json['role'] as String,
      profilePicture:
          json['profilePicture'] as String? ?? json['photo'] as String?,
      job: json['job'] as String?,
      localisation: json['localisation'] as String?,
      birthdate:
          json['birthdate'] != null
              ? DateTime.tryParse(json['birthdate'] as String)
              : null,
      genre: json['genre'] as String?,
    );
  }

  bool get isArtisan => role == 'artisan';
}
// --- End of Helper Model ---

class AuthService {
  static final String baseUrl = dotenv.env['API_BASE_URL']!;
  static LoggedInUser? currentUser;
  static String? _jwtToken;

  /// Returns headers for protected routes
  static Map<String, String> get authHeader {
    if (_jwtToken != null) {
      return {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_jwtToken',
      };
    }
    return {'Content-Type': 'application/json'};
  }

  static void setCurrentUser(Map<String, dynamic> userData) {
    try {
      currentUser = LoggedInUser.fromJson(userData);
      if (kDebugMode) {
        print(
          "AuthService: User set - ID: ${currentUser!.id}, Name: ${currentUser!.fullname}",
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print("AuthService: Error parsing user data - $e");
        print("AuthService: Raw user data received: $userData");
      }
      currentUser = null;
    }
  }

  static void clearCurrentUser() {
    currentUser = null;
    _jwtToken = null;
    if (kDebugMode) print("AuthService: Current user & token cleared.");
  }

  // --- Logout Method ---
  static Future<void> logoutUser(BuildContext context) async {
    clearCurrentUser();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const Welcomescreen()),
        (route) => false,
      );
    }
  }
  // --- End of Logout Method ---

  static String? get token => _jwtToken;
  static String? get currentUserId => currentUser?.id;
  static String? get currentUserPhone => currentUser?.phone;
  static bool get isUserArtisan => currentUser?.isArtisan ?? false;

  static Future<bool> sendOtp(String email) async {
    final url = Uri.parse('$baseUrl/api/users/send-otp');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      if (response.statusCode == 200) {
        if (kDebugMode) print("AuthService: OTP sent to $email");
        return true;
      }
      if (kDebugMode) print("AuthService: OTP error ${response.statusCode}");
      return false;
    } catch (e) {
      if (kDebugMode) print("AuthService: OTP network error - $e");
      return false;
    }
  }

  static Future<bool> verifyOtp(String email, String otp) async {
    final url = Uri.parse('$baseUrl/api/users/verify-otp');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp}),
      );
      if (response.statusCode == 200) {
        if (kDebugMode) print("AuthService: OTP verified for $email");
        return true;
      }
      if (kDebugMode)
        print("AuthService: OTP verify error ${response.statusCode}");
      return false;
    } catch (e) {
      if (kDebugMode) print("AuthService: OTP verify network error - $e");
      return false;
    }
  }

  /// Login : récupère le token et les infos user
  static Future<Map<String, dynamic>> loginUser(
    String email,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/api/users/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        _jwtToken = body['token'] as String?;
        final userData = body['user'] as Map<String, dynamic>;
        setCurrentUser(userData);
        return {'success': true, 'data': userData};
      } else {
        final msg =
            jsonDecode(response.body)['message'] as String? ??
            'Erreur inconnue';
        clearCurrentUser();
        return {'success': false, 'message': msg};
      }
    } catch (e) {
      clearCurrentUser();
      return {'success': false, 'message': 'Erreur réseau: $e'};
    }
  }

  /// Inscription : idem, stocke token + user
  static Future<Map<String, dynamic>> registerUser(
    Map<String, dynamic> registrationData,
  ) async {
    final url = Uri.parse('$baseUrl/api/users/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(registrationData),
      );

      if (response.statusCode == 201) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        _jwtToken = body['token'] as String?;
        final userData = body['user'] as Map<String, dynamic>;
        setCurrentUser(userData);
        return {'success': true, 'data': userData};
      } else {
        final msg =
            jsonDecode(response.body)['message'] as String? ??
            'Erreur inscription';
        clearCurrentUser();
        return {'success': false, 'message': msg};
      }
    } catch (e) {
      clearCurrentUser();
      return {'success': false, 'message': 'Erreur réseau: $e'};
    }
  }
}
