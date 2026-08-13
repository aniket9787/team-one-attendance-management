import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OnlineStatusWidget extends StatelessWidget {
  final String userId;

  const OnlineStatusWidget({
    super.key,
    required this.userId,
  });

  String _formatLastSeen(
      Timestamp? timestamp,
      ) {
    if (timestamp == null) {
      return '';
    }

    final date = timestamp.toDate();
    final now = DateTime.now();

    final isToday =
        date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;

    final yesterday =
    now.subtract(
      const Duration(days: 1),
    );

    final isYesterday =
        date.year == yesterday.year &&
            date.month == yesterday.month &&
            date.day == yesterday.day;

    if (isToday) {
      return DateFormat(
        'hh:mm a',
      ).format(date);
    }

    if (isYesterday) {
      return 'Yesterday';
    }

    if (date.year == now.year) {
      return DateFormat(
        'dd MMM',
      ).format(date);
    }

    return DateFormat(
      'dd MMM yyyy',
    ).format(date);
  }
  @override
  Widget build(BuildContext context) {
    if (userId.isEmpty) {
      return const SizedBox.shrink();
    }
    return StreamBuilder<
        DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('employees')
          .doc(userId)
          .snapshots(),
      builder: (
          context,
          snapshot,
          ) {
        if (!snapshot.hasData ||
            !snapshot.data!.exists) {
          return const SizedBox.shrink();
        }

        final data = snapshot.data!.data();

        if (data == null) {
          return const SizedBox.shrink();
        }

        final bool isOnline =
            data['isOnline'] ?? false;

        final Timestamp? lastSeen =
        data['lastSeen'];

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isOnline
                    ? Colors.green
                    : Colors.grey,
                shape: BoxShape.circle,
              ),
            ),

            const SizedBox(width: 5),

            Flexible(
              child: Text(
                isOnline
                    ? 'Online'
                    : _formatLastSeen(
                  lastSeen,
                ),
                overflow:
                TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight:
                  FontWeight.w500,
                  color: isOnline
                      ? Colors.green.shade700
                      : Colors.grey.shade700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}