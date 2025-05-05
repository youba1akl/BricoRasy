// lib/widgets2/horizontal_filter_bar.dart
import 'package:flutter/material.dart';

class HorizontalFilterBar extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterSelected;
  final List<String> filters;

  const HorizontalFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
    required this.filters,
  });

  @override
  Widget build(BuildContext context) {
    // --- Use the theme colors provided by the user ---
    final Color selectedBgColor = Theme.of(context).colorScheme.primaryContainer.withOpacity(0.6);
    final Color selectedTextColor = Theme.of(context).colorScheme.onPrimaryContainer;
    final Color unselectedTextColor = Theme.of(context).colorScheme.onSurfaceVariant;
    // Note: barBackgroundColor is not used as the outer container is transparent

    return Container(
      height: 40, // Adjust height if necessary
      // NO background color on the outer container
      child: Row(
        children: filters.map((filter) {
          final bool isSelected = selectedFilter == filter;
          return Expanded(
            child: Padding(
              // Padding provides spacing between the tappable areas
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: GestureDetector( // Using GestureDetector to avoid ripple
                onTap: () => onFilterSelected(filter),
                child: Container(
                  // This container provides the background *only* for the selected item
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0), // Padding inside the item
                  decoration: BoxDecoration(
                    // Apply theme-based background color only if selected
                    color: isSelected ? selectedBgColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(8), // Rounded corners
                  ),
                  child: Center(
                    child: Text(
                      filter,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        // Apply theme-based text colors
                        color: isSelected ? selectedTextColor : unselectedTextColor,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500, // Selected is bolder
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
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