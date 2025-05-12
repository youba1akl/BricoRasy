// lib/models/artisan.model.dart
import 'package:bricorasy/models/tarif_item.model.dart';
class Artisan {
  final String? id; // Optional: Corresponds to backend's _id for the User acting as Artisan
  final String fullname;
  final String job;
  final String localisation; // This is 'localisation' from User model
  final String numTel;     // This maps to 'phone' from User model
  final String rating;     // This might be an aggregated value or a placeholder from your data
  final String image;      // This maps to 'profilePicture' or 'photo' from User model
  final String like;
  final List<TarifItem> tarifs;       // This might be an aggregated value or a placeholder

  Artisan({
    this.id,
    required this.fullname,
    required this.job,
    required this.localisation,
    required this.numTel,
    required this.rating,
    required this.image, // Can be an empty string if no image
    required this.like,
    this.tarifs = const [],
  });

  // --- Helper static methods for JSON parsing ---
  /// Safely gets a string from a JSON value, providing a default if null or not a string.
  static String _getString(dynamic value, [String defaultValue = '']) {
    return value is String ? value : defaultValue;
  }

  /// Safely gets a string from a list of potential keys in JSON, providing a default.
  static String _getStringFromKeys(Map<String, dynamic> json, List<String> keys, [String defaultValue = '']) {
    for (String key in keys) {
      if (json.containsKey(key) && json[key] != null && json[key] is String) {
        return json[key] as String;
      }
    }
    return defaultValue;
  }
  // --- End of Helper static methods ---

  factory Artisan.fromJson(Map<String, dynamic> json) {
    List<TarifItem> parsedTarifs = [];
    if (json['tarifs'] != null && json['tarifs'] is List) {
      parsedTarifs = (json['tarifs'] as List)
          .map((item) => TarifItem.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return Artisan(
      id: _getString(json['_id']),
      fullname: _getString(json['fullname'], 'Nom Inconnu'),
      job: _getString(json['job'], 'Profession non spécifiée'),
      localisation: _getStringFromKeys(json, ['localisation', 'adress'], 'Lieu inconnu'),
      numTel: _getStringFromKeys(json, ['phone', 'numTel']),
      rating: json['rating']?.toString() ?? 'N/A',
      image: _getStringFromKeys(json, ['profilePicture', 'photo', 'image']),
      like: json['like']?.toString() ?? '0',
      tarifs: parsedTarifs, // <-- PARSE TARIFS
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null && id!.isNotEmpty) '_id': id,
        'fullname': fullname,
        'job': job,
        'localisation': localisation,
        'phone': numTel, // Map back to User schema field name
        'rating': rating,
        'profilePicture': image, // Map back to User schema field name
        'like': like,
        'tarifs': tarifs.map((tarif) => tarif.toJson()).toList(), // <-- SERIALIZE TARIFS
      };
}