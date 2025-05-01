import 'dart:convert';

class BricoleService {
  final String id;
  final String name;
  final String imagePath;
  final String localisation;

  final double prix;
  final List<String> categories;

  BricoleService({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.localisation,
    required this.prix,
    required this.categories,
  });

  factory BricoleService.fromJson(Map<String, dynamic> json) {
    // Parse creation & expiration to compute duration

    // Build image URL if any photo exists
    final List<dynamic> rawPhotos = json['photo'] as List<dynamic>;
    final String imgUrl =
        rawPhotos.isNotEmpty
            ? 'http://10.0.2.2:8000/uploads/${rawPhotos.first}'
            : '';

    return BricoleService(
      id: json['_id'] as String,
      name: json['titre'] as String,
      imagePath: imgUrl,
      localisation: json['localisation'] as String,

      prix: (json['prix'] as num).toDouble(),
      categories: [json['type_annonce'] as String],
    );
  }
}
