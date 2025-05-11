// lib/services/professional_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bricorasy/models/professional_service.dart'; // Adjust path if needed

// Ensure this constant is defined, perhaps in a shared config file
const String API_BASE_URL = "http://192.168.1.33:5000";

class ProfessionalApiService {
  Future<ProfessionalService> fetchProfessionalServiceById(String serviceId) async {
    final Uri url = Uri.parse('$API_BASE_URL/api/annonce/professionnel/$serviceId');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
        return ProfessionalService.fromJson(data);
      } else {
        print('Failed to load professional service (${response.statusCode}): ${response.body}');
        // It's good to throw a more specific error or return a result type
        throw Exception('Failed to load professional service details. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching professional service by ID: $e');
      throw Exception('Failed to load professional service details: $e');
    }
  }
}