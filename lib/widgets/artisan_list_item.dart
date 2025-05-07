// lib/widgets/artisan_list_item.dart
import 'package:flutter/material.dart';
import 'package:bricorasy/models/artisan.model.dart'; // Import your Artisan model

class ArtisanListItem extends StatelessWidget {
  final Artisan artisan;
  final VoidCallback onTap;

  const ArtisanListItem({
    super.key,
    required this.artisan,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color cardColor = Theme.of(context).cardColor;
    final Color shadowColor = Theme.of(context).shadowColor.withOpacity(0.05);
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color onSurfaceVariantColor = Theme.of(context).colorScheme.onSurfaceVariant;
    final Color starColor = Colors.amber; // Or use theme accent color

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        padding: const EdgeInsets.all(12.0), // Internal padding
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 28, // Slightly larger avatar
              backgroundColor: Colors.grey[200], // Placeholder background
              backgroundImage: AssetImage(artisan.image), // Use AssetImage
              // Handle image errors if necessary
              onBackgroundImageError: (exception, stackTrace) {
                 print("Error loading artisan image: ${artisan.image}");
              },
            ),
            const SizedBox(width: 12),

            // Info Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    artisan.fullname,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${artisan.job} - ${artisan.adress}", // Combine job and address
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: onSurfaceVariantColor,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Rating Column
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(Icons.star_rounded, color: starColor, size: 20),
                const SizedBox(height: 2),
                Text(
                  artisan.rating, // Assuming rating is a String
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: starColor,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}