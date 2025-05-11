// lib/models/artisan.model.dart
class Artisan {
  final String fullname;
  final String job;
  final String localisation;
  final String numTel;
  final String rating;
  final String image; // This can be an empty string
  final String like;

  Artisan({
    required this.fullname,
    required this.job,
    required this.localisation,
    required this.numTel,
    required this.rating,
    required this.image,
    required this.like,
  });

  factory Artisan.fromJson(Map<String, dynamic> json) {
    final loc = json['localisation'] ?? json['adress'] ?? '';
    // Ensure image defaults to empty string if null, not just missing
    String imagePath =
        json['profilePicture'] as String? ??
        json['photo'] as String? ??
        json['image'] as String? ??
        ''; // Default to empty string

    return Artisan(
      fullname: json['fullname'] ?? '',
      job: json['job'] ?? '',
      localisation: loc,
      numTel: json['numTel'] ?? '',
      rating: json['rating']?.toString() ?? '0',
      image: imagePath, // Will be "" if not found
      like: json['like']?.toString() ?? '0',
    );
  }

  Map<String, dynamic> toJson() => {
    'fullname': fullname,
    'job': job,
    'localisation': localisation,
    'numTel': numTel,
    'rating': rating,
    'image': image,
    'like': like,
  };
}
