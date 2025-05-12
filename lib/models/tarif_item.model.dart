// lib/models/tarif_item.model.dart
class TarifItem {
  String? id; // Optional: for MongoDB _id if subdocuments get them, or for client-side keying
  String serviceName;
  String price; // Can be a range like "1000 DA - 2000 DA" or "Contactez-moi"

  TarifItem({
    this.id,
    required this.serviceName,
    required this.price,
  });

  // Factory constructor to create from JSON (when fetching from backend)
  factory TarifItem.fromJson(Map<String, dynamic> json) {
    print("TarifItem.fromJson input: $json");
    return TarifItem(
      id: json['_id'] as String?, // If your subdocuments have IDs
      serviceName: json['serviceName'] as String? ?? '',
      price: json['price'] as String? ?? '',
      
    );
  }

  // Method to convert to JSON (when sending to backend)
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'serviceName': serviceName,
      'price': price,
    };
    if (id != null) {
      data['_id'] = id; // Only include if it exists (for updates)
    }
    return data;
  }
}