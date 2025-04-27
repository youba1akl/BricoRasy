// lib/screens/tools_list_screen.dart
import 'package:flutter/material.dart';
import 'package:bricorasy/models/dummy_tool.dart';
import 'package:bricorasy/widgets/tool_card.dart';

final List<DummyTool> dummyTools = [
  DummyTool(
    id: 'tool-001',
    name: "Perceuse sans fil (Drill)",
    description: "Powerful cordless drill for various tasks.",
    imageUrl:
        "https://i.postimg.cc/c19zpJ6f/Image-Popular-Product-1.png",
    price: 12000.00,
    isFavourite: true,
  ),
  DummyTool(
    id: 'tool-002',
    name: "Scie sauteuse (Jigsaw)",
    description: "Precision cutting for wood and other materials.",
    imageUrl:
        "https://i.postimg.cc/CxD6nH74/Image-Popular-Product-2.png",
    price: 8500.00,
  ),
  DummyTool(
    id: 'tool-003',
    name: "Ponceuse vibrante (Orbital Sander)",
    description: "Smooth finishing for surfaces.",
    imageUrl: "https://i.postimg.cc/1XjYwvbv/glap.png",
    price: 6000.00,
    isFavourite: true,
  ),
  DummyTool(
    id: 'tool-004',
    name: "Marteau piqueur (Demolition Hammer)",
    description: "Heavy-duty tool for breaking concrete.",
    imageUrl:
        "https://i.postimg.cc/d1QWXMYW/Image-Popular-Product-3.png",
    price: 35000.00,
  ),
  DummyTool(
    id: 'tool-005',
    name: "Clé à molette (Adjustable Wrench)",
    description: "Essential for tightening and loosening nuts.",
    imageUrl: "",
    price: 1500.00,
  ),
];

class ToolsListScreen extends StatelessWidget {
  const ToolsListScreen({Key? key}) : super(key: key);

  void _onAddTool(BuildContext context) {
    // TODO: Navigate to AddToolScreen
    print('Navigate to Add Tool Screen');
  }

  void _onToolDetail(BuildContext context, DummyTool tool) {
    // TODO: Navigate to ToolDetailScreen
    print('Navigate to detail for: ${tool.name}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Outils"),
        backgroundColor: Colors.amber,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _onAddTool(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: GridView.builder(
            itemCount: dummyTools.length,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              mainAxisSpacing: 20,
              crossAxisSpacing: 16,
              childAspectRatio: 0.7,
            ),
            itemBuilder: (context, index) {
              final tool = dummyTools[index];
              return ToolCard(
                tool: tool,
                onPress: () => _onToolDetail(context, tool),
              );
            },
          ),
        ),
      ),
    );
  }
}
