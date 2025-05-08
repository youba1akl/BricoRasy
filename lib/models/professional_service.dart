// lib/models/professional_service.dart

class ProfessionalService {
  final String id;
  final String name;
  final String dateCreation;
  final String dateExpiration;
  final String imagePath;
  final String localisation;
  final double prix;
  final List<String> categories;
  final String? numtel;
  final String? description;

  ProfessionalService({
    required this.id,
    required this.name,
    required this.dateCreation,
    required this.dateExpiration,
    required this.imagePath,
    required this.localisation,
    required this.prix,
    required this.categories,
    this.numtel,
    this.description,
  });

  factory ProfessionalService.fromJson(Map<String, dynamic> json) {
    String safeString(dynamic val) => val?.toString() ?? '';

    // Backend toJSON should provide 'id' (transformed from _id)
    final id = safeString(json['id'] ?? json['_id']);
    // Backend sends 'name'
    final name = safeString(json['name']);
    final dateCreation = safeString(json['date_creation']);
    final dateExpiration = safeString(json['date_expiration']);
    final localisation = safeString(json['localisation']);
    final numtel = safeString(json['numtel']);
    final description = safeString(json['description']); // Make sure your ProfessionalService class has this field

    double prixValue = 0.0;
    final rawPrix = json['prix']; // Backend sends this as a string
    if (rawPrix is String) {
      prixValue = double.tryParse(rawPrix) ?? 0.0;
    } else if (rawPrix is num) { // Fallback
      prixValue = rawPrix.toDouble();
    }

    String imgUrl = ''; // Default or placeholder
    // Backend sends 'photo' as an array of FULL URLs
    if (json['photo'] is List) {
      final photos = (json['photo'] as List).whereType<String>().toList();
      if (photos.isNotEmpty && photos.first.isNotEmpty) {
        imgUrl = photos.first; // Use the first full URL directly
      }
    }
    // if (imgUrl.isEmpty) imgUrl = 'assets/images/default_placeholder.png'; // Optional: local asset placeholder

    List<String> categories = [];
    if (json['types'] is List) { // Backend sends 'types'
      categories = (json['types'] as List).whereType<String>().toList();
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
      numtel: numtel,
      description: description, // Assign the description
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date_creation': dateCreation,
      'date_expiration': dateExpiration,
      'imagePath': imagePath,
      'localisation': localisation,
      'prix': prix,
      'categories': categories,
      'numtel': numtel,
      'description': description,
    };
  }
}