// lib/screens/price_catalog_screen.dart
import 'package:bricorasy/data/price_catalog_data.dart'; // Import your data
import 'package:bricorasy/models/price_catalog_item.dart'; // Import your models
import 'package:flutter/material.dart';

class PriceCatalogScreen extends StatelessWidget {
  const PriceCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalogue de Prix Indicatifs'),
        backgroundColor: colorScheme.surface,
        elevation: 1,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: priceCatalogData.length,
        itemBuilder: (context, index) {
          final category = priceCatalogData[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            elevation: 2.0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            child: ExpansionTile(
              backgroundColor: colorScheme.surfaceVariant.withOpacity(0.2),
              collapsedBackgroundColor: colorScheme.surface,
              iconColor: colorScheme.primary,
              collapsedIconColor: colorScheme.onSurfaceVariant,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)), // To avoid border conflict
              title: Text(
                category.name,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
              childrenPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              children: category.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 3, // Give more space to service name
                        child: Text(
                          item.service,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        flex: 2, // Give enough space for price
                        child: Text(
                          item.priceRange,
                          textAlign: TextAlign.right,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: colorScheme.secondary, // Or primary
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}