// lib/models/artisan.model.dart

class Artisan {
  final String fullname;
  final String job;
  final String localisation;
  final String numTel;
  final String rating;
  final String image;
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
    // ➊ Merge any possible key names for “address”
    final loc =
        json['localisation'] ??
        json['adress'] // fallback if your server used “adress”
        ??
        '';

    return Artisan(
      fullname: json['fullname'] ?? '',
      job: json['job'] ?? '',
      localisation: loc,
      numTel: json['numTel'] ?? '',
      rating: json['rating'] ?? '',
      image: json['image'] ?? '',
      like: json['like'] ?? '',
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
