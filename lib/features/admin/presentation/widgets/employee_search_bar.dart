import 'package:flutter/material.dart';

class EmployeeSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;

  const EmployeeSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,

      onChanged: onChanged,

      decoration: InputDecoration(
        hintText:
        "Search by Name, Employee ID, Email, Phone, Department or Role",

        prefixIcon: const Icon(
          Icons.search,
        ),

        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
          icon: const Icon(
            Icons.clear,
          ),
          onPressed: onClear,
        ),

        filled: true,

        fillColor: Colors.white,

        contentPadding:
        const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),

        border: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(15),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(15),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Colors.blue,
            width: 2,
          ),
        ),
      ),
    );
  }
}