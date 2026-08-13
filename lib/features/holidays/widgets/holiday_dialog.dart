import 'package:flutter/material.dart';

import '../../holidays/data/holiday_service.dart';
import '../../holidays/domain/holiday_model.dart';

class HolidayDialog extends StatefulWidget {
  final HolidayModel? holiday;

  const HolidayDialog({
    super.key,
    this.holiday,
  });

  @override
  State<HolidayDialog> createState() =>
      _HolidayDialogState();
}

class _HolidayDialogState
    extends State<HolidayDialog> {

  final HolidayService holidayService =
  HolidayService();

  final _formKey =
  GlobalKey<FormState>();

  late final TextEditingController
  titleController;

  late final TextEditingController
  descriptionController;

  DateTime? holidayDate;

  String holidayType = "National";

  bool isOptional = false;

  bool isLoading = false;

  final List<String> holidayTypes = [

    "National",

    "Festival",

    "Company",

    "Optional",

  ];

  @override
  void initState() {

    super.initState();

    titleController = TextEditingController(
      text: widget.holiday?.title ?? "",
    );

    descriptionController =
        TextEditingController(
          text:
          widget.holiday?.description ?? "",
        );

    holidayDate =
        widget.holiday?.holidayDate;

    holidayType =
        widget.holiday?.holidayType ??
            "National";

    isOptional =
        widget.holiday?.isOptional ??
            false;
  }

  @override
  void dispose() {

    titleController.dispose();

    descriptionController.dispose();

    super.dispose();

  }

  Future<void> pickDate() async {

    final picked =
    await showDatePicker(

      context: context,

      initialDate:
      holidayDate ??
          DateTime.now(),

      firstDate:
      DateTime(2024),

      lastDate:
      DateTime(2050),

    );

    if (picked == null) return;

    setState(() {

      holidayDate = picked;

    });

  }

  Future<void> saveHoliday() async {

    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    if (holidayDate == null) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content:
          Text("Select Holiday Date"),

        ),

      );

      return;

    }

    setState(() {

      isLoading = true;

    });

    try {

      if (widget.holiday == null) {

        await holidayService.addHoliday(

          title:
          titleController.text.trim(),

          description:
          descriptionController.text
              .trim(),

          holidayType: holidayType,

          holidayDate: holidayDate!,

          isOptional: isOptional,

        );

      } else {

        await holidayService.updateHoliday(

          id: widget.holiday!.id,

          title:
          titleController.text.trim(),

          description:
          descriptionController.text
              .trim(),

          holidayType: holidayType,

          holidayDate: holidayDate!,

          isOptional: isOptional,

        );

      }

      if (!mounted) return;

      Navigator.pop(
        context,
        true,
      );

    } catch (e) {

      setState(() {

        isLoading = false;

      });

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(

          content: Text(
            e.toString(),
          ),

        ),

      );

    }

  }

  @override
  Widget build(BuildContext context) {

    final isEdit =
        widget.holiday != null;

    return AlertDialog(

      shape:
      RoundedRectangleBorder(

        borderRadius:
        BorderRadius.circular(20),

      ),

      title: Text(

        isEdit
            ? "Edit Holiday"
            : "Add Holiday",

      ),

      content:
      SingleChildScrollView(

        child: SizedBox(

          width: 420,

          child: Form(

            key: _formKey,

            child: Column(

              mainAxisSize:
              MainAxisSize.min,

              children: [

                TextFormField(

                  controller:
                  titleController,

                  decoration:
                  const InputDecoration(

                    labelText:
                    "Holiday Name",

                    border:
                    OutlineInputBorder(),

                  ),

                  validator: (value) {

                    if (value == null ||
                        value.trim().isEmpty) {

                      return "Required";

                    }

                    return null;

                  },

                ),

                const SizedBox(
                    height: 16),

                TextFormField(

                  controller:
                  descriptionController,

                  maxLines: 3,

                  decoration:
                  const InputDecoration(

                    labelText:
                    "Description",

                    border:
                    OutlineInputBorder(),

                  ),

                  validator: (value) {

                    if (value == null ||
                        value.trim().isEmpty) {

                      return "Required";

                    }

                    return null;

                  },

                ),

                const SizedBox(
                    height: 16),

                DropdownButtonFormField<String>(

                  value: holidayType,

                  items: holidayTypes

                      .map(

                        (e) =>
                        DropdownMenuItem(

                          value: e,

                          child: Text(e),

                        ),

                  )

                      .toList(),

                  onChanged: (value) {

                    if (value == null)
                      return;

                    setState(() {

                      holidayType = value;

                    });

                  },

                ),

                const SizedBox(
                    height: 16),

                ListTile(

                  shape:
                  RoundedRectangleBorder(

                    borderRadius:
                    BorderRadius
                        .circular(10),

                  ),

                  tileColor:
                  Colors.grey.shade100,

                  title: Text(

                    holidayDate == null

                        ? "Select Date"

                        : "${holidayDate!.day}/${holidayDate!.month}/${holidayDate!.year}",

                  ),

                  trailing: const Icon(
                    Icons.calendar_today,
                  ),

                  onTap: pickDate,

                ),

                const SizedBox(
                    height: 10),

                SwitchListTile(

                  value: isOptional,

                  title: const Text(
                    "Optional Holiday",
                  ),

                  onChanged: (value) {

                    setState(() {

                      isOptional = value;

                    });

                  },

                ),

              ],

            ),

          ),

        ),

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

        ElevatedButton(

          onPressed:
          isLoading ? null : saveHoliday,

          child: isLoading

              ? const SizedBox(

            width: 18,

            height: 18,

            child:
            CircularProgressIndicator(
              strokeWidth: 2,
            ),

          )

              : Text(

            isEdit
                ? "Update"
                : "Save",

          ),

        ),

      ],

    );

  }

}