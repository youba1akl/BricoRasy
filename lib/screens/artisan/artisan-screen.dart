// lib/screens/artisan/artisan-screen.dart

import 'dart:convert';
import 'package:bricorasy/models/artisan.model.dart'; // Ensure correct path
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Import the profile screen for navigation
import 'package:bricorasy/screens/artisan/artisan-profil-screen.dart'; // Ensure correct path

// Import the styled widgets (adjust paths if necessary)
import 'package:bricorasy/widgets2/search_form.dart';
// import 'package:bricorasy/widgets2/horizontal_filter_bar.dart'; // REMOVE THIS IMPORT
import 'package:bricorasy/widgets2/artisan_filter_bar.dart';     // <-- ADD THIS IMPORT
import 'package:bricorasy/widgets/artisan_list_item.dart';

class Artisantscreen extends StatefulWidget {
  const Artisantscreen({super.key});

  @override
  State<Artisantscreen> createState() => _ArtisantscreenState();
}

class _ArtisantscreenState extends State<Artisantscreen> {
  List<Artisan> _artisans = [];
  List<Artisan> _filteredArtisans = [];
  bool _isLoading = true;
  String _selectedFilter = 'Tout'; // Default filter: 'Tout' is one of our artisan filters
  String _searchQuery = '';

  // This list is now consistent with ArtisanFilterBar, but ArtisanFilterBar has its own copy.
  // You could remove this if ArtisanFilterBar is the sole source of truth for these strings.
  // However, it can be useful to keep it here for validating _selectedFilter or other logic.
  final List<String> _artisanFilters = ['Tout', 'Bien Noté', 'Mal Noté'];

  @override
  void initState() {
    super.initState();
    // Ensure _selectedFilter is a valid option from _artisanFilters
    if (!_artisanFilters.contains(_selectedFilter)) {
        _selectedFilter = _artisanFilters.first; // Default to 'Tout'
    }
    _loadArtisans();
  }

  Future<void> _loadArtisans() async {
    // ... (keep existing _loadArtisans logic)
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final String response = await rootBundle.loadString(
        'assets/json/artisan.json',
      );
      final List<dynamic> data = json.decode(response);
      if (mounted) {
        setState(() {
          _artisans = data.map((e) => Artisan.fromJson(e)).toList();
          _applyFilters();
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
          SnackBar(
            content: Text("Erreur de chargement des artisans: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _applyFilters() {
    List<Artisan> tempFiltered = List.from(_artisans);

    if (_searchQuery.isNotEmpty) {
      final queryLower = _searchQuery.toLowerCase();
      tempFiltered =
          tempFiltered.where((artisan) {
            return artisan.fullname.toLowerCase().contains(queryLower) ||
                artisan.job.toLowerCase().contains(queryLower) ||
                artisan.adress.toLowerCase().contains(queryLower);
          }).toList();
    }

    // Now this logic will work correctly with selections from ArtisanFilterBar
    if (_selectedFilter == 'Bien Noté') {
      tempFiltered =
          tempFiltered.where((a) {
            final ratingValue =
                double.tryParse(a.rating.replaceAll(',', '.')) ??
                0.0;
            return ratingValue >= 4.0;
          }).toList();
      print("Filtering: Bien Noté");
    } else if (_selectedFilter == 'Mal Noté') {
      tempFiltered =
          tempFiltered.where((a) {
            final ratingValue =
                double.tryParse(a.rating.replaceAll(',', '.')) ?? 0.0;
            return ratingValue < 3.0;
          }).toList();
      print("Filtering: Mal Noté");
    }
    // 'Tout' implies no additional rating filter beyond the search query

    if (mounted) {
      setState(() {
        _filteredArtisans = tempFiltered;
      });
    }
  }

  void _handleSearch(String query) {
    // ... (keep existing _handleSearch logic)
    print("Searching artisans: $query");
    _searchQuery = query;
    _applyFilters();
  }

  void _handleFilterTap() {
    // ... (keep existing _handleFilterTap logic)
    print("Artisan filter icon tapped!");
  }

  void _handleFilterSelection(String filter) {
    // This 'filter' will now be "Tout", "Bien Noté", or "Mal Noté"
    if (!mounted) return;
    print("Filter selected from ArtisanFilterBar: $filter");
    setState(() {
      _selectedFilter = filter;
    });
    _applyFilters();
  }

  void _navigateToProfile(Artisan artisan) {
    // ... (keep existing _navigateToProfile logic)
     Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => Artisanprofilscreen(
              username: artisan.fullname,
              job: artisan.job,
              like: artisan.like,
              loc: artisan.adress,
              rating: artisan.rating,
              imgProvider: AssetImage(artisan.image),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Container(
      color: backgroundColor,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 16.0,
              left: 16.0,
              right: 16.0,
              bottom: 8.0,
            ),
            child: SearchForm(
              onSearch: _handleSearch,
              onFilterTap: _handleFilterTap,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: ArtisanFilterBar( // <-- USE THE NEW WIDGET HERE
              selectedFilter: _selectedFilter,
              onFilterSelected: _handleFilterSelection,
            ),
          ),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredArtisans.isEmpty
                    ? const Center(
                      child: Text("Aucun artisan trouvé."),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.only(
                        left: 16.0,
                        right: 16.0,
                        bottom: 16.0,
                        top: 8.0,
                      ),
                      itemCount: _filteredArtisans.length,
                      itemBuilder: (context, index) {
                        final artisan = _filteredArtisans[index];
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: 12.0,
                          ),
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