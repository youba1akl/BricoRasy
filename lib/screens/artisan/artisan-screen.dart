// lib/screens/artisan/artisan-screen.dart

import 'package:flutter/material.dart';
import 'package:bricorasy/models/artisan.model.dart';
import 'package:bricorasy/services/artisan_services.dart';
import 'package:bricorasy/screens/artisan/artisan-profil-screen.dart'; // Ensure this path is correct
import 'package:bricorasy/widgets2/search_form.dart';
import 'package:bricorasy/widgets2/artisan_filter_bar.dart'; // Assuming this uses ['Tout', 'Bien Noté', 'Mal Noté']
import 'package:bricorasy/widgets/artisan_list_item.dart'; // Your custom list item widget

/// Shows a list of artisans loaded from your backend, with search + rating filters.
class Artisantscreen extends StatefulWidget {
  const Artisantscreen({super.key});

  @override
  State<Artisantscreen> createState() => _ArtisantscreenState();
}

class _ArtisantscreenState extends State<Artisantscreen> {
  List<Artisan> _artisans = []; // Original list fetched from server
  List<Artisan> _filteredArtisans = []; // List displayed after applying filters
  bool _isLoading = true;

  String _selectedRatingFilter = 'Tout'; // Current selected rating filter tab
  String _searchQuery = ''; // Current free-text search query

  // These filter names should match exactly what ArtisanFilterBar displays/returns
  // final List<String> _artisanRatingFilters = ['Tout', 'Bien Noté', 'Mal Noté']; // This is implicitly handled by ArtisanFilterBar

  @override
  void initState() {
    super.initState();
    _loadArtisansFromServer();
  }

  /// Calls your HTTP service (api_artisan) to fetch artisans,
  /// then applies initial filters.
  Future<void> _loadArtisansFromServer() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final List<Artisan> fetchedArtisans = await api_artisan.fetchArtisans();
      if (mounted) {
        setState(() {
          _artisans = fetchedArtisans;
          _applyAllFilters(); // Apply filters (search query and rating filter)
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Artisantscreen: Erreur chargement artisans: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Échec du chargement des artisans. Veuillez réessayer.',
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  /// Re‐filters the _artisans list by both the current search text (_searchQuery)
  /// and the selected rating tab (_selectedRatingFilter).
  void _applyAllFilters() {
    if (!mounted) return;
    List<Artisan> tempList = List<Artisan>.from(_artisans);

    // Apply free-text search query filter
    if (_searchQuery.isNotEmpty) {
      final String queryLower = _searchQuery.toLowerCase();
      tempList =
          tempList.where((artisan) {
            return artisan.fullname.toLowerCase().contains(queryLower) ||
                artisan.job.toLowerCase().contains(queryLower) ||
                artisan.localisation.toLowerCase().contains(queryLower);
          }).toList();
    }

    // Apply rating filter
    if (_selectedRatingFilter == 'Bien Noté') {
      tempList =
          tempList.where((artisan) {
            final double ratingValue =
                double.tryParse(artisan.rating.replaceAll(',', '.')) ?? 0.0;
            return ratingValue >= 3.0; // Your threshold for "Bien Noté"
          }).toList();
    } else if (_selectedRatingFilter == 'Mal Noté') {
      tempList =
          tempList.where((artisan) {
            final double ratingValue =
                double.tryParse(artisan.rating.replaceAll(',', '.')) ?? 0.0;
            return ratingValue <
                2.0; // Your threshold for "Mal Noté" (e.g., less than 2 stars)
          }).toList();
    }
    // 'Tout' implies no additional rating-based filtering.

    setState(() {
      _filteredArtisans = tempList;
    });
  }

  /// Called when the search text is submitted from SearchForm.
  void _handleSearchSubmitted(String query) {
    if (!mounted) return;
    setState(() {
      _searchQuery = query;
      _applyAllFilters();
    });
  }

  /// Called when the filter icon in SearchForm is tapped.
  /// You can use this to show more advanced/custom filter options in a dialog/modal.
  void _handleAdvancedFilterTap() {
    debugPrint(
      'Artisantscreen: Advanced filter icon tapped (implement if needed).',
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Filtres avancés à implémenter.")),
    );
  }

  /// Called when a user selects a rating filter tab from ArtisanFilterBar.
  void _handleRatingFilterSelected(String filter) {
    if (!mounted) return;
    setState(() {
      _selectedRatingFilter = filter;
      _applyAllFilters();
    });
  }

  /// Navigates to the selected artisan's profile detail screen.
  void _navigateToArtisanProfile(Artisan artisan) {
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => Artisanprofilscreen(
              artisan: artisan, // Pass the full Artisan object
              isMyProfile:
                  false, // When viewing from this list, it's never "my profile"
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // appBar: AppBar(title: Text("Liste des Artisans")), // Optional AppBar
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: SearchForm(
                //  hintText: 'Rechercher un artisan...', // Customized hint text
                onSearch: _handleSearchSubmitted,
                onFilterTap: _handleAdvancedFilterTap,
              ),
            ),

            // Rating filter tabs (e.g., "Tout", "Bien Noté", "Mal Noté")
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ArtisanFilterBar(
                // This widget should internally have the ['Tout', 'Bien Noté', 'Mal Noté'] filters
                selectedFilter: _selectedRatingFilter,
                onFilterSelected: _handleRatingFilterSelected,
              ),
            ),

            // Content: Loading indicator, Empty state, or List of artisans
            Expanded(
              child:
                  _isLoading
                      ? Center(
                        child: CircularProgressIndicator(
                          color: colorScheme.primary,
                        ),
                      )
                      : _filteredArtisans.isEmpty
                      ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(
                            'Aucun artisan ne correspond à vos critères de recherche.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                          16,
                          8,
                          16,
                          16,
                        ), // Adjusted top padding
                        itemCount: _filteredArtisans.length,
                        itemBuilder: (BuildContext context, int index) {
                          final Artisan artisan = _filteredArtisans[index];
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: 14.0,
                            ), // Spacing between items
                            child: ArtisanListItem(
                              // Your custom widget to display each artisan
                              artisan: artisan,
                              onTap: () => _navigateToArtisanProfile(artisan),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
