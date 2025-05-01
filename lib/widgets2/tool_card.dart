import 'package:flutter/material.dart';

class ToolCard extends StatelessWidget {
  // Accept Map for now, change to DummyTool later
  final Map<String, dynamic> toolData;
  final VoidCallback onPress;

  const ToolCard({
    super.key,
    required this.toolData,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    // Extract data from the map
    final imageUrl = toolData['imageUrl'] as String? ?? ''; // Handle potential null
    final toolName = toolData['name'] as String? ?? 'Unnamed Tool';
    final price = toolData['price'] as String? ?? 'N/A';
    final isFavourite = toolData['isFavourite'] as bool? ?? false;

    // Define colors (consider making these theme-based)
    final Color toolPriceColor = Colors.deepOrange.shade700;
    final Color toolIconColor = Colors.grey.shade400;
    final Color toolFavColor = Colors.red.shade400;
    final Color toolCardBg = Theme.of(context).cardColor;
    final Color toolPlaceholderBg = Colors.grey.shade200;
    final Color toolShadowColor = Theme.of(context).shadowColor.withOpacity(0.06);

    return Container(
      decoration: BoxDecoration(
        color: toolCardBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: toolShadowColor,
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: InkWell(
        onTap: onPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Center(
                  child: imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Icon(
                                Icons.broken_image_outlined,
                                size: 40,
                                color: toolIconColor),
                            loadingBuilder:
                                (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                  child: CircularProgressIndicator(
                                      strokeWidth: 1.5,
                                      color: Colors.grey));
                            },
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                              color: toolPlaceholderBg,
                              borderRadius: BorderRadius.circular(8.0)),
                          child: Center(
                            child: Icon(Icons.construction_outlined,
                                size: 35, color: toolIconColor),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                toolName,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600, height: 1.3),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: toolPriceColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Icon(
                    isFavourite ? Icons.favorite : Icons.favorite_border,
                    color: isFavourite ? toolFavColor : toolIconColor,
                    size: 18,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}