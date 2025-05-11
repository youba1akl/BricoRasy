// lib/services/artisan_services.dart
import 'dart:convert';
import 'package:flutter/foundation.dart'; // For kDebugMode
import 'package:http/http.dart' as http;
import 'package:bricorasy/models/artisan.model.dart';
import 'package:bricorasy/services/auth_services.dart'; // For AuthService.currentUser, baseUrl, and authHeader

class api_artisan {
  // Use AuthService.baseUrl for consistency
  static String get _baseUrl => AuthService.baseUrl;

  /// Fetches a list of all users who have the role 'artisan'.
  /// These User objects from the backend are expected to contain fields
  /// that can be mapped by Artisan.fromJson.
  static Future<List<Artisan>> fetchArtisans() async {
    final uri = Uri.parse('$_baseUrl/api/users/artisans');
    if (kDebugMode) {
      print("ArtisanService: Fetching all artisans from $uri");
    }
    try {
      // Assuming this endpoint might be public or use a general app token if needed,
      // but adding authHeader for consistency if it becomes protected.
      final response = await http.get(uri, headers: AuthService.authHeader);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        if (kDebugMode) {
          print("ArtisanService: Successfully fetched ${data.length} artisans.");
        }
        return data
            .map((json) => Artisan.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        if (kDebugMode) {
          print("ArtisanService: Failed to load artisans - ${response.statusCode}: ${response.body}");
        }
        throw Exception('Échec du chargement des artisans (Code: ${response.statusCode})');
      }
    } catch (e) {
      if (kDebugMode) {
        print("ArtisanService: Network error or exception fetching artisans - $e");
      }
      throw Exception('Erreur de connexion lors du chargement des artisans: $e');
    }
  }

  /// Fetches a single user by their ID, expecting them to be an artisan.
  /// Your backend needs an endpoint like GET /api/users/:userId that returns user details.
  static Future<Artisan> fetchArtisanById(String userId) async {
    final uri = Uri.parse('$_baseUrl/api/users/$userId'); // Assumes backend GET /api/users/:id
    if (kDebugMode) {
      print("ArtisanService: Fetching artisan by ID '$userId' from '$uri'");
    }
    try {
      // Fetching a specific user profile might require authentication
      final response = await http.get(uri, headers: AuthService.authHeader);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
        // Backend's /api/users/:userId should return the user object which includes 'role'
        if (data['role'] == 'artisan') {
          if (kDebugMode) {
            print("ArtisanService: Successfully fetched artisan by ID: ${data['fullname']}");
          }
          return Artisan.fromJson(data);
        } else {
          if (kDebugMode) {
            print("ArtisanService: User found by ID '$userId' is not an artisan. Role: ${data['role']}");
          }
          // It's better to throw a specific error or return null if not an artisan,
          // depending on how the calling code wants to handle it.
          // For now, throwing an exception if role doesn't match.
          throw Exception('L\'utilisateur (ID: $userId) n\'est pas un artisan.');
        }
      } else {
        if (kDebugMode) {
          print("ArtisanService: Failed to load artisan by ID '$userId' - ${response.statusCode}: ${response.body}");
        }
        throw Exception('Échec du chargement du profil artisan (ID: $userId, Code: ${response.statusCode})');
      }
    } catch (e) {
      if (kDebugMode) {
        print("ArtisanService: Network error or exception fetching artisan by ID '$userId' - $e");
      }
      throw Exception('Erreur de connexion pour charger le profil artisan (ID: $userId): $e');
    }
  }

  /// Constructs an Artisan object for the currently logged-in user if they are an artisan.
  /// Relies on AuthService.currentUser being populated accurately after login.
  static Future<Artisan?> fetchMyArtisanProfile() async {
    // This method remains synchronous as it uses already available AuthService.currentUser data.
    if (kDebugMode) {
      print("ArtisanService: Attempting to fetch/construct 'my' artisan profile from AuthService.currentUser.");
    }

    final loggedInUser = AuthService.currentUser;

    if (loggedInUser != null) {
      if (loggedInUser.isArtisan) {
        if (kDebugMode) {
          print("ArtisanService: Current user '${loggedInUser.fullname}' is an artisan. Mapping data to Artisan model.");
        }
        // Map LoggedInUser fields to Artisan fields.
        // The Artisan model's fromJson is not directly used here because we are mapping
        // from a LoggedInUser object, not a raw JSON map.
        return Artisan(
          id: loggedInUser.id, // Pass the user's ID to the Artisan model
          fullname: loggedInUser.fullname,
          job: loggedInUser.job ?? "Métier non spécifié",
          localisation: loggedInUser.localisation ?? "Lieu non spécifié",
          numTel: loggedInUser.phone, // LoggedInUser.phone is the contact number
          rating: "N/A", // Placeholder: Rating is typically an aggregated value
          image: loggedInUser.profilePicture ?? '', // Use profilePicture, default to empty
          like: "0", // Placeholder: Likes are also typically aggregated
        );
      } else {
        if (kDebugMode) {
          print("ArtisanService: Logged-in user '${loggedInUser.fullname}' is NOT an artisan (role: ${loggedInUser.role}).");
        }
        return null; // Logged-in user is not an artisan
      }
    } else {
      if (kDebugMode) {
        print("ArtisanService: No user currently logged in (AuthService.currentUser is null). Cannot determine artisan status.");
      }
      return null; // No user is logged in
    }
  }
}