import 'package:flutter/material.dart';

class HorizontalFilterBar extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterSelected;
  const HorizontalFilterBar({ super.key, required this.selectedFilter, required this.onFilterSelected, });

  @override
  Widget build(BuildContext context) {
    final List<String> filters = ['Bricole', 'Professionnel', 'Objet'];
    // Use theme colors for better adaptability
    final Color selectedBgColor = Theme.of(context).colorScheme.primaryContainer.withOpacity(0.6);
    final Color selectedTextColor = Theme.of(context).colorScheme.onPrimaryContainer;
    final Color unselectedTextColor = Theme.of(context).colorScheme.onSurfaceVariant;

    return Container(
      height: 38, // Slightly shorter
      // Removed outer grey background, rely on item backgrounds
      child: Row(
        children: filters.map((filter) {
          final bool isSelected = selectedFilter == filter;
          return Expanded(
            child: Padding( // Add padding for spacing between items
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: InkWell(
                onTap: () => onFilterSelected(filter),
                borderRadius: BorderRadius.circular(8), // Match container radius
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? selectedBgColor : Colors.transparent, // Transparent if not selected
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      filter,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith( // Use labelLarge style
                        color: isSelected ? selectedTextColor : unselectedTextColor,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      )
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