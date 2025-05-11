class PostArtisanInfo {
  final String id;
  final String fullname;
  // Add profilePicture if your backend populates it for posts

  PostArtisanInfo({required this.id, required this.fullname});

  factory PostArtisanInfo.fromJson(Map<String, dynamic> json) {
    return PostArtisanInfo(
      id: json['_id'] as String,
      fullname: json['fullname'] as String,
    );
  }
}

class Post {
  final String id; // MongoDB _id
  final String description;
  final List<String> images; // URLs of images
  final PostArtisanInfo artisan; // Populated artisan info
  final String? title; // Added based on your requirement
  final String? phone; // Added
  final String? email; // Added
  final DateTime createdAt;
  final DateTime updatedAt;
  // final List<String> likes; // List of user IDs who liked (simplified for now)
  // final List<dynamic> comments; //  (simplified for now)

  Post({
    required this.id,
    required this.description,
    required this.images,
    required this.artisan,
    this.title,
    this.phone,
    this.email,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['_id'] as String,
      description: json['description'] as String,
      images: List<String>.from(json['images'] as List? ?? []),
      // Backend populates 'artisanId' as 'artisan' with fullname
      artisan: PostArtisanInfo.fromJson(json['artisanId'] as Map<String, dynamic>? ?? {'_id':'unknown', 'fullname':'Unknown Artisan'}),
      title: json['title'] as String?, // Assuming backend will add these
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}