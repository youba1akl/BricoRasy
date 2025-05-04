// lib/widgets2/tool_card.dart (Example structure)

import 'package:flutter/material.dart';
import 'package:bricorasy/models/dummy_tool.dart'; // Import the model

class ToolCard extends StatelessWidget {
  // Accept DummyTool object
  final DummyTool tool;
  final VoidCallback onPress;

  const ToolCard({
    super.key,
    required this.tool, // Changed parameter name and type
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    // Access data directly from the tool object
    final imageUrl = tool.imagePath;
    final toolName = tool.name;
    final price = tool.price; // Assuming price is double in model
    // final isFavourite = tool.isFavourite; // Add if your model has this

    // Define colors (consider making these theme-based)
    final Color toolPriceColor = Colors.deepOrange.shade700;
    final Color toolIconColor = Colors.grey.shade400;
    // final Color toolFavColor = Colors.red.shade400;
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
                          child: Image.network( // Use Image.network for URLs
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
                            child: Icon(Icons.construction_outlined, // Tool icon
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
                    "${price.toStringAsFixed(2)} DA", // Format price
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: toolPriceColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  // Add favorite icon back if needed and if model supports it
                  // Icon(
                  //   isFavourite ? Icons.favorite : Icons.favorite_border,
                  //   color: isFavourite ? toolFavColor : toolIconColor,
                  //   size: 18,
                  // ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}