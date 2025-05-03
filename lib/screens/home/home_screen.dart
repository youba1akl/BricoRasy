// lib/screens/home/home_screen.dart

import 'package:flutter/material.dart';

// Model Imports
import 'package:bricorasy/models/bricole_service.dart';
import 'package:bricorasy/models/dummy_tool.dart'; // Ensure DummyTool is imported

// Widget Imports
import 'package:bricorasy/widgets2/search_form.dart';
import 'package:bricorasy/widgets2/horizontal_filter_bar.dart';
import 'package:bricorasy/widgets2/home/service_list_view.dart';
import 'package:bricorasy/widgets2/home/tool_grid_view.dart';
import 'package:bricorasy/services/HomePage_service.dart';
// Import the detail screens if needed for other navigation callbacks
import 'package:bricorasy/screens/home/bricole-screen.dart';
import 'package:bricorasy/screens/tool_detail/tool_detail_screen.dart'; // Import ToolDetailScreen

// Define the background color (or get from theme)
const kAppBackgroundColor = Color(0xFFFFF0E8); // Example: Light Pinkish-Beige

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedFilter = 'Bricole'; // Default filter

  // --- Callbacks ---
  void _selectFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    print("Filter selected: $filter");
  }

  void _onSearchSubmitted(String query) {
    print('Searching for: "$query" in $_selectedFilter context');
    // TODO: Implement search logic
  }

  void _onFilterIconTap() {
    print("Filter icon tapped!");
    // TODO: Implement filter options popup/dialog
  }

  // Callback for Service Tapped (navigates within ServiceListView now)
  void _onServiceTapped(BricoleService service) {
    print("Service tapped in HomeScreen (can add logic here if needed): ${service.name}");
    // Navigation is handled inside ServiceListView, but you could add
    // analytics or other logic here if required.
  }

  // --- UPDATED Callback for Tool Tapped ---
  void _onToolTapped(DummyTool tool) { // Changed parameter type to DummyTool
    print("Tool tapped in HomeScreen (can add logic here if needed): ${tool.name}");
    // Navigation is handled inside ToolGridView now.
    // You could add analytics or other logic here.

    // Example: If you wanted navigation triggered from HomeScreen instead:
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (_) => ToolDetailScreen(tool: tool),
    //   ),
    // );
  }
  // --- End UPDATED Callback ---

  // --- Helper to build the main content area ---
  Widget _buildCurrentContent() {
    switch (_selectedFilter) {
      case 'Objet':
        return FutureBuilder<List<DummyTool>>(
          future: apiService_outil.fetchTools(), // Assuming this fetches List<DummyTool>
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              // Consider showing a more user-friendly error widget
              print("Error fetching tools: ${snapshot.error}"); // Log the error
              return Center(child: Text('Erreur de chargement des outils.'));
            }
            // Use hasData check for robustness
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Aucun outil disponible'));
            }
            final tools = snapshot.data!;
            // Pass the _onToolTapped callback (which now accepts DummyTool)
            return ToolGridView(tools: tools, onToolTapped: _onToolTapped);
          },
        );
      case 'Professionnel':
        // TODO: Implement fetching for professional services
        return ServiceListView(
          services: const [], // Placeholder empty list
          onServiceTapped: _onServiceTapped, // Pass the service callback
        );
      case 'Bricole':
      default:
        return FutureBuilder<List<BricoleService>>(
          future: apiservice.fetchServices(), // Assuming this fetches List<BricoleService>
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              print("Error fetching services: ${snapshot.error}"); // Log the error
              return Center(child: Text('Erreur de chargement des services.'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Aucun service disponible'));
            }
            final services = snapshot.data!;
            // Pass the _onServiceTapped callback
            return ServiceListView(
              services: services,
              onServiceTapped: _onServiceTapped,
            );
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use theme background color if available, otherwise fallback
    final Color backgroundColor =
        Theme.of(context).scaffoldBackgroundColor ?? kAppBackgroundColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar Area
            Padding(
              padding: const EdgeInsets.only(
                top: 16.0,
                left: 16.0,
                right: 16.0,
              ),
              // Pass the actual callbacks
              child: SearchForm(
                  onSearch: _onSearchSubmitted, onFilterTap: _onFilterIconTap),
            ),
            const SizedBox(height: 16),

            // Filter Bar Area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              // Pass the actual callback
              child: HorizontalFilterBar(
                selectedFilter: _selectedFilter,
                onFilterSelected: _selectFilter, // Use the state update method
              ),
            ),

            // Dynamic Content Area
            Expanded(
              child: _buildCurrentContent(), // Use the helper method
            ),
          ],
        ),
      ),
      // bottomNavigationBar: BottomNavigationBar(...), // Add if needed
    );
  }
}