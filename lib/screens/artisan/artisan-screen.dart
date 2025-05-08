// lib/screens/artisan/artisan-screen.dart

import 'package:flutter/material.dart';
import 'package:bricorasy/models/artisan.model.dart';
import 'package:bricorasy/services/artisan_services.dart';
import 'package:bricorasy/screens/artisan/artisan-profil-screen.dart';
import 'package:bricorasy/widgets2/search_form.dart';
import 'package:bricorasy/widgets2/artisan_filter_bar.dart';
import 'package:bricorasy/widgets/artisan_list_item.dart';

/// Shows a list of artisans loaded from your backend, with search + rating filters.
class Artisantscreen extends StatefulWidget {
  const Artisantscreen({super.key});

  @override
  State<Artisantscreen> createState() => _ArtisantscreenState();
}

class _ArtisantscreenState extends State<Artisantscreen> {
  List<Artisan> _artisans = [];
  List<Artisan> _filteredArtisans = [];
  bool _isLoading = true;

  // Active rating filter tab
  String _selectedFilter = 'Tout';
  // Active free-text search query
  String _searchQuery = '';

  // Matches what ArtisanFilterBar shows
  final List<String> _artisanFilters = ['Tout', 'Bien Noté', 'Mal Noté'];

  @override
  void initState() {
    super.initState();
    _loadArtisansFromServer();
  }

  /// Calls your HTTP service to fetch artisans, then applies initial filters.
  Future<void> _loadArtisansFromServer() async {
    setState(() => _isLoading = true);
    try {
      final list = await api_artisan.fetchArtisans();
      setState(() {
        _artisans = list;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Erreur chargement artisans: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Échec du chargement des artisans'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Re‐filters the _artisans list by both search text and rating tab.
  void _applyFilters() {
    var list = List<Artisan>.from(_artisans);

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list =
          list.where((a) {
            return a.fullname.toLowerCase().contains(q) ||
                a.job.toLowerCase().contains(q) ||
                a.localisation.toLowerCase().contains(q);
          }).toList();
    }

    if (_selectedFilter == 'Bien Noté') {
      list =
          list.where((a) {
            final r = double.tryParse(a.rating.replaceAll(',', '.')) ?? 0.0;
            return r >= 3.0;
          }).toList();
    } else if (_selectedFilter == 'Mal Noté') {
      list =
          list.where((a) {
            final r = double.tryParse(a.rating.replaceAll(',', '.')) ?? 0.0;
            return r < 2.0;
          }).toList();
    }

    setState(() => _filteredArtisans = list);
  }

  /// Updates the search query and re‐applies filters.
  void _handleSearch(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  /// Handles tapping the filter icon (you could show advanced options here).
  void _handleFilterTap() {
    debugPrint('Filter icon tapped');
  }

  /// Called when user selects a rating tab.
  void _handleFilterSelection(String filter) {
    setState(() => _selectedFilter = filter);
    _applyFilters();
  }

  /// Nav to artisan profile details.
  void _navigateToProfile(Artisan artisan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => Artisanprofilscreen(
              username: artisan.fullname,
              job: artisan.job,
              like: artisan.like,
              loc: artisan.localisation,
              rating: artisan.rating,
              imgProvider: AssetImage(artisan.image),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // If you're embedding this inside another Scaffold, you can switch to Container.
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: SearchForm(
                onSearch: _handleSearch,
                onFilterTap: _handleFilterTap,
              ),
            ),

            // Rating filter tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ArtisanFilterBar(
                selectedFilter: _selectedFilter,
                onFilterSelected: _handleFilterSelection,
              ),
            ),

            // Content (loading / empty / list)
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _filteredArtisans.isEmpty
                      ? const Center(child: Text('Aucun artisan trouvé.'))
                      : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredArtisans.length,
                        itemBuilder: (ctx, i) {
                          final artisan = _filteredArtisans[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
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
