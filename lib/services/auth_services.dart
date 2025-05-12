// lib/services/auth_service.dart
import 'dart:convert';
import 'dart:io'; // For File, if sending XFile for profile picture
import 'package:flutter/foundation.dart'; // For kDebugMode
import 'package:flutter/material.dart'; // For BuildContext in logoutUser
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart'; // For XFile
import 'package:bricorasy/models/tarif_item.model.dart'; 

// Assuming Welcomescreen is your initial screen after logout
import 'package:bricorasy/screens/sign_page/welcome-screen.dart';

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
  final List<TarifItem> tarifs; // Now correctly typed as List<TarifItem>

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
    this.tarifs = const [], // Default to an empty list
  });

factory LoggedInUser.fromJson(Map<String, dynamic> json) {
  if (kDebugMode) print("LoggedInUser.fromJson - INPUT JSON: $json");
  List<TarifItem> parsedTarifs = [];
  if (json['tarifs'] != null && json['tarifs'] is List) {
    if (kDebugMode) print("LoggedInUser.fromJson - Found 'tarifs' array: ${json['tarifs']}");
    try {
      parsedTarifs = (json['tarifs'] as List).map((item) {
        if (kDebugMode) print("LoggedInUser.fromJson - Parsing tarif item: $item, Type: ${item.runtimeType}");
        if (item is Map<String, dynamic>) { // Explicit check
          return TarifItem.fromJson(item);
        } else {
          if (kDebugMode) print("LoggedInUser.fromJson - Tarif item is not a Map<String, dynamic>!");
          return TarifItem(serviceName: "Parse Error", price: "Check Logs"); // Error item
        }
      }).toList();
      if (kDebugMode) print("LoggedInUser.fromJson - Successfully parsed ${parsedTarifs.length} tarifs.");
    } catch (e) {
      if (kDebugMode) {
        print("LoggedInUser.fromJson - ERROR parsing 'tarifs': $e");
        print("LoggedInUser.fromJson - Problematic 'tarifs' JSON part: ${json['tarifs']}");
      }
    }
  } else {
    if (kDebugMode) print("LoggedInUser.fromJson - 'tarifs' field is null or not a List in JSON.");
  }

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
      tarifs: parsedTarifs, // Assign the (potentially empty) list of TarifItem objects
    );
  }

  bool get isArtisan => role == 'artisan';
}
// --- End of Helper Model ---

class AuthService {
  static const String baseUrl = "http://192.168.1.3:5000";
  static LoggedInUser? currentUser;
  static String? _jwtToken;

  static Map<String, String> get authHeader {
    final Map<String, String> headers = {'Content-Type': 'application/json'};
    if (_jwtToken != null) {
      headers['Authorization'] = 'Bearer $_jwtToken';
    }
    return headers;
  }

  static Map<String, String> get multipartAuthHeader {
    if (_jwtToken != null) {
      return {'Authorization': 'Bearer $_jwtToken'};
    }
    return {};
  }


