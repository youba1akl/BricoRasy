// lib/screens/artisan/artisan-screen.dart

import 'dart:convert';
import 'package:bricorasy/models/artisan.model.dart'; // Ensure correct path
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Import the profile screen for navigation
import 'package:bricorasy/screens/artisan/artisan-profil-screen.dart'; // Ensure correct path

// Import the styled widgets (adjust paths if necessary)
import 'package:bricorasy/widgets2/search_form.dart';
import 'package:bricorasy/widgets2/horizontal_filter_bar.dart';
import 'package:bricorasy/widgets/artisan_list_item.dart'; // Import the new list item

// Assuming kAppBackgroundColor is defined elsewhere or use theme
// const kAppBackgroundColor = Color(0xFFFFF0E8);

class Artisantscreen extends StatefulWidget {
  const Artisantscreen({super.key});

  @override
  State<Artisantscreen> createState() => _ArtisantscreenState();
}

class _ArtisantscreenState extends State<Artisantscreen> {
  List<Artisan> _artisans = []; // Original list loaded from JSON
  List<Artisan> _filteredArtisans = []; // List displayed after filtering
  bool _isLoading = true;
  String _selectedFilter = 'Tout'; // Default filter state
  String _searchQuery = ''; // Store current search query

  // Define filter options specifically for this screen
  final List<String> _artisanFilters = ['Tout', 'Bien Noté', 'Mal Noté'];

  @override
  void initState() {
    super.initState();
    _loadArtisans();
  }

  Future<void> _loadArtisans() async {
    if (!mounted) return;
    setState(() => _isLoading = true );
    try {
      // Ensure asset path is correct and declared in pubspec.yaml
      final String response = await rootBundle.loadString('assets/json/artisan.json');
      final List<dynamic> data = json.decode(response);
      if (mounted) {
        setState(() {
          _artisans = data.map((e) => Artisan.fromJson(e)).toList();
          _applyFilters(); // Apply initial filter (which includes search query if any)
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading artisans: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur de chargement des artisans: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- Filtering Logic ---
  void _applyFilters() {
     List<Artisan> tempFiltered = List.from(_artisans);

     // Apply search query filter
     if (_searchQuery.isNotEmpty) {
        final queryLower = _searchQuery.toLowerCase();
        tempFiltered = tempFiltered.where((artisan) {
           return artisan.fullname.toLowerCase().contains(queryLower) ||
                  artisan.job.toLowerCase().contains(queryLower) ||
                  artisan.adress.toLowerCase().contains(queryLower);
        }).toList();
     }

     // Apply rating filter
     // TODO: Implement actual rating logic based on your data/requirements
     // Ensure your Artisan model's rating field can be parsed to a number if needed.
     if (_selectedFilter == 'Bien Noté') {
        // Example: Keep artisans with rating >= 4.0 (adjust threshold)
        tempFiltered = tempFiltered.where((a) {
           final ratingValue = double.tryParse(a.rating.replaceAll(',', '.')) ?? 0.0; // Handle comma decimal
           return ratingValue >= 4.0;
        }).toList();
        print("Filtering: Bien Noté");
     } else if (_selectedFilter == 'Mal Noté') {
        // Example: Keep artisans with rating < 3.0 (adjust threshold)
         tempFiltered = tempFiltered.where((a) {
           final ratingValue = double.tryParse(a.rating.replaceAll(',', '.')) ?? 0.0;
           return ratingValue < 3.0;
        }).toList();
         print("Filtering: Mal Noté");
     }
     // 'Tout' doesn't require filtering by rating

     if (mounted) {
       setState(() {
          _filteredArtisans = tempFiltered;
       });
     }
  }


  // --- Callbacks ---
  void _handleSearch(String query) {
    print("Searching artisans: $query");
    // Update search query state and re-apply filters
    _searchQuery = query;
    _applyFilters();
  }

  void _handleFilterTap() {
    print("Artisan filter icon tapped!");
    // TODO: Implement advanced filter options popup/dialog if needed
  }

   void _handleFilterSelection(String filter) {
    if (!mounted) return;
    // Update filter state and re-apply filters
    setState(() {
      _selectedFilter = filter;
    });
    _applyFilters();
  }


  // --- Navigation Handler ---
  void _navigateToProfile(Artisan artisan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Artisanprofilscreen(
          username: artisan.fullname,
          job: artisan.job,
          like: artisan.like,
          loc: artisan.adress,
          rating: artisan.rating,
          imgProvider: AssetImage(artisan.image), // Pass AssetImage
        ),
      ),
    );
  }

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    // This widget returns a Column, assuming it's placed within a Scaffold's body
    // by a parent widget (like a main screen with BottomNavigationBar).
    return Container(
       color: backgroundColor, // Apply background color
       child: Column(
        children: [
          // --- Search Bar Area ---
          Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0, bottom: 8.0),
            child: SearchForm(
              onSearch: _handleSearch,
              onFilterTap: _handleFilterTap,
              hintText: "Rechercher un artisan...", // Specific hint text
            ),
          ),

          // --- Filter Bar ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: HorizontalFilterBar(
              selectedFilter: _selectedFilter,
              onFilterSelected: _handleFilterSelection,
              filters: _artisanFilters, // Pass the specific artisan filters
            ),
          ),

          // --- Loading or List Area ---
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredArtisans.isEmpty
                    ? const Center(child: Text("Aucun artisan trouvé.")) // Empty state message
                    : ListView.builder(
                        padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0, top: 8.0),
                        itemCount: _filteredArtisans.length, // Use filtered list length
                        itemBuilder: (context, index) {
                          final artisan = _filteredArtisans[index]; // Use filtered list item
                          // Use the new ArtisanListItem widget
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0), // Spacing between items
                            child: ArtisanListItem(
                              artisan: artisan,
                              onTap: () => _navigateToProfile(artisan),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}