// lib/screens/home/home_screen.dart

import 'package:flutter/material.dart';

// Model Imports
import 'package:bricorasy/models/bricole_service.dart';
import 'package:bricorasy/models/professional_service.dart';
import 'package:bricorasy/models/dummy_tool.dart';

// Widget Imports (ensure paths are correct)
import 'package:bricorasy/widgets2/search_form.dart';
import 'package:bricorasy/widgets2/horizontal_filter_bar.dart';
import 'package:bricorasy/widgets2/home/service_list_view.dart';
import 'package:bricorasy/widgets2/home/tool_grid_view.dart';
import 'package:bricorasy/widgets2/home/proService_listView.dart';

// Service Imports (ensure these are correctly defined and initialized)
import 'package:bricorasy/services/HomePage_service.dart';

// Import the detail screens (ensure paths are correct)
import 'package:bricorasy/screens/home/bricole-screen.dart';
import 'package:bricorasy/screens/tool_detail/tool_detail_screen.dart';
// TODO: Add import for Professional Service Detail Screen if you have one

// Define the background color (or get from theme)
const kAppBackgroundColor = Color(0xFFFFF0E8); // Example: Light Pinkish-Beige

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedFilter = 'Bricole'; // Default filter

  // --- MODIFIED: Renamed 'Objet' to 'Outils' ---
  final List<String> _homeFilters = const ['Bricole', 'Professionnel', 'Outils'];
  // --- End Modification ---

  // --- Callbacks ---
  void _selectFilter(String filter) {
    if (_selectedFilter != filter) {
      setState(() {
        _selectedFilter = filter;
      });
      print("Filter selected: $filter");
    }
  }

  void _onSearchSubmitted(String query) {
    print('Searching for: "$query" in $_selectedFilter context');
    // TODO: Implement search logic
  }

  void _onFilterIconTap() {
    print("Filter icon tapped!");
    // TODO: Implement advanced filter options popup/dialog
  }

  // --- Navigation Callbacks ---
  void _onBricoleServiceTapped(BricoleService service) {
    print("Bricole Service tapped: ${service.name}");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Bricolescreen(service: service),
      ),
    );
  }

   void _onProfessionalServiceTapped(ProfessionalService service) {
    print("Professional Service tapped: ${service.name}");
    // TODO: Navigate to Professional Service Detail Screen
     ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Navigation vers détail Pro non implémentée.'))
     );
  }

  void _onToolTapped(DummyTool tool) {
    print("Tool tapped: ${tool.name}");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ToolDetailScreen(tool: tool),
      ),
    );
  }
  // --- End Navigation Callbacks ---

  // --- Helper to build the main content area based on filter ---
  Widget _buildCurrentContent() {
    // --- MODIFIED: Changed case label to 'Outils' ---
    switch (_selectedFilter) {
      case 'Outils': // Changed from 'Objet'
    // --- End Modification ---
        return FutureBuilder<List<DummyTool>>(
          future: apiService_outil.fetchTools(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              print("Error fetching tools: ${snapshot.error}");
              return Center(child: Text('Erreur de chargement des outils.\n${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Aucun outil disponible'));
            }
            final tools = snapshot.data!;
            return ToolGridView(tools: tools, onToolTapped: _onToolTapped);
          },
        );

      case 'Professionnel':
        return FutureBuilder<List<ProfessionalService>>(
          future: apiService_pro.fetchServicePro(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
               print("Error fetching pro services: ${snapshot.error}");
              return Center(child: Text('Erreur de chargement des services Pro.\n${snapshot.error}'));
            }
             if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Aucun service professionnel disponible'));
            }
            final services = snapshot.data!;
            return ProserviceListView(
              services: services,
              onServiceTapped: _onProfessionalServiceTapped,
            );
          },
        );

      case 'Bricole':
      default: // Default to Bricole
        return FutureBuilder<List<BricoleService>>(
          future: apiservice.fetchServices(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              print("Error fetching bricole services: ${snapshot.error}");
              return Center(child: Text('Erreur de chargement des services Bricole.\n${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Aucun service bricole disponible'));
            }
            final services = snapshot.data!;
            return ServiceListView(
              services: services,
              onServiceTapped: _onBricoleServiceTapped,
            );
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor =
        Theme.of(context).scaffoldBackgroundColor ?? kAppBackgroundColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // --- Search Bar Area ---
            Padding(
              padding: const EdgeInsets.only(
                top: 16.0, left: 16.0, right: 16.0, bottom: 8.0
              ),
              child: SearchForm(
                onSearch: _onSearchSubmitted,
                onFilterTap: _onFilterIconTap,
                hintText: "Rechercher services ou outils...", // Updated hint
              ),
            ),

            // --- Filter Bar Area ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: HorizontalFilterBar(
                selectedFilter: _selectedFilter,
                onFilterSelected: _selectFilter,
                filters: _homeFilters, // Pass the updated filters list
              ),
            ),

            // --- Dynamic Content Area ---
            Expanded(
              child: _buildCurrentContent(),
            ),
          ],
        ),
      ),
      // bottomNavigationBar: BottomNavigationBar(...), // Add if needed
    );
  }
}