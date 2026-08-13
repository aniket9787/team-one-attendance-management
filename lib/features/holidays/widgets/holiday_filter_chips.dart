import 'package:flutter/material.dart';

class HolidayFilterChips extends StatelessWidget {
  final String selectedFilter;
  final List<String> filters;
  final ValueChanged<String> onSelected;

  const HolidayFilterChips({
    super.key,
    required this.selectedFilter,
    required this.filters,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final bool isMobile = width < 600;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final selected =
                filter == selectedFilter;

            return Padding(
              padding:
              const EdgeInsets.only(
                right: 10,
              ),
              child: ChoiceChip(
                label: Text(filter),

                selected: selected,

                selectedColor:
                Colors.blue.shade100,

                backgroundColor:
                Colors.grey.shade100,

                labelStyle: TextStyle(
                  fontSize:
                  isMobile ? 13 : 14,
                  fontWeight:
                  FontWeight.w600,
                  color: selected
                      ? Colors.blue
                      : Colors.black87,
                ),

                avatar: Icon(
                  _getIcon(filter),
                  size: 18,
                  color: selected
                      ? Colors.blue
                      : Colors.grey,
                ),

                onSelected: (_) {
                  onSelected(filter);
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  IconData _getIcon(String value) {
    switch (value) {
      case "National":
        return Icons.flag;

      case "Festival":
        return Icons.celebration;

      case "Company":
        return Icons.business;

      case "Optional":
        return Icons.star;

      default:
        return Icons.apps;
    }
  }
}