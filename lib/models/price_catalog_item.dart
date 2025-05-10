class PriceCatalogItem {
  final String service;
  final String priceRange;

  PriceCatalogItem({required this.service, required this.priceRange});
}

class PriceCategory {
  final String name;
  final List<PriceCatalogItem> items;

  PriceCategory({required this.name, required this.items});
}