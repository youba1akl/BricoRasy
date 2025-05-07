// lib/widgets2/search_form.dart

import 'package:flutter/material.dart';

class SearchForm extends StatefulWidget {
  final Function(String) onSearch;
  final VoidCallback? onFilterTap;

  const SearchForm({
    super.key,
    required this.onSearch,
    this.onFilterTap,
  });

  @override
  State<SearchForm> createState() => _SearchFormState();
}

class _SearchFormState extends State<SearchForm> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color iconColor = Theme.of(context).colorScheme.onSurfaceVariant;
    final Color hintColor = Theme.of(context).colorScheme.onSurfaceVariant;
    final Color shadowColor = Theme.of(context).shadowColor.withOpacity(0.05);
    final Color surfaceColor = Theme.of(context).colorScheme.surface;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onSubmitted: widget.onSearch,
        textInputAction: TextInputAction.search,
        style: Theme.of(context).textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: "Search services or objects...",
          hintStyle: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: hintColor),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 10.0),
            child: Icon(Icons.search_rounded, color: iconColor, size: 22),
          ),
          suffixIcon: widget.onFilterTap != null
              ? IconButton(
                  icon: Icon(Icons.tune_outlined,
                      color: iconColor, size: 20),
                  onPressed: widget.onFilterTap,
                  splashRadius: 20,
                )
              : null,
          border: InputBorder.none,
          filled: false,
        ),
      ),
    );
  }
}