  static void setCurrentUser(Map<String, dynamic> userData) {
    try {
      currentUser = LoggedInUser.fromJson(userData); // This will now use the corrected fromJson
      if (kDebugMode) {
        print(
          "AuthService: User set - ID: ${currentUser!.id}, Name: ${currentUser!.fullname}, Role: ${currentUser!.role}, Tarifs: ${currentUser!.tarifs.length}",
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print("AuthService: Error parsing user data in setCurrentUser - $e");
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

  static Future<void> logoutUser(BuildContext context) async {
    final String? userName = currentUser?.fullname;
    clearCurrentUser();
    if (kDebugMode) print("AuthService: User $userName logged out.");
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const Welcomescreen()),
        (route) => false,
      );
    }
  }

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
        if (kDebugMode) print("AuthService: Login successful for ${currentUser?.fullname}. Token stored.");
        return {'success': true, 'data': userData};
      } else {
        final msg =
            jsonDecode(response.body)['message'] as String? ??
            'Erreur de connexion inconnue';
        if (kDebugMode) print("AuthService: Login failed - ${response.statusCode}: $msg");
        clearCurrentUser();
        return {'success': false, 'message': msg};
      }
    } catch (e) {
      if (kDebugMode) print("AuthService: Network error during login - $e");
      clearCurrentUser();
      return {'success': false, 'message': 'Erreur réseau lors de la connexion: ${e.toString()}'};
    }
  }

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
        if (kDebugMode) print("AuthService: Registration successful for ${currentUser?.fullname}. Token stored.");
        return {'success': true, 'data': userData};
      } else {
        final msg =
            jsonDecode(response.body)['message'] as String? ??
            'Erreur d\'inscription inconnue';
        if (kDebugMode) print("AuthService: Registration failed - ${response.statusCode}: $msg");
        clearCurrentUser();
        return {'success': false, 'message': msg};
      }
    } catch (e) {
      if (kDebugMode) print("AuthService: Network error during registration - $e");
      clearCurrentUser();
      return {'success': false, 'message': 'Erreur réseau lors de l\'inscription: ${e.toString()}'};
    }
  }

  static Future<LoggedInUser?> updateMyProfile({
    required Map<String, dynamic> updateData,
    XFile? profilePictureFile,
  }) async {
    if (currentUser == null) {
      if (kDebugMode) print("AuthService: No user logged in. Cannot update profile.");
      throw Exception("Utilisateur non connecté. Impossible de mettre à jour le profil.");
    }

    final uri = Uri.parse('$baseUrl/api/users/me/profile');
    if (kDebugMode) {
      print("AuthService: Updating profile at $uri");
      print("AuthService: Update payload (text data): $updateData");
      if (profilePictureFile != null) print("AuthService: New profile picture file: ${profilePictureFile.name}");
      if (updateData['profilePicture'] == '') print("AuthService: Signal to delete existing profile picture received.");
    }

    try {
      http.Response response;

      if (profilePictureFile != null) {
        var request = http.MultipartRequest('PUT', uri);
        request.headers.addAll(multipartAuthHeader);

        updateData.forEach((key, value) {
          if (key == 'tarifs' && value is List) {
            for (int i = 0; i < value.length; i++) {
              final tarifItem = value[i] as Map<String, dynamic>;
              tarifItem.forEach((subKey, subValue) {
                 request.fields['tarifs[$i][$subKey]'] = subValue.toString();
              });
            }
          } else if (value != null) {
            request.fields[key] = value.toString();
          }
        });

        request.files.add(
          await http.MultipartFile.fromPath(
            'profilePictureFile',
            profilePictureFile.path,
          ),
        );
        if (kDebugMode) print("AuthService: Sending multipart request for profile update.");
        final streamedResponse = await request.send();
        response = await http.Response.fromStream(streamedResponse);
      } else {
        if (kDebugMode) print("AuthService: Sending JSON request for profile update.");
        response = await http.put(
          uri,
          headers: authHeader,
          body: json.encode(updateData),
        );
      }

      if (kDebugMode) print("AuthService: Update profile response - ${response.statusCode}: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body) as Map<String, dynamic>;
        setCurrentUser(responseData);
        if (kDebugMode) print("AuthService: Profile updated successfully. New user data for: ${AuthService.currentUser?.fullname}");
        return AuthService.currentUser;
      } else {
        String errorMessage = 'Erreur inconnue lors de la mise à jour.';
        try {
            final decodedError = json.decode(response.body);
            errorMessage = decodedError['message'] as String? ?? (decodedError['error'] as String? ?? errorMessage);
        } catch (_) { errorMessage = response.body.isNotEmpty ? response.body : errorMessage; }
        if (kDebugMode) print('AuthService: Error updating profile - ${response.statusCode}: $errorMessage');
        throw Exception('Échec de la mise à jour du profil: $errorMessage (Code: ${response.statusCode})');
      }
    } catch (e) {
      if (kDebugMode) print('AuthService: Network error or exception in updateMyProfile - $e');
      throw Exception('Échec de la connexion lors de la mise à jour du profil: ${e.toString()}');
    }
  }
}