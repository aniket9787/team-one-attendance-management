import 'package:flutter/material.dart';

class HolidayStatistics extends StatelessWidget {
  final int totalHolidays;
  final int upcomingHolidays;
  final int optionalHolidays;
  final int mandatoryHolidays;

  const HolidayStatistics({
    super.key,
    required this.totalHolidays,
    required this.upcomingHolidays,
    required this.optionalHolidays,
    required this.mandatoryHolidays,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final bool isMobile = width < 600;

    final cards = [

      _StatData(
        "Total",
        totalHolidays.toString(),
        Icons.calendar_month,
        Colors.blue,
      ),

      _StatData(
        "Upcoming",
        upcomingHolidays.toString(),
        Icons.upcoming,
        Colors.orange,
      ),

      _StatData(
        "Optional",
        optionalHolidays.toString(),
        Icons.star,
        Colors.deepPurple,
      ),

      _StatData(
        "Mandatory",
        mandatoryHolidays.toString(),
        Icons.check_circle,
        Colors.green,
      ),

    ];

    if (isMobile) {

      return Padding(

        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),

        child: Column(

          children: [

            for (final item in cards) ...[

              _StatisticCard(data: item),

              const SizedBox(height: 12),

            ],

          ],

        ),

      );

    }

    return Padding(

      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),

      child: Row(

        children: [

          for (int i = 0; i < cards.length; i++) ...[

            Expanded(

              child: _StatisticCard(
                data: cards[i],
              ),

            ),

            if (i != cards.length - 1)
              const SizedBox(width: 16),

          ],

        ],

      ),

    );

  }
}

class _StatData {

  final String title;

  final String value;

  final IconData icon;

  final Color color;

  const _StatData(
      this.title,
      this.value,
      this.icon,
      this.color,
      );

}

class _StatisticCard extends StatelessWidget {

  final _StatData data;

  const _StatisticCard({
    required this.data,
  });

  @override
  Widget build(BuildContext context) {

    return Container(

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
        BorderRadius.circular(18),

        border: Border.all(
          color: Colors.grey.shade200,
        ),

        boxShadow: [

          BoxShadow(

            color: data.color.withOpacity(.10),

            blurRadius: 12,

            offset: const Offset(0, 6),

          ),

        ],

      ),

      child: Column(

        children: [

          CircleAvatar(

            radius: 26,

            backgroundColor:
            data.color.withOpacity(.12),

            child: Icon(

              data.icon,

              color: data.color,

              size: 28,

            ),

          ),

          const SizedBox(height: 14),

          Text(

            data.value,

            style: const TextStyle(

              fontSize: 28,

              fontWeight: FontWeight.bold,

            ),

          ),

          const SizedBox(height: 6),

          Text(

            data.title,

            style: TextStyle(

              color: Colors.grey.shade700,

              fontWeight: FontWeight.w600,

            ),

          ),

        ],

      ),

    );

  }

}