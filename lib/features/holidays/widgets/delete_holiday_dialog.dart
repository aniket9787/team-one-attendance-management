import 'package:flutter/material.dart';

class DeleteHolidayDialog extends StatelessWidget {
  final String holidayName;
  final Future<void> Function() onDelete;

  const DeleteHolidayDialog({
    super.key,
    required this.holidayName,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),

      title: const Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.red,
          ),
          SizedBox(width: 10),
          Text("Delete Holiday"),
        ],
      ),

      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Are you sure you want to delete",
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 10),

          Text(
            holidayName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            "This action cannot be undone.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.red,
            ),
          ),
        ],
      ),

      actions: [

        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            "Cancel",
          ),
        ),

        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          icon: const Icon(Icons.delete),
          label: const Text("Delete"),
          onPressed: () async {

            await onDelete();

            if (context.mounted) {
              Navigator.pop(context);
            }
          },
        ),
      ],
    );
  }
}