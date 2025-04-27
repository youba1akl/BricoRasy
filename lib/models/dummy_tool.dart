// lib/models/dummy_tool.dart
class DummyTool {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final bool isFavourite;

  const DummyTool({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    this.isFavourite = false,
  });
}
