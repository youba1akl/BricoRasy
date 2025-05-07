// lib/screens/home/home_screen.dart

import 'package:flutter/material.dart';

// Model Imports
import 'package:bricorasy/models/bricole_service.dart';
import 'package:bricorasy/models/professional_service.dart';
import 'package:bricorasy/models/dummy_tool.dart';

// Widget Imports (ensure paths are correct)
import 'package:bricorasy/widgets2/search_form.dart'; // Assuming this is widgets2/home/search_form.dart based on previous context
import 'package:bricorasy/widgets2/horizontal_filter_bar.dart'; // Assuming this is widgets2/home/horizontal_filter_bar.dart
import 'package:bricorasy/widgets2/home/service_list_view.dart';
import 'package:bricorasy/widgets2/home/tool_grid_view.dart';
import 'package:bricorasy/widgets2/home/proService_listView.dart';

// Service Imports (ensure these are correctly defined and initialized)
// Make sure these apiService instances are initialized somewhere accessible, or pass them in.
// For simplicity, assuming they are global or accessible.
import 'package:bricorasy/services/HomePage_service.dart'; // Contains apiservice, apiService_pro, apiService_outil

// Import the detail screens (ensure paths are correct)
import 'package:bricorasy/screens/home/bricole-screen.dart';
import 'package:bricorasy/screens/tool_detail/tool_detail_screen.dart';
// --- Import for Professional Service Detail Screen ---
import 'package:bricorasy/screens/home/professional_detail_screen.dart';

// Define the background color (or get from theme)
const kAppBackgroundColor = Color(0xFFFFF0E8); // Example: Light Pinkish-Beige

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedFilter = 'Bricole'; // Default filter
  final List<String> _homeFilters = const ['Bricole', 'Professionnel', 'Outils'];

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
    // TODO: Implement search logic based on query and _selectedFilter
    // This might involve re-fetching data with search parameters.
  }

  void _onFilterIconTap() {
    print("Filter icon tapped!");
    // TODO: Implement advanced filter options popup/dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Fonctionnalité de filtre avancé non implémentée.")),
    );
  }

  // --- Navigation Callbacks ---
  void _onBricoleServiceTapped(BricoleService service) {
    print("Bricole Service tapped: ${service.name}");
    Navigator.push(
      context,
      MaterialPageRoute(
        // Assuming Bricolescreen also takes the full service object
        builder: (_) => Bricolescreen(service: service),
      ),
    );
  }

   void _onProfessionalServiceTapped(ProfessionalService service) {
    print("Professional Service tapped: ${service.name}, ID: ${service.id}");
    // --- MODIFIED: Navigate to ProfessionalDetailScreen passing service.id ---
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfessionalDetailScreen(serviceId: service.id), // Pass the service.id
      ),
    );
  }

  void _onToolTapped(DummyTool tool) {
    print("Tool tapped: ${tool.name}");
    Navigator.push(
      context,
      MaterialPageRoute(
        // Assuming ToolDetailScreen also takes the full tool object
        builder: (_) => ToolDetailScreen(tool: tool),
      ),
    );
  }
  // --- End Navigation Callbacks ---

  // --- Helper to build the main content area based on filter ---
  Widget _buildCurrentContent() {
    // Ensure your API service instances (apiservice, apiService_pro, apiService_outil)
    // are correctly initialized and accessible.
    // For example, they might be instantiated in initState or be singletons.
    // final HomePageService apiService = HomePageService(); // Or however you access them

    switch (_selectedFilter) {
      case 'Outils':
        return FutureBuilder<List<DummyTool>>(
          future: apiService_outil.fetchTools(), // From HomePage_service.dart
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
          future: apiService_pro.fetchServicePro(), // From HomePage_service.dart
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
      default:
        return FutureBuilder<List<BricoleService>>(
          future: apiservice.fetchServices(), // From HomePage_service.dart
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
        Theme.of(context).scaffoldBackgroundColor; // Prefer theme color

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 16.0, left: 16.0, right: 16.0, bottom: 8.0
              ),
              child: SearchForm( // From widgets2/home/search_form.dart
                onSearch: _onSearchSubmitted,
                onFilterTap: _onFilterIconTap,
                hintText: "Rechercher services ou outils...",
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: HorizontalFilterBar( // From widgets2/home/horizontal_filter_bar.dart
                selectedFilter: _selectedFilter,
                onFilterSelected: _selectFilter,
                filters: _homeFilters,
              ),
            ),
            Expanded(
              child: _buildCurrentContent(),
            ),
          ],
        ),
      ),
    );
  }
}