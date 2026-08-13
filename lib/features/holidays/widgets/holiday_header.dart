import 'package:flutter/material.dart';

class HolidayHeader extends StatelessWidget {
  final VoidCallback onAddHoliday;

  const HolidayHeader({
    super.key,
    required this.onAddHoliday,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final bool isMobile = width < 600;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: EdgeInsets.all(
        isMobile ? 18 : 24,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xff2563EB),
            Color(0xff1D4ED8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(.20),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: isMobile
          ? Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Text(
            "Holiday Management",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Manage company holidays from one place.",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onAddHoliday,
              icon: const Icon(Icons.add),
              label: const Text("Add Holiday"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor:
                const Color(0xff2563EB),
                padding:
                const EdgeInsets.symmetric(
                  vertical: 14,
                ),
              ),
            ),
          ),
        ],
      )
          : Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: const [
                Text(
                  "Holiday Management",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Manage company holidays from one place.",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: onAddHoliday,
            icon: const Icon(Icons.add),
            label: const Text("Add Holiday"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor:
              const Color(0xff2563EB),
              padding:
              const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}