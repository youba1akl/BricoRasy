import 'dart:convert';

class BricoleService {
  final String id;
  final String name;
  final String date_creation;
  final String date_exp;
  final String imagePath;
  final String localisation;
  final String phone; // ← new
  final String idc; // ← new
  final double prix;
  final String description;
  final List<String> categories;

  BricoleService({
    required this.id,
    required this.name,
    required this.date_creation,
    required this.date_exp,
    required this.imagePath,
    required this.localisation,
    required this.phone, // ← new
    required this.idc, // ← new
    required this.prix,
    required this.categories,
    required this.description,
  });

  factory BricoleService.fromJson(Map<String, dynamic> json) {
    // parse price
    double prixValue;
    final rawPrix = json['prix'];
    if (rawPrix is num) {
      prixValue = rawPrix.toDouble();
    } else if (rawPrix is Map<String, dynamic> &&
        rawPrix.containsKey(r'$numberDecimal')) {
      prixValue = double.parse(rawPrix[r'$numberDecimal'] as String);
    } else {
      prixValue = 0.0;
    }

    // build image URL
    final List<dynamic> rawPhotos = json['photo'] as List<dynamic>;
    final String imgUrl =
        rawPhotos.isNotEmpty
            ? 'http://10.0.2.2:5000/uploads/${rawPhotos.first}'
            : '';

    return BricoleService(
      id: json['_id'] as String,
      name: json['titre'] as String,
      date_creation: json['date_creation'] as String,
      date_exp: json['date_expiration'] as String,
      imagePath: imgUrl,
      localisation: json['localisation'] as String,

      // pull in the two new fields
      phone: json['phone'] as String,
      idc: json['idc'] as String,
      description: json['description'] as String,

      prix: prixValue,
      categories: [json['type_annonce'] as String],
    );
  }
}
