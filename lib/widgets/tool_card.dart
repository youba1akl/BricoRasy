// lib/widgets/tool_card.dart
import 'package:flutter/material.dart';
import 'package:bricorasy/models/dummy_tool.dart';

class ToolCard extends StatelessWidget {
  final double width;
  final double aspectRatio;
  final DummyTool tool;
  final VoidCallback onPress;

  const ToolCard({
    Key? key,
    this.width = 140,
    this.aspectRatio = 1.02,
    required this.tool,
    required this.onPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool hasValidImage = tool.imageUrl.isNotEmpty &&
        Uri.tryParse(tool.imageUrl)?.hasAbsolutePath == true;

    return GestureDetector(
      onTap: onPress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: aspectRatio,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF979797).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: hasValidImage
                  ? Image.network(
                      tool.imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(
                        child: Icon(Icons.broken_image,
                            color: Colors.grey, size: 40),
                      ),
                    )
                  : const Center(
                      child: Icon(Icons.construction,
                          color: Colors.grey, size: 40),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            tool.name,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${tool.price.toStringAsFixed(2)} DA",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFF7643),
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(50),
                onTap: () {
                  // TODO: toggle favorite
                  print("Favorite tapped for ${tool.name}");
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  height: 24,
                  width: 24,
                  decoration: BoxDecoration(
                    color: tool.isFavourite
                        ? const Color(0xFFFF7643).withOpacity(0.15)
                        : const Color(0xFF979797).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    tool.isFavourite ? Icons.favorite : Icons.favorite_border,
                    color: tool.isFavourite
                        ? const Color(0xFFFF4848)
                        : const Color(0xFFDBDEE4),
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
