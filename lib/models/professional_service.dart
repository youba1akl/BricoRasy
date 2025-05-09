class ProfessionalService {
  final String id;
  final String name;
  final String dateCreation;
  final String dateExpiration;
  final String imagePath;
  final String localisation;
  final String? numtel;
  final String mail;
  final double prix;
  final List<String> categories;
  final String? description;

  ProfessionalService({
    required this.id,
    required this.name,
    required this.dateCreation,
    required this.dateExpiration,
    required this.imagePath,
    required this.localisation,
    required this.numtel,
    required this.mail,
    required this.prix,
    required this.categories,
    this.description,
  });

  factory ProfessionalService.fromJson(Map<String, dynamic> json) {
    String safeString(dynamic v) => v?.toString() ?? '';

    final id = safeString(json['id'] ?? json['_id']);
    final name = safeString(json['name']);
    final dateCreation = safeString(json['date_creation']);
    final dateExpiration = safeString(json['date_expiration']);
    final localisation = safeString(json['localisation']);
    final numtel = safeString(json['numtel']);
    final mail = safeString(json['mail']);
    final description = safeString(json['description']);

    // parse prix
    double prixValue = 0.0;
    final rawPrix = json['prix'];
    if (rawPrix is String) {
      prixValue = double.tryParse(rawPrix) ?? 0.0;
    } else if (rawPrix is num) {
      prixValue = rawPrix.toDouble();
    }

    // photos → first URL
    final List<dynamic> rawPhotos = json['photo'] as List<dynamic>;
    final imagePath =
        rawPhotos.isNotEmpty
            ? 'http://10.0.2.2:5000/uploads/${rawPhotos.first}'
            : '';

    // types → categories
    final List<String> categories =
        (json['types'] as List<dynamic>?)?.whereType<String>().toList() ?? [];

    return ProfessionalService(
      id: id,
      name: name,
      dateCreation: dateCreation,
      dateExpiration: dateExpiration,
      imagePath: imagePath,
      localisation: localisation,
      numtel: numtel.isEmpty ? null : numtel,
      mail: mail,
      prix: prixValue,
      categories: categories,
      description: description.isEmpty ? null : description,
    );
  }
}
