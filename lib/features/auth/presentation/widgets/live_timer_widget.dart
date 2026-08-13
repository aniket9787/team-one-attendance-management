import 'package:flutter/material.dart';

class LiveTimerWidget extends StatelessWidget {
  final Duration duration;

  const LiveTimerWidget({
    super.key,
    required this.duration,
  });

  String format(Duration d) {
    final hours = d.inHours
        .toString()
        .padLeft(2, '0');

    final minutes = (d.inMinutes % 60)
        .toString()
        .padLeft(2, '0');

    final seconds = (d.inSeconds % 60)
        .toString()
        .padLeft(2, '0');

    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.timer,
            color: Color(0xFF2563EB),
          ),
          const SizedBox(width: 8),
          Text(
            format(duration),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}