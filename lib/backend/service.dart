import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bricorasy/models/bricole_service.dart';

class apiservice {
  static const _baseUrl = 'http://10.0.2.2:8000';

  static Future<List<BricoleService>> fetchServices() async {
    final uri = Uri.parse('$_baseUrl/api/annonces/bricole');

    final reponse = await http.get(uri);

    if (reponse.statusCode != 200) {
      throw Exception('Échec du chargement: ${reponse.statusCode}');
    }
    final List<dynamic> data = jsonDecode(reponse.body) as List<dynamic>;
    return data
        .map((json) => BricoleService.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
