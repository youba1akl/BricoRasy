class DummyTool {
  final String id;
  final String localisation;
  final String dateCreation;
  final String dureeLocation;
  final String typeAnnonce;
  final String name;
  final String description;
  final String imagePath;
  final double price;
  final String phone; // ← new
  final String idc; // ← new

  const DummyTool({
    required this.id,
    required this.localisation,
    required this.dateCreation,
    required this.dureeLocation,
    required this.typeAnnonce,
    required this.name,
    required this.description,
    required this.imagePath,
    required this.price,
    required this.phone,
    required this.idc,
  });

  factory DummyTool.fromJson(Map<String, dynamic> json) {
    // Safely parse fields that may be null
    final String id = json['_id'] as String? ?? '';
    final String name = json['titre'] as String? ?? '';
    final String localisation = json['localisation'] as String? ?? '';
    final String dateCreation = json['date_creation'] as String? ?? '';
    final String dureeLocation = json['duree_location'] as String? ?? '';
    final String typeAnnonce = json['type_annonce'] as String? ?? '';
    final String description = json['description'] as String? ?? '';
    final String phone = json['phone'] as String? ?? '';
    final String idc = json['idc'] as String? ?? '';

    // Parse price (handles Decimal128 or number)
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

    // Parse photos array and build full URL
    String imgUrl = '';
    if (json['photo'] is List) {
      final photos = (json['photo'] as List).whereType<String>().toList();
      if (photos.isNotEmpty) {
        imgUrl = 'http://10.0.2.2:5000/uploads/${photos.first}';
      }
    }

    return DummyTool(
      id: id,
      name: name,
      localisation: localisation,
      dateCreation: dateCreation,
      dureeLocation: dureeLocation,
      typeAnnonce: typeAnnonce,
      description: description,
      imagePath: imgUrl,
      price: prixValue,
      phone: phone,
      idc: idc,
    );
  }
}
