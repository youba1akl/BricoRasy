// lib/services/auth_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart'; // For kDebugMode (optional for print statements)
import 'package:flutter/material.dart'; // Required for BuildContext in logoutUser
import 'package:http/http.dart' as http;

// Assuming Welcomescreen is your initial screen after logout
import 'package:bricorasy/screens/sign_page/welcome-screen.dart'; // Adjust path if necessary

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
      profilePicture: json['profilePicture'] as String? ?? json['photo'] as String?,
      job: json['job'] as String?,
      localisation: json['localisation'] as String?,
      birthdate: json['birthdate'] != null ? DateTime.tryParse(json['birthdate'] as String) : null,
      genre: json['genre'] as String?,
    );
  }

  bool get isArtisan => role == 'artisan';
}
// --- End of Helper Model ---

class AuthService {
  static const String baseUrl = "http://192.168.1.7:5000"; // Your local IP for backend
  static LoggedInUser? currentUser;

  static void setCurrentUser(Map<String, dynamic> userData) {
    try {
      currentUser = LoggedInUser.fromJson(userData);
      if (kDebugMode) {
        print("AuthService: User set - ID: ${currentUser!.id}, Name: ${currentUser!.fullname}, Role: ${currentUser!.role}");
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
    if (kDebugMode) {
      print("AuthService: Current user cleared.");
    }
  }

  // --- Logout Method ---
  static Future<void> logoutUser(BuildContext context) async {
    clearCurrentUser();

    // TODO: Optional: Call a backend logout endpoint if necessary
    // final url = Uri.parse('$baseUrl/api/users/logout');
    // try {
    //   // Add headers if your logout requires authentication (e.g., a token)
    //   // await http.post(url, headers: {'Authorization': 'Bearer YOUR_TOKEN'});
    //   if (kDebugMode) print("AuthService: Backend logout successful (if implemented).");
    // } catch (e) {
    //   if (kDebugMode) print("AuthService: Error during backend logout - $e");
    // }

    // Navigate to the WelcomeScreen and remove all previous routes
    if (context.mounted) { // Check if context is still valid before navigating
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const Welcomescreen()), // Or your login screen
        (Route<dynamic> route) => false, // Predicate to remove all routes
      );
    }
  }
  // --- End of Logout Method ---

  static String? get currentUserId => currentUser?.id;
  static String? get currentUserPhone => currentUser?.phone;
  static String? get currentUserRole => currentUser?.role;
  static bool get isUserArtisan => currentUser?.isArtisan ?? false;

  static Future<bool> sendOtp(String email) async {
    final url = Uri.parse('$baseUrl/api/users/send-otp');
    // ... (rest of sendOtp implementation as you had it, with kDebugMode prints)
     try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      if (response.statusCode == 200) {
        if (kDebugMode) print("AuthService: OTP sent successfully to $email");
        return true;
      } else {
        if (kDebugMode) print("AuthService: Error sending OTP to $email - ${response.statusCode}: ${response.body}");
        return false;
      }
    } catch (e) {
      if (kDebugMode) print("AuthService: Network error sending OTP - $e");
      return false;
    }
  }

  static Future<bool> verifyOtp(String email, String otp) async {
    final url = Uri.parse('$baseUrl/api/users/verify-otp');
    // ... (rest of verifyOtp implementation as you had it, with kDebugMode prints)
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "otp": otp}),
      );

      if (response.statusCode == 200) {
        if (kDebugMode) print("AuthService: OTP verified successfully for $email");
        return true;
      } else {
        if (kDebugMode) print("AuthService: OTP verification failed for $email - ${response.statusCode}: ${response.body}");
        return false;
      }
    } catch (e) {
      if (kDebugMode) print("AuthService: Network error verifying OTP - $e");
      return false;
    }
  }

  static Future<Map<String, dynamic>> loginUser(
    String email,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/api/users/login');
    // ... (rest of loginUser implementation as you had it, ensures setCurrentUser and clearCurrentUser are called)
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        setCurrentUser(data);
        return {'success': true, 'data': data};
      } else {
        final errorMessage = json.decode(response.body)['message'] as String? ?? 'Erreur de connexion inconnue';
        if (kDebugMode) print("AuthService: Login failed - ${response.statusCode}: $errorMessage");
        clearCurrentUser();
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      if (kDebugMode) print("AuthService: Network error during login - $e");
      clearCurrentUser();
      return {'success': false, 'message': 'Erreur réseau lors de la connexion: $e'};
    }
  }

  // It's highly recommended to implement registerUser to also call setCurrentUser
  static Future<Map<String, dynamic>> registerUser(Map<String, dynamic> registrationData) async {
    final url = Uri.parse('$baseUrl/api/users/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(registrationData),
      );
      if (response.statusCode == 201) { // HTTP 201 Created for successful registration
        final data = json.decode(response.body) as Map<String, dynamic>;
        setCurrentUser(data); // Set the full user data upon successful registration
        if (kDebugMode) print("AuthService: Registration successful, user set.");
        return {'success': true, 'data': data};
      } else {
        final errorMessage = json.decode(response.body)['message'] as String? ?? 'Erreur d\'inscription inconnue';
        if (kDebugMode) print("AuthService: Registration failed - ${response.statusCode}: $errorMessage");
        clearCurrentUser(); // Ensure no partial user data is set
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      if (kDebugMode) print("AuthService: Network error during registration - $e");
      clearCurrentUser();
      return {'success': false, 'message': 'Erreur réseau lors de l\'inscription: $e'};
    }
  }
}