import 'package:flutter/material.dart';

class HolidaySearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final VoidCallback? onRefresh;

  const HolidaySearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onClear,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final bool isMobile = width < 600;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      child: Row(
        children: [

          //-----------------------------------
          // Search Box
          //-----------------------------------

          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: "Search Holidays...",
                prefixIcon: const Icon(
                  Icons.search,
                ),

                suffixIcon: controller.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(
                    Icons.clear,
                  ),
                  onPressed: onClear,
                )
                    : null,

                filled: true,
                fillColor: Colors.white,

                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.grey.shade300,
                  ),
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Colors.blue,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),

          //-----------------------------------
          // Refresh Button
          //-----------------------------------

          if (!isMobile)
            const SizedBox(width: 12),

          if (!isMobile)
            SizedBox(
              height: 55,
              child: ElevatedButton.icon(
                onPressed: onRefresh,
                icon: const Icon(
                  Icons.refresh,
                ),
                label: const Text(
                  "Refresh",
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  Colors.blue,
                  foregroundColor:
                  Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}