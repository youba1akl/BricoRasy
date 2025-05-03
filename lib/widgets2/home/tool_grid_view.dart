// lib/widgets2/home/tool_grid_view.dart

import 'package:flutter/material.dart';
// Import your ToolCard (adjust path if needed)
import 'package:bricorasy/widgets2/tool_card.dart';
// Import the Tool model (adjust path if needed)
import 'package:bricorasy/models/dummy_tool.dart';
// Import the new detail screen (adjust path if needed)
import 'package:bricorasy/screens/tool_detail/tool_detail_screen.dart';

class ToolGridView extends StatelessWidget {
  // Now expects a List of DummyTool objects
  final List<DummyTool> tools;
  // Callback now accepts a DummyTool object
  final Function(DummyTool) onToolTapped;

  const ToolGridView({
    super.key,
    required this.tools,
    required this.onToolTapped, // Updated signature
  });

  @override
  Widget build(BuildContext context) {
    // Consistent padding for the grid content area
    const EdgeInsets contentPadding = EdgeInsets.only(
        top: 12.0, left: 16.0, right: 16.0, bottom: 16.0);

    // Handle empty list case gracefully
    if (tools.isEmpty) {
      return const Center(
        child: Padding(
          padding: contentPadding,
          child: Text('Aucun outil disponible pour le moment.'),
        ),
      );
    }

    return Padding( // Add padding around the GridView itself
      padding: contentPadding,
      child: GridView.builder(
        // Use the length of the tool list
        itemCount: tools.length,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200, // Max width for each item
          mainAxisSpacing: 18,     // Vertical spacing
          crossAxisSpacing: 16,    // Horizontal spacing
          childAspectRatio: 0.75,  // Adjust if needed for ToolCard content
        ),
        itemBuilder: (context, index) {
          final currentTool = tools[index]; // Get the DummyTool object
          // Use your ToolCard widget
          return ToolCard(
            // Pass the DummyTool object to ToolCard
            // Ensure ToolCard's constructor accepts DummyTool tool;
            tool: currentTool,
            onPress: () {
              // --- Navigation Logic ---
              Navigator.push(
                context,
                MaterialPageRoute(
                  // Navigate to ToolDetailScreen, passing the tool object
                  builder: (_) => ToolDetailScreen(tool: currentTool),
                ),
              );
              // Optionally call the original callback if needed elsewhere
              // onToolTapped(currentTool);
              // --- End Navigation Logic ---
            },
          );
        },
      ),
    );
  }
}