// lib/widgets/search_form.dart
import 'package:flutter/material.dart';

class SearchForm extends StatefulWidget {
  final Function(String) onSearch;
  final VoidCallback? onFilterTap;
  final String hintText; // <-- Added: Make hintText configurable

  const SearchForm({
    super.key,
    required this.onSearch,
    this.onFilterTap,
    this.hintText = "Search...", // <-- Added: Default hint text
  });

  @override
  State<SearchForm> createState() => _SearchFormState();
}

class _SearchFormState extends State<SearchForm> {
  final TextEditingController _searchController = TextEditingController();
  @override
  void dispose() { _searchController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final Color iconColor = Theme.of(context).colorScheme.onSurfaceVariant;
    final Color hintColor = Theme.of(context).colorScheme.onSurfaceVariant;
    final Color shadowColor = Theme.of(context).shadowColor.withOpacity(0.05);
    final Color surfaceColor = Theme.of(context).colorScheme.surface; // Use surface color for background

    return Container(
      decoration: BoxDecoration( color: surfaceColor, borderRadius: BorderRadius.circular(10),
        boxShadow: [ BoxShadow( color: shadowColor, blurRadius: 8, offset: const Offset(0, 2), ), ],
      ),
      child: TextField(
          controller: _searchController,
          onSubmitted: widget.onSearch, // Use onSubmitted
          style: Theme.of(context).textTheme.bodyLarge,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: widget.hintText, // <-- Use the hintText from the widget parameter
            hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: hintColor),
            contentPadding: const EdgeInsets.symmetric( vertical: 12, ),
            prefixIcon: Padding( padding: const EdgeInsets.only(left: 16.0, right: 10.0), child: Icon( Icons.search_rounded, color: iconColor, size: 22, ), ),
            suffixIcon: widget.onFilterTap != null ? IconButton( icon: Icon(Icons.tune_outlined, color: iconColor, size: 20), onPressed: widget.onFilterTap, splashRadius: 20, ) : null,
            border: InputBorder.none, // Remove the default border
            filled: false, // Container provides background
          ),
        ),
    );
  }
}