import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bricorasy/models/artisan.model.dart';

class api_artisan {
  static const _baseUrl = 'http://127.0.0.1:5000';

  static Future<List<Artisan>> fetchArtisans() async {
    final uri = Uri.parse('$_baseUrl/api/users/artisans');
    final reponse = await http.get(uri);

    if (reponse.statusCode != 200) {
      throw Exception('Échec du chargement: ${reponse.statusCode}');
    }
    final List<dynamic> data = jsonDecode(reponse.body) as List<dynamic>;
    return data
        .map((json) => Artisan.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
