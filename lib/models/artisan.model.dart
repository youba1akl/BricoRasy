class Artisan {
  final String fullname;
  final String job;
  final String adress;
  final String numTel;
  final String rating;
  final String image;
  final String like;

  Artisan({
    required this.fullname,
    required this.job,
    required this.adress,
    required this.numTel,
    required this.rating,
    required this.image,
    required this.like,
  });

  factory Artisan.fromJson(Map<String, dynamic> json) {
    return Artisan(
      fullname: json['fullname'] ?? '',
      job: json['job'] ?? '',
      adress: json['adress'] ?? '',
      numTel: json['numTel'] ?? '',
      rating: json['rating'] ?? '',
      image: json['image'] ?? '',
      like: json['like'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullname': fullname,
      'job': job,
      'adress': adress,
      'numTel': numTel,
      'rating': rating,
      'image': image,
      'like': like,
    };
  }
}
