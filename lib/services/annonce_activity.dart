// lib/services/annonce_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bricorasy/services/auth_services.dart';
import 'package:bricorasy/models/bricole_service.dart';
import 'package:bricorasy/models/professional_service.dart';
import 'package:bricorasy/models/dummy_tool.dart'; // or your Outil model

const String _baseUrl = 'http://127.0.0.1:5000/api/annonce';

class AnnonceService {
  static Future<List<BricoleService>> fetchBricole() async {
    final resp = await http.get(
      Uri.parse('$_baseUrl/bricole'),
      headers: AuthService.authHeader,
    );
    if (resp.statusCode == 200) {
      final List list = jsonDecode(resp.body);
      return list.map((j) => BricoleService.fromJson(j)).toList();
    }
    throw Exception('Erreur ${resp.statusCode}');
  }

  static Future<List<ProfessionalService>> fetchProfessionnel() async {
    final resp = await http.get(
      Uri.parse('$_baseUrl/professionnel'),
      headers: AuthService.authHeader,
    );
    if (resp.statusCode == 200) {
      final List list = jsonDecode(resp.body);
      return list.map((j) => ProfessionalService.fromJson(j)).toList();
    }
    throw Exception('Erreur ${resp.statusCode}');
  }

  static Future<List<DummyTool>> fetchOutil() async {
    final resp = await http.get(
      Uri.parse('$_baseUrl/outil'),
      headers: AuthService.authHeader,
    );
    if (resp.statusCode == 200) {
      final List list = jsonDecode(resp.body);
      return list.map((j) => DummyTool.fromJson(j)).toList();
    }
    throw Exception('Erreur ${resp.statusCode}');
  }
}
