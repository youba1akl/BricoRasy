import 'dart:convert';

class ProfessionalService {
  final String id;
  final String name;
  final String dateCreation;
  final String dateExpiration;
  final String imagePath;
  final String localisation;
  final double prix;
  final List<String> categories;

  ProfessionalService({
    required this.id,
    required this.name,
    required this.dateCreation,
    required this.dateExpiration,
    required this.imagePath,
    required this.localisation,
    required this.prix,
    required this.categories,
  });

  factory ProfessionalService.fromJson(Map<String, dynamic> json) {
    // 1) Safe string extraction with fallback
    String safeString(String? s) => s ?? '';

    final id = safeString(json['_id'] as String?);
    final name = safeString(json['titre'] as String?);
    final dateCreation = safeString(json['date_creation'] as String?);
    final dateExpiration = safeString(json['date_expiration'] as String?);
    final localisation = safeString(json['localisation'] as String?);

    // 2) Price parsing (unchanged)
    double prixValue;
    final rawPrix = json['prix'];
    if (rawPrix is num) {
      prixValue = rawPrix.toDouble();
    } else if (rawPrix is Map<String, dynamic> &&
        rawPrix.containsKey(r'$numberDecimal')) {
      prixValue = double.tryParse(rawPrix[r'$numberDecimal'] as String) ?? 0.0;
    } else {
      prixValue = 0.0;
    }

    // 3) Photos array safe parsing
    String imgUrl = '';
    if (json['photo'] is List) {
      final photos = (json['photo'] as List).whereType<String>().toList();
      if (photos.isNotEmpty) {
        imgUrl = 'http://10.0.2.2:5000/uploads/${photos.first}';
      }
    }

    // 4) Categories: the backend might send 'types' (an array) or a single 'type_annonce'
    List<String> categories = [];
    if (json['types'] is List) {
      categories = (json['types'] as List).whereType<String>().toList();
    } else if (json['type_annonce'] is String) {
      categories = [json['type_annonce'] as String];
    }

    return ProfessionalService(
      id: id,
      name: name,
      dateCreation: dateCreation,
      dateExpiration: dateExpiration,
      imagePath: imgUrl,
      localisation: localisation,
      prix: prixValue,
      categories: categories,
    );
  }
}
