// lib/services/post_service.dart
import 'dart:convert';
import 'dart:io'; // For File, used if sending XFile directly (not typical for createPost here, but good for reference)
import 'package:flutter/foundation.dart'; // For kDebugMode
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart'; // For XFile, needed by createPost
import 'package:bricorasy/models/post.model.dart';    // Your Post model
import 'package:bricorasy/services/auth_services.dart'; // For baseUrl, currentUser, authHeader

class PostService {
  static String get _baseUrl => AuthService.baseUrl;

  /// Fetches posts for a specific artisan by their User ID.
  static Future<List<Post>> fetchPostsByArtisanId(String artisanId) async {
    // The artisanId here is expected to be the User._id of the artisan
    final uri = Uri.parse('$_baseUrl/api/posts?artisanId=$artisanId');
    if (kDebugMode) {
      print("PostService: Fetching posts for artisan ID '$artisanId' from '$uri'");
    }
    try {
      // This endpoint might be public or require auth depending on your backend
      final response = await http.get(uri, headers: AuthService.authHeader);

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        final List<Post> posts = responseData
            .map((data) => Post.fromJson(data as Map<String, dynamic>))
            .toList();
        if (kDebugMode) {
          print("PostService: Successfully fetched ${posts.length} posts for artisan '$artisanId'.");
        }
        return posts;
      } else {
        if (kDebugMode) {
          print("PostService: Failed to load posts for artisan '$artisanId' - ${response.statusCode}: ${response.body}");
        }
        throw Exception('Échec du chargement des postes (Artisan: $artisanId, Code: ${response.statusCode})');
      }
    } catch (e) {
      if (kDebugMode) {
        print("PostService: Network error or exception fetching posts for artisan '$artisanId' - $e");
      }
      throw Exception('Erreur de connexion lors du chargement des postes: $e');
    }
  }

  /// Creates a new post.
  /// Assumes the backend endpoint '/api/posts' handles multipart/form-data for image uploads.
  static Future<Post?> createPost({
    required String title,
    required String description,
    required List<XFile> images, // List of XFile from image_picker
    String? phone, // Optional phone for the post
    String? email, // Optional email for the post
  }) async {
    final currentUser = AuthService.currentUser;
    if (currentUser == null) {
      if (kDebugMode) print("PostService: User not logged in. Cannot create post.");
      throw Exception("Utilisateur non connecté. Impossible de créer un poste.");
    }
    if (!currentUser.isArtisan) {
      if (kDebugMode) print("PostService: User '${currentUser.fullname}' is not an artisan. Cannot create post.");
      throw Exception("Seuls les artisans peuvent créer des postes.");
    }

    final uri = Uri.parse('$_baseUrl/api/posts'); // Backend endpoint for creating posts
    if (kDebugMode) print("PostService: Creating post for artisan ID '${currentUser.id}' at '$uri'");

    final request = http.MultipartRequest('POST', uri);

    // Add text fields
    request.fields['artisanId'] = currentUser.id; // The logged-in user IS the artisan
    request.fields['title'] = title;
    request.fields['description'] = description;
    // Use post-specific phone/email if provided, otherwise fall back to artisan's main contact
    request.fields['phone'] = phone?.isNotEmpty == true ? phone! : currentUser.phone;
    request.fields['email'] = email?.isNotEmpty == true ? email! : currentUser.email;


    // Add authentication headers
    // Note: Some servers/configurations might have issues with Bearer tokens in multipart headers.
    // If so, you might need to send the token as a field, or ensure your backend handles it.
    request.headers.addAll(AuthService.authHeader);

    // Add images
    if (images.isNotEmpty) {
      for (var imageFile in images) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'images', // THIS MUST MATCH THE FIELD NAME YOUR BACKEND MULTER EXPECTS
                      // e.g., if multer is upload.array('postImages', 5), use 'postImages'
            imageFile.path,
            // filename: path.basename(imageFile.path), // Optional: if backend needs original filename
            // contentType: MediaType('image', 'jpeg'), // Optional: specify content type
          ),
        );
      }
    } else {
      // If images are optional and can be an empty array on the backend.
      // If images are required but none provided, you might want to throw an error here
      // or let the backend handle the validation.
      // For now, we allow sending with no images if the list is empty.
      // The backend post model `images` field is an array, so an empty array is valid.
    }


    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) { // 201 Created
        final responseData = json.decode(response.body) as Map<String, dynamic>;
        if (kDebugMode) print("PostService: Post created successfully - ${responseData['_id']}");
        return Post.fromJson(responseData); // Assuming backend returns the created post object
      } else {
        final errorBody = response.body;
        String errorMessage = 'Erreur inconnue lors de la création du poste.';
        try {
          final decodedError = json.decode(errorBody);
          if (decodedError is Map && decodedError.containsKey('error')) {
            errorMessage = decodedError['error'] as String;
          } else if (decodedError is Map && decodedError.containsKey('message')) {
            errorMessage = decodedError['message'] as String;
          }
        } catch (_) {
          errorMessage = errorBody; // Fallback to raw body if not JSON
        }
        if (kDebugMode) print('PostService: Error creating post - ${response.statusCode}: $errorMessage');
        throw Exception('Échec de la création du poste: $errorMessage (Code: ${response.statusCode})');
      }
    } catch (e) {
      if (kDebugMode) print('PostService: Network error or exception in createPost - $e');
      throw Exception('Échec de la connexion lors de la création du poste: $e');
    }
  }

  // TODO: Add other methods as needed:
  // static Future<Post> fetchPostById(String postId) async { ... }
  // static Future<Post> updatePost(String postId, Map<String, dynamic> data, List<XFile> newImages) async { ... }
  // static Future<void> deletePost(String postId) async { ... }
  // static Future<void> likePost(String postId) async { ... }
  // static Future<Comment> addCommentToPost(String postId, String commentText) async { ... }
}