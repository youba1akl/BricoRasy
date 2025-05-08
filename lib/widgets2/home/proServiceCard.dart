import 'package:flutter/material.dart';
import 'package:bricorasy/models/professional_service.dart'; // Import the model

// --- Main Service Card Widget ---
class ServiceInfoBigCardProf extends StatelessWidget {
  final ProfessionalService service;
  final VoidCallback press;
  const ServiceInfoBigCardProf({
    super.key,
    required this.service,
    required this.press,
  });

  @override
  Widget build(BuildContext context) {
    final Color mutedTextColor = Theme.of(context).colorScheme.onSurfaceVariant;
    final Color cardBackgroundColor = Theme.of(context).cardColor;
    final Color shadowColor = Theme.of(context).shadowColor.withOpacity(0.04);

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
        borderRadius: BorderRadius.circular(16), // Match container radius
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ServiceImageDisplay(
              imagePath: service.imagePath,
            ), // Use the widget below
            Padding(
              padding: const EdgeInsets.only(
                top: 10.0,
                left: 12.0,
                right: 12.0,
                bottom: 10.0,
              ),
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
                  CategoriesDisplay(
                    categories: service.categories,
                  ), // Use the widget below
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const SizedBox(width: 15),
                      Text(
                        service.prix.toString(),
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: mutedTextColor),
                      ),
                      const SizedBox(width: 15),
                      Text(service.localisation),
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

// --- Helper Widget for Categories ---
class CategoriesDisplay extends StatelessWidget {
  final List<String> categories;
  const CategoriesDisplay({super.key, required this.categories});
  @override
  Widget build(BuildContext context) {
    return Text(
      categories.join("  •  "), // Slightly more spacing for separator
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

// --- Helper Widget for Service Image ---
class ServiceImageDisplay extends StatelessWidget {
  final String imagePath;
  const ServiceImageDisplay({super.key, required this.imagePath});
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.8, // Consistent aspect ratio
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16),
        ), // Round top corners to match card
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) => Container(
                // Improved error display
                decoration: BoxDecoration(
                  color:
                      Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest, // Use a theme color for background
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
