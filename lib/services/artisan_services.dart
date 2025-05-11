// lib/services/artisan_services.dart
import 'dart:convert';
import 'package:flutter/foundation.dart'; // For kDebugMode
import 'package:http/http.dart' as http;
import 'package:bricorasy/models/artisan.model.dart';
import 'package:bricorasy/services/auth_services.dart'; // Import AuthService

class api_artisan {
  // Use AuthService.baseUrl for consistency and easier updates if the base URL changes.
  static String get _baseUrl => AuthService.baseUrl;

  /// Fetches a list of all users who have the role 'artisan'.
  /// These User objects are expected to contain fields mappable by Artisan.fromJson.
  static Future<List<Artisan>> fetchArtisans() async {
    final uri = Uri.parse('$_baseUrl/api/users/artisans');
    if (kDebugMode) {
      print("ArtisanService: Fetching all artisans from $uri");
    }
    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        if (kDebugMode) {
          print(
            "ArtisanService: Successfully fetched ${data.length} artisans.",
          );
        }
        return data
            .map((json) => Artisan.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        if (kDebugMode) {
          print(
            "ArtisanService: Failed to load artisans - ${response.statusCode}: ${response.body}",
          );
        }
        throw Exception(
          'Échec du chargement des artisans: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print("ArtisanService: Network error fetching artisans - $e");
      }
      // Consider more specific error types or messages
      throw Exception(
        'Erreur de connexion lors du chargement des artisans: $e',
      );
    }
  }

  /// Fetches a single user by their ID, expecting them to be an artisan.
  /// Your backend needs an endpoint like GET /api/users/:userId that returns user details.
  static Future<Artisan> fetchArtisanById(String userId) async {
    // IMPORTANT: Ensure your backend has a GET /api/users/:userId endpoint
    final uri = Uri.parse('$_baseUrl/api/users/$userId');
    if (kDebugMode) {
      print("ArtisanService: Fetching artisan by ID $userId from $uri");
    }
    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;
        // Check if the fetched user is indeed an artisan based on the 'role' field
        if (data['role'] == 'artisan') {
          if (kDebugMode) {
            print(
              "ArtisanService: Successfully fetched artisan by ID: ${data['fullname']}",
            );
          }
          return Artisan.fromJson(data);
        } else {
          if (kDebugMode) {
            print(
              "ArtisanService: User found by ID $userId is not an artisan. Role: ${data['role']}",
            );
          }
          throw Exception('L\'utilisateur récupéré n\'est pas un artisan.');
        }
      } else {
        if (kDebugMode) {
          print(
            "ArtisanService: Failed to load artisan by ID $userId - ${response.statusCode}: ${response.body}",
          );
        }
        throw Exception(
          'Échec du chargement du profil artisan (ID: $userId): ${response.statusCode}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print(
          "ArtisanService: Network error fetching artisan by ID $userId - $e",
        );
      }
      throw Exception('Erreur de connexion pour charger le profil artisan: $e');
    }
  }

  /// Fetches the artisan profile for the currently logged-in user.
  /// This relies on AuthService.currentUser being populated after login.
  static Future<Artisan?> fetchMyArtisanProfile() async {
    if (kDebugMode) {
      print("ArtisanService: Attempting to fetch my artisan profile.");
    }
    // Check if a user is logged in and if they are an artisan directly from AuthService
    if (AuthService.currentUser != null) {
      if (AuthService.currentUser!.isArtisan) {
        if (kDebugMode) {
          print("ArtisanService: Current user is an artisan. Mapping data.");
        }
        // The LoggedInUser object should have all necessary fields.
        // Map LoggedInUser fields to Artisan fields.
        // Your Artisan.fromJson might also be usable if LoggedInUser has a toJson method,
        // or if you manually map.
        return Artisan(
          // id: AuthService.currentUser!.id, // Your Artisan model doesn't have id currently
          fullname: AuthService.currentUser!.fullname,
          job:
              AuthService.currentUser!.job ?? "Non spécifié", // Default if null
          localisation:
              AuthService.currentUser!.localisation ?? "Non spécifiée",
          numTel:
              AuthService
                  .currentUser!
                  .phone, // User's phone is the numTel for artisan
          rating:
              "N/A", // Rating usually comes from aggregated reviews, not directly on user model
          image:
              AuthService.currentUser!.profilePicture ??
              '', // Use profilePicture or default
          like: "0", // Likes usually come from a separate system or aggregation
        );
      } else {
        if (kDebugMode) {
          print(
            "ArtisanService: Logged-in user (${AuthService.currentUser!.fullname}) is not an artisan (role: ${AuthService.currentUser!.role}).",
          );
        }
        return null; // Logged-in user is not an artisan
      }
    } else {
      if (kDebugMode) {
        print(
          "ArtisanService: No user currently logged in (AuthService.currentUser is null).",
        );
      }
      return null; // No user is logged in
    }
    // Note: If you wanted to re-fetch from the server instead of relying on AuthService.currentUser,
    // you would call an endpoint like GET /api/users/me (protected by auth token)
    // or GET /api/users/{AuthService.currentUserId} and then perform the role check and mapping.
    // For simplicity and efficiency, relying on the already fetched AuthService.currentUser is good
    // if your login response includes all necessary artisan fields for 'artisan' role users.
  }
}
