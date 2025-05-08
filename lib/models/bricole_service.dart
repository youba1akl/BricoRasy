
class BricoleService {
  final String id;
  final String name;
  final String date_creation;
  final String date_exp;
  final String imagePath;
  final String localisation;

  final double prix;
  final List<String> categories;

  BricoleService({
    required this.id,
    required this.name,
    required this.date_creation,
    required this.date_exp,
    required this.imagePath,
    required this.localisation,
    required this.prix,
    required this.categories,
  });

  factory BricoleService.fromJson(Map<String, dynamic> json) {

    double prixValue;
  final rawPrix = json['prix'];
  if (rawPrix is num) {
    prixValue = rawPrix.toDouble();
  } else if (rawPrix is Map<String, dynamic> && rawPrix.containsKey(r'$numberDecimal')) {
    prixValue = double.parse(rawPrix[r'$numberDecimal'] as String);
  } else {
    prixValue = 0.0; 
  }

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

      prix: prixValue,
      categories: [json['type_annonce'] as String],
    );
  }
}


