import 'package:bricorasy/models/dummy_tool.dart';
import 'package:flutter/material.dart';
import 'package:bricorasy/widgets2/tool_card.dart'; // Import your ToolCard

class ToolGridView extends StatelessWidget {
  // Accept Map for now, change to List<DummyTool> later
  final List<DummyTool> tools;
  // Pass the specific tool data (Map) on tap
  final Function(DummyTool) onToolTapped;

  const ToolGridView({
    super.key,
    required this.tools,
    required this.onToolTapped,
  });

  @override
  Widget build(BuildContext context) {
    // Consistent padding for the grid content area
    const EdgeInsets contentPadding = EdgeInsets.only(top: 12.0, left: 16.0, right: 16.0, bottom: 16.0);

    return Padding( // Add padding around the GridView itself
      padding: contentPadding,
      child: GridView.builder(
        itemCount: tools.length,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200, // Max width for each item
          mainAxisSpacing: 18,     // Vertical spacing
          crossAxisSpacing: 16,    // Horizontal spacing
          childAspectRatio: 0.75,  // Adjust aspect ratio if needed for ToolCard content
        ),
        itemBuilder: (context, index) {
          final toolData = tools[index];
          // Use your ToolCard widget!
          return ToolCard(
            toolData: toolData,
            onPress: () => onToolTapped(toolData), // Pass the specific tool's data
          );
        },
      ),
    );
  }
}