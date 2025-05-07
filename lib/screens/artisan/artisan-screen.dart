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
  // This list is currently NOT being used to populate the HorizontalFilterBar
  // due to the constraint of not changing HorizontalFilterBar.
  final List<String> _artisanFilters = ['Tout', 'Bien Noté', 'Mal Noté'];

  @override
  void initState() {
    super.initState();
    _loadArtisans();
  }

  Future<void> _loadArtisans() async {
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

    // IMPORTANT: This logic relies on _selectedFilter being "Bien Noté" or "Mal Noté".
    // If HorizontalFilterBar sets _selectedFilter to "Bricole", "Professionnel", or "Objet",
    // this specific rating filter logic will not be triggered as intended by clicks on that bar.
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

    if (mounted) {
      setState(() {
        _filteredArtisans = tempFiltered;
      });
    }
  }

  void _handleSearch(String query) {
    print("Searching artisans: $query");
    _searchQuery = query;
    _applyFilters();
  }

  void _handleFilterTap() {
    print("Artisan filter icon tapped!");
    // Potentially show a different filter UI that uses _artisanFilters
  }

  void _handleFilterSelection(String filter) {
    if (!mounted) return;
    // 'filter' will be "Bricole", "Professionnel", or "Objet" coming from HorizontalFilterBar
    print("Filter selected from HorizontalFilterBar: $filter");
    setState(() {
      _selectedFilter = filter; // _selectedFilter now holds "Bricole", "Professionnel", or "Objet"
    });
    _applyFilters(); // _applyFilters will run, but its conditions for 'Bien Noté'/'Mal Noté' might not match
  }

  void _navigateToProfile(Artisan artisan) {
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
            child: HorizontalFilterBar(
              selectedFilter: _selectedFilter,
              onFilterSelected: _handleFilterSelection,
              // filters: _artisanFilters, // <-- REMOVED THIS LINE TO FIX THE ERROR
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
                      itemCount:
                          _filteredArtisans.length,
                      itemBuilder: (context, index) {
                        final artisan =
                            _filteredArtisans[index];
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