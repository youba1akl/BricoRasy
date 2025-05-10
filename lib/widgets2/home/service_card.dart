import 'package:flutter/material.dart';
import 'package:bricorasy/models/bricole_service.dart'; // Your model import

/// Main Service Card Widget
class ServiceInfoBigCard extends StatelessWidget {
  final BricoleService service;
  final VoidCallback press;

  const ServiceInfoBigCard({
    super.key,
    required this.service,
    required this.press,
  });

  @override
  Widget build(BuildContext context) {
    final mutedTextColor = Theme.of(context).colorScheme.onSurfaceVariant;
    final cardBackgroundColor = Theme.of(context).cardColor;
    final shadowColor = Theme.of(context).shadowColor.withOpacity(0.04);

    return Container(
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: press,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ServiceImageDisplay(imagePath: service.imagePath),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 5),
                  CategoriesDisplay(categories: service.categories),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        service.prix.toString(),
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: mutedTextColor),
                      ),
                      const SizedBox(width: 15),
                      Text(
                        service.localisation,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: mutedTextColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Displays the list of categories under the title
class CategoriesDisplay extends StatelessWidget {
  final List<String> categories;
  const CategoriesDisplay({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    return Text(
      categories.join("  •  "),
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Loads an image from the network with a placeholder & error fallback
class ServiceImageDisplay extends StatelessWidget {
  final String imagePath;
  const ServiceImageDisplay({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.8,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: Image.network(
          imagePath,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            final total = progress.expectedTotalBytes;
            final loaded = progress.cumulativeBytesLoaded;
            return Center(
              child: CircularProgressIndicator(
                value: total != null ? loaded / total : null,
              ),
            );
          },
          errorBuilder:
              (context, error, stackTrace) => Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 40,
                ),
              ),
        ),
      ),
    );
  }
}
