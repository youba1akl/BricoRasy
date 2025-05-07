// lib/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:bricorasy/models/bricole_service.dart';
import 'package:bricorasy/models/professional_service.dart';
import 'package:bricorasy/models/dummy_tool.dart';

import 'package:bricorasy/widgets2/search_form.dart';
import 'package:bricorasy/widgets2/horizontal_filter_bar.dart';
import 'package:bricorasy/widgets2/home/service_list_view.dart';
import 'package:bricorasy/widgets2/home/tool_grid_view.dart';
import 'package:bricorasy/widgets2/home/proService_listView.dart';

import 'package:bricorasy/services/HomePage_service.dart';

const kAppBackgroundColor = Color(0xFFFFF0E8);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedFilter = 'Bricole';

  bool _loadingBricole = true;
  List<BricoleService> _allBricole = [];
  List<BricoleService> _filteredBricole = [];

  bool _loadingPro = true;
  List<ProfessionalService> _allPro = [];
  List<ProfessionalService> _filteredPro = [];

  bool _loadingTools = true;
  List<DummyTool> _allTools = [];
  List<DummyTool> _filteredTools = [];

  bool _showFilterOptions = false;
  String _activeSearchFilter = 'title';
  final List<String> _filterOptions = ['title', 'localisation', 'prix'];

  @override
  void initState() {
    super.initState();

    apiservice
        .fetchServices()
        .then((list) {
          setState(() {
            _allBricole = list;
            _filteredBricole = List.from(list);
            _loadingBricole = false;
          });
        })
        .catchError((_) => setState(() => _loadingBricole = false));

    apiService_pro
        .fetchServicePro()
        .then((list) {
          setState(() {
            _allPro = list;
            _filteredPro = List.from(list);
            _loadingPro = false;
          });
        })
        .catchError((_) => setState(() => _loadingPro = false));

    apiService_outil
        .fetchTools()
        .then((list) {
          setState(() {
            _allTools = list;
            _filteredTools = List.from(list);
            _loadingTools = false;
          });
        })
        .catchError((_) => setState(() => _loadingTools = false));
  }

  void _selectFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  void _toggleFilterOptions() {
    setState(() {
      _showFilterOptions = !_showFilterOptions;
    });
  }

  void _onSearchSubmitted(String query) {
    final q = query.trim().toLowerCase();

    if (_selectedFilter == 'Bricole') {
      setState(() {
        _filteredBricole =
            _allBricole.where((s) {
              final value = _getBricoleField(s, _activeSearchFilter);
              return value.toLowerCase().contains(q);
            }).toList();
      });
    } else if (_selectedFilter == 'Professionnel') {
      setState(() {
        _filteredPro =
            _allPro.where((p) {
              final value = _getProField(p, _activeSearchFilter);
              return value.toLowerCase().contains(q);
            }).toList();
      });
    } else if (_selectedFilter == 'Objet') {
      setState(() {
        _filteredTools =
            _allTools.where((t) {
              final value = _getToolField(t, _activeSearchFilter);
              return value.toLowerCase().contains(q);
            }).toList();
      });
    }
  }

  String _getBricoleField(BricoleService svc, String field) {
    switch (field) {
      case 'location':
        return svc.localisation;
      case 'prix':
        return svc.prix.toString();
      case 'title':
      default:
        return svc.name;
    }
  }

  String _getProField(ProfessionalService svc, String field) {
    switch (field) {
      case 'location':
        return svc.localisation;
      case 'prix':
        return svc.prix.toString();
      case 'title':
      default:
        return svc.name;
    }
  }

  String _getToolField(DummyTool tool, String field) {
    switch (field) {
      case 'location':
        return tool.localisation;
      case 'prix':
        return tool.price.toString();
      case 'title':
      default:
        return tool.name;
    }
  }

  Widget _buildSearchFilters() {
    final Map<String, Color> chipColors = {
      'title': Colors.blue,
      'localisation': Colors.green,
      'prix': Colors.orange,
    };

    return _showFilterOptions
        ? Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Wrap(
            spacing: 10,
            children:
                _filterOptions.map((filter) {
                  return ChoiceChip(
                    label: Text(filter),
                    selected: _activeSearchFilter == filter,
                    selectedColor: chipColors[filter]!.withOpacity(0.2),
                    backgroundColor: Colors.grey.shade200,
                    labelStyle: TextStyle(
                      color:
                          _activeSearchFilter == filter
                              ? chipColors[filter]
                              : Colors.black,
                    ),
                    onSelected: (_) {
                      setState(() {
                        _activeSearchFilter = filter;
                      });
                    },
                  );
                }).toList(),
          ),
        )
        : const SizedBox.shrink();
  }

  void _onServiceTapped(BricoleService svc) {}
  void _onProServiceTapped(ProfessionalService svc) {}
  void _onToolTapped(DummyTool tool) {}

  Widget _buildCurrentContent() {
    switch (_selectedFilter) {
      case 'Objet':
        if (_loadingTools)
          return const Center(child: CircularProgressIndicator());
        if (_filteredTools.isEmpty)
          return const Center(child: Text('Aucun outil trouvé'));
        return ToolGridView(tools: _filteredTools, onToolTapped: _onToolTapped);

      case 'Professionnel':
        if (_loadingPro)
          return const Center(child: CircularProgressIndicator());
        if (_filteredPro.isEmpty)
          return const Center(child: Text('Aucune annonce trouvée'));
        return ProserviceListView(
          services: _filteredPro,
          onServiceTapped: _onProServiceTapped,
        );

      case 'Bricole':
      default:
        if (_loadingBricole)
          return const Center(child: CircularProgressIndicator());
        if (_filteredBricole.isEmpty)
          return const Center(child: Text('Aucune annonce trouvée'));
        return ServiceListView(
          services: _filteredBricole,
          onServiceTapped: _onServiceTapped,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor ?? kAppBackgroundColor;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SearchForm(
                onSearch: _onSearchSubmitted,
                onFilterTap: _toggleFilterOptions,
              ),
            ),
            _buildSearchFilters(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: HorizontalFilterBar(
                selectedFilter: _selectedFilter,
                onFilterSelected: _selectFilter,
              ),
            ),
            Expanded(child: _buildCurrentContent()),
          ],
        ),
      ),
    );
  }
}
