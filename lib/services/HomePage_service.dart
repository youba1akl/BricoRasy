import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bricorasy/models/bricole_service.dart';
import 'package:bricorasy/models/professional_service.dart';
import 'package:bricorasy/models/dummy_tool.dart';

class apiservice {
  static const _baseUrl = 'http://127.0.0.1:5000';

  static Future<List<BricoleService>> fetchServices() async {
    final uri = Uri.parse('$_baseUrl/api/annonce/bricole');

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

class apiService_pro {
  static const _baseUrl = 'http://127.0.0.1:5000';
  static Future<List<ProfessionalService>> fetchServicePro() async {
    final uri = Uri.parse('$_baseUrl/api/annonce/professionnel');
    final reponse = await http.get(uri);
    if (reponse.statusCode != 200) {
      throw Exception('Échec du chargement: ${reponse.statusCode}');
    }
    final List<dynamic> data = jsonDecode(reponse.body) as List<dynamic>;
    return data
        .map(
          (json) => ProfessionalService.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }
}

class apiService_outil {
  static const _baseUrl = 'http://127.0.0.1:5000';

  static Future<List<DummyTool>> fetchTools() async {
    final uri = Uri.parse('$_baseUrl/api/annonce/outil');
    final reponse = await http.get(uri);

    if (reponse.statusCode != 200) {
      throw Exception('Échec du chargement: ${reponse.statusCode}');
    }
    final List<dynamic> data = jsonDecode(reponse.body) as List<dynamic>;
    return data
        .map((json) => DummyTool.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
