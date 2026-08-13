import 'package:flutter/material.dart';

import '../../../../core/services/attendance_service.dart';

class AttendancePopupPage extends StatefulWidget {
  const AttendancePopupPage({super.key});

  @override
  State<AttendancePopupPage> createState() =>
      _AttendancePopupPageState();
}

class _AttendancePopupPageState
    extends State<AttendancePopupPage> {
  final AttendanceService _attendanceService =
  AttendanceService();


  final TextEditingController _reportController =

  TextEditingController();

  static const int reportLimit = 100;

  bool loading = true;
  bool isCheckedIn = false;

  @override
  void initState() {
    super.initState();
    loadStatus();
  }


  @override
  void dispose() {
    _reportController.dispose();
    super.dispose();
  }


  Future<void> loadStatus() async {
    try {
      final result =
      await _attendanceService.isCheckedIn();

      if (!mounted) return;

      setState(() {
        isCheckedIn = result;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });
    }
  }

  Future<void> handleAttendance() async {
    try {
      setState(() {
        loading = true;
      });

      if (isCheckedIn) {
        final report = _reportController.text.trim();

        final wordCount = report
            .split(RegExp(r'\s+'))
            .where((e) => e.isNotEmpty)
            .length;

        if (wordCount > reportLimit) {
          throw Exception(
            "Today's Report cannot exceed $reportLimit words.",
          );
        }

        await _attendanceService.checkOut(
          report: report,
        );

        _reportController.clear();
      } else {
        await _attendanceService.checkIn();
      }

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }


  String currentDate() {
    final now = DateTime.now();

    return "${now.day}/${now.month}/${now.year}";
  }

  String currentTime() {
    final now = DateTime.now();

    int hour = now.hour % 12;
    if (hour == 0) hour = 12;

    final minute =
    now.minute.toString().padLeft(2, '0');

    final period =
    now.hour >= 12 ? "PM" : "AM";

    return "$hour:$minute $period";
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        insetPadding: EdgeInsets.symmetric(
          horizontal:
          MediaQuery.of(context).size.width * 0.05,
        ),
      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(25),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
          maxWidth: 500,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
            child: loading
                ? const SizedBox(
              height: 220,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
                : SingleChildScrollView(
              child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor:
              isCheckedIn
                  ? Colors.red.shade50
                  : Colors.green
                  .shade50,
              child: Icon(
                isCheckedIn
                    ? Icons
                    .access_time_filled
                    : Icons
                    .access_time,
                color: isCheckedIn
                    ? Colors.red
                    : Colors.green,
                size: 40,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            Text(
              isCheckedIn
                  ? "CHECK OUT"
                  : "CHECK IN",
              style:
              const TextStyle(
                fontSize: 26,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            Container(
              padding:
              const EdgeInsets
                  .all(12),
              decoration:
              BoxDecoration(
                color: Colors
                    .grey.shade100,
                borderRadius:
                BorderRadius
                    .circular(
                  12,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment
                        .center,
                    children: [
                      const Icon(
                        Icons
                            .calendar_today,
                        size: 16,
                      ),
                      const SizedBox(
                        width: 6,
                      ),
                      Text(
                        currentDate(),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment
                        .center,
                    children: [
                      const Icon(
                        Icons
                            .schedule,
                        size: 16,
                      ),
                      const SizedBox(
                        width: 6,
                      ),
                      Text(
                        currentTime(),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            Text(
              isCheckedIn
                  ? "You are currently working.\nPress below to check out."
                  : "You are not checked in.\nPress below to start working.",
              textAlign:
              TextAlign.center,
              style: TextStyle(
                color: Colors
                    .grey.shade700,
                fontSize: 15,
              ),
            ),

            if (isCheckedIn) ...[
              const SizedBox(height: 20),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Today's Report (Optional)",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: _reportController,
                minLines: 3,
                maxLines: 6,
                maxLength: reportLimit,
                decoration: InputDecoration(
                  hintText: "What did you work on today?",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
              ),
            ],

            const SizedBox(
              height: 25,
            ),

            SizedBox(
              width:
              double.infinity,
              height: 52,
              child:
              ElevatedButton(
                onPressed:
                handleAttendance,
                style:
                ElevatedButton
                    .styleFrom(
                  backgroundColor:
                  isCheckedIn
                      ? Colors.red
                      : Colors
                      .green,
                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius
                        .circular(
                      14,
                    ),
                  ),
                ),
                child: Text(
                  isCheckedIn
                      ? "END WORKING SESSION"
                      : "START WORKING SESSION",
                  style:
                  const TextStyle(
                    color:
                    Colors.white,
                    fontWeight:
                    FontWeight
                        .bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
          ],
              ),
            ),
        ),
      ),
    );
  }
}