    import 'package:flutter/material.dart';

    import '../../../../core/models/attendance_model.dart';
    import '../../../../core/services/attendance_service.dart';

    class CheckInOutPage extends StatefulWidget {
      const CheckInOutPage({super.key});

      @override
      State<CheckInOutPage> createState() =>
          _CheckInOutPageState();
    }

    class _CheckInOutPageState
        extends State<CheckInOutPage> {
      final AttendanceService _attendanceService =
      AttendanceService();

      bool isCheckedIn = false;
      bool loading = true;


      final TextEditingController _reportController =
      TextEditingController();

      static const int reportLimit = 100;




      @override
      void initState() {
        super.initState();
        loadAttendanceStatus();
      }


      @override
      void dispose() {
        _reportController.dispose();
        super.dispose();
      }

      Future<void> loadAttendanceStatus() async {
        final result =
        await _attendanceService.isCheckedIn();

        if (!mounted) return;

        setState(() {
          isCheckedIn = result;
          loading = false;
        });
      }

      Future<void> handleAttendance() async {
        try {
          setState(() {
            loading = true;
          });

          if (isCheckedIn) {
            final report = _reportController.text.trim();

            // Count words in report
            final wordCount = report
                .split(RegExp(r'\s+'))
                .where((e) => e.isNotEmpty)
                .length;

            // Maximum 100 words
            if (wordCount > reportLimit) {
              throw Exception(
                "Today's Report cannot exceed $reportLimit words.",
              );
            }

            // Report required before checkout
            if (report.isEmpty) {
              throw Exception(
                "Please enter today's report before checking out.",
              );
            }

            // Checkout
            await _attendanceService.checkOut();

            // Clear report field
            _reportController.clear();

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Checked Out Successfully",
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } else {
            // Check In
            await _attendanceService.checkIn();

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Checked In Successfully",
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            }
          }

          await loadAttendanceStatus();
        } catch (e) {
          if (mounted) {
            setState(() {
              loading = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.toString()),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }

      String formatDuration(Duration d) {
        String two(int n) => n.toString().padLeft(2, '0');

        return "${two(d.inHours)}:"
            "${two(d.inMinutes.remainder(60))}:"
            "${two(d.inSeconds.remainder(60))}";
      }

      String formatDate(DateTime date) {
        return "${date.day}/${date.month}/${date.year}";
      }

      String formatTime(DateTime date) {
        final hour =
        date.hour > 12 ? date.hour - 12 : date.hour;

        final minute =
        date.minute.toString().padLeft(2, '0');

        final period =
        date.hour >= 12 ? "PM" : "AM";

        return "$hour:$minute $period";
      }
      @override
      Widget build(BuildContext context) {
        return Scaffold(
          backgroundColor: const Color(0xFF0F172A),

          appBar: AppBar(
            elevation: 0,
            backgroundColor: const Color(0xFF111827),
            title: const Text(
              "Attendance",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            iconTheme: const IconThemeData(
              color: Colors.white,
            ),
          ),

          body: loading
              ? const Center(
            child: CircularProgressIndicator(),
          )
              : Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [

                // ==========================
                // Attendance Card
                // ==========================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF6366F1),
                        Color(0xFF8B5CF6),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(.3),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [

                      Icon(
                        isCheckedIn
                            ? Icons.access_time_filled
                            : Icons.access_time,
                        color: Colors.white,
                        size: 50,
                      ),

                      const SizedBox(height: 15),

                      Text(
                        isCheckedIn
                            ? "Currently Working"
                            : "Not Checked In",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      StreamBuilder<Duration>(
                        stream: _attendanceService.liveTimer(),
                        builder: (context, snapshot) {
                          final duration =
                              snapshot.data ?? Duration.zero;

                          return Text(
                            formatDuration(duration),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 15),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isCheckedIn
                              ? Colors.green
                              : Colors.red,
                          borderRadius:
                          BorderRadius.circular(50),
                        ),
                        child: Text(
                          isCheckedIn
                              ? "ACTIVE"
                              : "OFFLINE",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ==========================
                // Today's Report
                // ==========================
                if (isCheckedIn) ...[
                  const SizedBox(height: 20),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Today's Report",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: _reportController,
                    maxLines: 4,
                    maxLength: reportLimit,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      hintText:
                      "What did you work on today?",
                      hintStyle: const TextStyle(
                        color: Colors.white54,
                      ),
                      counterStyle: const TextStyle(
                        color: Colors.white70,
                      ),
                      filled: true,
                      fillColor: const Color(0xFF1E293B),
                      border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.white24,
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // ==========================
                // History Title
                // ==========================
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Attendance History",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: handleAttendance,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCheckedIn
                          ? Colors.redAccent
                          : Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      isCheckedIn ? "Check Out" : "Check In",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ==========================
                // History List
                // ==========================
                Expanded(
                  child: FutureBuilder<List<AttendanceModel>>(
                    future:
                    _attendanceService.attendanceHistory(),
                    builder: (context, snapshot) {

                      if (!snapshot.hasData) {
                        return const Center(
                          child:
                          CircularProgressIndicator(),
                        );
                      }

                      final history = snapshot.data!;

                      if (history.isEmpty) {
                        return const Center(
                          child: Text(
                            "No Attendance Found",
                            style: TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: history.length,
                        itemBuilder: (context, index) {

                          final item = history[index];

                          return Container(
                            margin: const EdgeInsets.only(
                              bottom: 12,
                            ),
                            decoration: BoxDecoration(
                              color:
                              const Color(0xFF1E293B),
                              borderRadius:
                              BorderRadius.circular(18),
                              border: Border.all(
                                color: Colors.white10,
                              ),
                            ),
                            child: ListTile(
                              contentPadding:
                              const EdgeInsets.all(14),

                              leading: CircleAvatar(
                                radius: 24,
                                backgroundColor:
                                Colors.blue
                                    .withOpacity(.15),
                                child: const Icon(
                                  Icons.calendar_month,
                                  color: Colors.blue,
                                ),
                              ),

                              title: Text(
                                formatDate(item.checkIn),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),

                              subtitle: Padding(
                                padding:
                                const EdgeInsets.only(
                                  top: 8,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                                  children: [

                                    Text(
                                      "Check In : ${formatTime(item.checkIn)}",
                                      style:
                                      const TextStyle(
                                        color:
                                        Colors.white70,
                                      ),
                                    ),

                                    const SizedBox(
                                      height: 4,
                                    ),

                                    Text(
                                      "Check Out : ${item.checkOut == null ? '--' : formatTime(item.checkOut!)}",
                                      style:
                                      const TextStyle(
                                        color:
                                        Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              trailing: Container(
                                padding:
                                const EdgeInsets
                                    .symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                  const Color(
                                      0xFF6366F1)
                                      .withOpacity(.15),
                                  borderRadius:
                                  BorderRadius
                                      .circular(12),
                                ),
                                child: Text(
                                  formatDuration(
                                    item.totalDuration,
                                  ),
                                  style:
                                  const TextStyle(
                                    color:
                                    Color(0xFF8B5CF6),
                                    fontWeight:
                                    FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }