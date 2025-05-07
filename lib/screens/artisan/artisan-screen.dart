// lib/screens/artisan/artisan-screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:bricorasy/models/artisan.model.dart';
import 'package:bricorasy/screens/artisan/artisan-profil-screen.dart';
import 'package:bricorasy/widgets2/search_form.dart';
import 'package:bricorasy/widgets2/horizontal_filter_bar.dart';
import 'package:bricorasy/widgets/artisan_list_item.dart';

/// Screen that displays a list of artisans with filtering and search features.
class Artisantscreen extends StatefulWidget {
  const Artisantscreen({super.key});

  @override
  State<Artisantscreen> createState() => _ArtisantscreenState();
}

class _ArtisantscreenState extends State<Artisantscreen> {
  // All loaded artisans from JSON
  List<Artisan> _artisans = [];

  // Artisans after applying search and filter
  List<Artisan> _filteredArtisans = [];

  // Control loading spinner
  bool _isLoading = true;

  // Current selected filter (tab)
  String _selectedFilter = 'Tout';

  // Current search query
  String _searchQuery = '';

  // Available filter options (used as tabs)
  final List<String> _artisanFilters = ['Tout', 'Bien Noté', 'Mal Noté'];

  @override
  void initState() {
    super.initState();
    _loadArtisans();
  }

  /// Loads artisan data from a local JSON file and applies initial filters.
  Future<void> _loadArtisans() async {
    setState(() => _isLoading = true);
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/json/artisan.json',
      );
      final List<dynamic> jsonData = json.decode(jsonString);

      setState(() {
        _artisans = jsonData.map((e) => Artisan.fromJson(e)).toList();
        _applyFilters(); // Apply filter to initialize the displayed list
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Erreur de chargement des artisans: $e");
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

  /// Applies both the current search and rating filters to the artisan list.
  void _applyFilters() {
    List<Artisan> filtered = List.from(_artisans);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered =
          filtered.where((artisan) {
            return artisan.fullname.toLowerCase().contains(query) ||
                artisan.job.toLowerCase().contains(query) ||
                artisan.adress.toLowerCase().contains(query);
          }).toList();
    }

    // Apply rating-based filter
    if (_selectedFilter == 'Bien Noté') {
      filtered =
          filtered.where((a) {
            final rating =
                double.tryParse(a.rating.replaceAll(',', '.')) ?? 0.0;
            return rating >= 4.0;
          }).toList();
    } else if (_selectedFilter == 'Mal Noté') {
      filtered =
          filtered.where((a) {
            final rating =
                double.tryParse(a.rating.replaceAll(',', '.')) ?? 0.0;
            return rating < 3.0;
          }).toList();
    }

    setState(() {
      _filteredArtisans = filtered;
    });
  }

  /// Updates the search query and re-applies filters.
  void _handleSearch(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  /// Toggles advanced filter options (not implemented yet).
  void _handleFilterTap() {
    debugPrint("Advanced filter options tapped.");
  }

  /// Updates the selected filter tab and refreshes the filtered list.
  void _selectTab(String tab) {
    setState(() {
      _selectedFilter = tab;
    });
    _applyFilters(); // _applyFilters will run, but its conditions for 'Bien Noté'/'Mal Noté' might not match
  }

  /// Navigates to the detailed profile of the selected artisan.
  void _navigateToProfile(Artisan artisan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => Artisanprofilscreen(
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

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // --- Search Bar with filter icon ---
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: SearchForm(
                onSearch: _handleSearch,
                onFilterTap: _handleFilterTap,
              ),
            ),

            // --- Horizontal tab filter bar ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: HorizontalFilterBar(
                selectedFilter: _selectedFilter,
                onFilterSelected: _selectTab,
              ),
            ),

            // --- Artisan list content or loading indicator ---
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _filteredArtisans.isEmpty
                      ? const Center(child: Text("Aucun artisan trouvé."))
                      : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _filteredArtisans.length,
                        itemBuilder: (context, index) {
                          final artisan = _filteredArtisans[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
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
      ),
    );
  }
}