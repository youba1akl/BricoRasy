import 'package:flutter/material.dart';

// Model Imports
import 'package:bricorasy/models/bricole_service.dart';
import 'package:bricorasy/models/professional_service.dart';
import 'package:bricorasy/models/dummy_tool.dart';

// Widget Imports
import 'package:bricorasy/widgets2/search_form.dart';
import 'package:bricorasy/widgets2/horizontal_filter_bar.dart';
import 'package:bricorasy/widgets2/home/service_list_view.dart';
import 'package:bricorasy/widgets2/home/tool_grid_view.dart';
import 'package:bricorasy/services/HomePage_service.dart';

import 'package:bricorasy/widgets2/home/proService_listView.dart';

// Define the background color (or get from theme)
const kAppBackgroundColor = Color(0xFFFFF0E8); // Example: Light Pinkish-Beige

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedFilter = 'Bricole'; // Default filter

  // --- Helper to build the main content area ---
  Widget _buildCurrentContent() {
    switch (_selectedFilter) {
      case 'Objet':
        return FutureBuilder<List<DummyTool>>(
          future: apiService_outil.fetchTools(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return const Center(child: CircularProgressIndicator());
            if (snapshot.hasError)
              return Center(child: Text('Erreur : ${snapshot.error}'));
            final services = snapshot.data!;
            if (services.isEmpty)
              return const Center(child: Text('Aucune annonce disponible'));
            return ToolGridView(tools: services, onToolTapped: (p0) {});
          },
        );
      case 'Professionnel':
        return FutureBuilder<List<ProfessionalService>>(
          future: apiService_pro.fetchServicePro(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return const Center(child: CircularProgressIndicator());
            if (snapshot.hasError)
              return Center(child: Text('Erreur : ${snapshot.error}'));
            final services = snapshot.data!;
            if (services.isEmpty)
              return const Center(child: Text('Aucune annonce disponible'));
            return ProserviceListView(
              services: services,
              onServiceTapped: (p0) {},
            );
          },
        );
      case 'Bricole':
      default:
        return FutureBuilder<List<BricoleService>>(
          future: apiservice.fetchServices(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return const Center(child: CircularProgressIndicator());
            if (snapshot.hasError)
              return Center(child: Text('Erreur : ${snapshot.error}'));
            final services = snapshot.data!;
            if (services.isEmpty)
              return const Center(child: Text('Aucune annonce disponible'));
            return ServiceListView(
              services: services,
              onServiceTapped: (p0) {},
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
      // Consider adding an AppBar here if you want one consistently on the home screen
      // appBar: AppBar(title: Text("BricoRasy"), ... ),
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
              child: SearchForm(onSearch: (p0) {}, onFilterTap: () {}),
            ),
            const SizedBox(height: 16),

            // Filter Bar Area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: HorizontalFilterBar(
                selectedFilter: _selectedFilter,
                onFilterSelected: (filter) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                },
              ),
            ),

            // No SizedBox needed here, content padding handles spacing below filter bar

            // Dynamic Content Area
            Expanded(
              child: _buildCurrentContent(), // Use the helper method
            ),
          ],
        ),
      ),
      // Add BottomNavigationBar if this HomeScreen is the main scaffold holding it
      // bottomNavigationBar: BottomNavigationBar(...),
    );
  }
}
