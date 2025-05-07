import 'package:flutter/material.dart';

class ArtisanFilterBar extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterSelected;

  // Define the specific filters for the Artisan screen
  final List<String> _artisanScreenFilters = const ['Tout', 'Bien Noté', 'Mal Noté'];

  const ArtisanFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Use theme colors for better adaptability, similar to HorizontalFilterBar
    final Color selectedBgColor = Theme.of(
      context,
    ).colorScheme.primaryContainer.withOpacity(0.6); // Example: Light purple/lilac
    final Color selectedTextColor =
        Theme.of(context).colorScheme.onPrimaryContainer; // Example: Darker purple/blue
    final Color unselectedTextColor =
        Theme.of(context).colorScheme.onSurfaceVariant;

    return Container(
      height: 38, // Consistent height
      child: Row(
        children: _artisanScreenFilters.map((filter) {
          final bool isSelected = selectedFilter == filter;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: InkWell(
                onTap: () => onFilterSelected(filter),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? selectedBgColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      filter,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: isSelected ? selectedTextColor : unselectedTextColor,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}