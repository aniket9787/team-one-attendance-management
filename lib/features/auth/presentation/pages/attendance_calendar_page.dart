  import 'package:flutter/material.dart';
  import 'package:table_calendar/table_calendar.dart';

  import '../../../../core/models/attendance_model.dart';
  import '../../../../core/models/session_model.dart';
  import '../../../../core/services/attendance_service.dart';
  import '../../../../core/services/session_service.dart';

  class AttendanceCalendarPage extends StatefulWidget {
    const AttendanceCalendarPage({super.key});

    @override
    State<AttendanceCalendarPage> createState() =>
        _AttendanceCalendarPageState();
  }

  class _AttendanceCalendarPageState
      extends State<AttendanceCalendarPage> {
    final AttendanceService attendanceService =
    AttendanceService();

    final SessionService sessionService =
    SessionService();

    bool loading = true;

    DateTime focusedDay = DateTime.now();
    DateTime selectedDay = DateTime.now();

    List<AttendanceModel> attendanceList = [];
    List<SessionModel> sessionList = [];

    @override
    void initState() {
      super.initState();
      loadData();
    }

    Future<void> loadData() async {
      try {
        attendanceList =
        await attendanceService.attendanceHistory();

        sessionList =
        await sessionService.sessionHistory();

        if (!mounted) return;

        setState(() {
          loading = false;
        });
      } catch (e) {
        if (!mounted) return;

        setState(() {
          loading = false;
        });
      }
    }

    bool isAttendanceDay(DateTime day) {
      return attendanceList.any(
            (item) =>
        item.checkIn.year == day.year &&
            item.checkIn.month == day.month &&
            item.checkIn.day == day.day,
      );
    }

    bool isLoginDay(DateTime day) {
      return sessionList.any(
            (item) =>
        item.loginTime.year == day.year &&
            item.loginTime.month == day.month &&
            item.loginTime.day == day.day,
      );
    }

    String formatTime(DateTime date) {
      int hour = date.hour % 12;

      if (hour == 0) {
        hour = 12;
      }

      final minute =
      date.minute.toString().padLeft(2, '0');

      final period =
      date.hour >= 12 ? 'PM' : 'AM';

      return '$hour:$minute $period';
    }

    bool isHalfDay(Duration attendanceDuration) {
      return attendanceDuration.inMinutes < 270;
    }

    String formatDuration(Duration d) {
      String two(int n) =>
          n.toString().padLeft(2, '0');

      return '${two(d.inHours)}:'
          '${two(d.inMinutes.remainder(60))}:'
          '${two(d.inSeconds.remainder(60))}';
    }

    Widget _summaryBox({
      required String title,
      required String value,
      required Color color,
      required IconData icon,
    }) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [

            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(.12),
                borderRadius:
                BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [

                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    @override
    Widget build(BuildContext context) {
      final selectedAttendance =
      attendanceList.where(
            (item) =>
        item.checkIn.day == selectedDay.day &&
            item.checkIn.month ==
                selectedDay.month &&
            item.checkIn.year ==
                selectedDay.year,
      );

      final selectedSessions =
      sessionList.where(
            (item) =>
        item.loginTime.day ==
            selectedDay.day &&
            item.loginTime.month ==
                selectedDay.month &&
            item.loginTime.year ==
                selectedDay.year,
      );


      final attendanceDuration = selectedAttendance.fold(
        Duration.zero,
            (previous, item) => previous + item.totalDuration,
      );

      final loginDuration = selectedSessions.fold(

        Duration.zero,
            (previous, item) => previous + item.sessionDuration,
      );

      final bool halfDay =
      isHalfDay(attendanceDuration);

      return Scaffold(
        backgroundColor:
        const Color(0xFFF5F7FB),

        appBar: AppBar(
          backgroundColor:
          const Color(0xFF2563EB),
          title: const Text(
            'Attendance Calendar',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
        ),

        body: loading
            ? const Center(
          child:
          CircularProgressIndicator(),
        )
            : SingleChildScrollView(
          child: Column(
          children: [
            Container(
              margin:
              const EdgeInsets.all(
                16,
              ),
              padding:
              const EdgeInsets.all(
                10,
              ),
              decoration:
              BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.circular(
                  20,
                ),
              ),
              child: TableCalendar(
                firstDay:
                DateTime(2020),
                lastDay:
                DateTime(2050),
                focusedDay:
                focusedDay,

                selectedDayPredicate:
                    (day) =>
                    isSameDay(
                      selectedDay,
                      day,
                    ),

                onDaySelected:
                    (
                    selected,
                    focused,
                    ) {
                  setState(() {
                    selectedDay =
                        selected;
                    focusedDay =
                        focused;
                  });
                },

                calendarBuilders:
                CalendarBuilders(
                  markerBuilder:
                      (
                      context,
                      date,
                      events,
                      ) {
                    List<Widget>
                    markers = [];
                    final attendance =
                    attendanceList.where(
                          (a) =>
                      a.checkIn.year == date.year &&
                          a.checkIn.month == date.month &&
                          a.checkIn.day == date.day,
                    );

                    final totalDuration =
                    attendance.fold(
                      Duration.zero,
                          (prev, item) =>
                      prev + item.totalDuration,
                    );

                    final isHalf =
                        totalDuration.inMinutes < 270;

                    if (attendance.isNotEmpty) {
                      markers.add(
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 1,
                          ),
                          decoration: BoxDecoration(
                            color: isHalf
                                ? Colors.orange
                                : Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }
                    if (isLoginDay(
                        date)) {
                      markers.add(
                        Container(
                          width: 8,
                          height: 8,
                          margin:
                          const EdgeInsets
                              .symmetric(
                            horizontal:
                            1,
                          ),
                          decoration:
                          const BoxDecoration(
                            color:
                            Colors.blue,
                            shape:
                            BoxShape.circle,
                          ),
                        ),
                      );
                    }

                    if (markers
                        .isEmpty) {
                      return null;
                    }

                    return Positioned(
                      bottom: 4,
                      child: Row(
                        mainAxisSize:
                        MainAxisSize
                            .min,
                        children:
                        markers,
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {

                  final isMobile =
                      constraints.maxWidth < 600;

                  return isMobile
                      ? Column(
                    children: [

                      _summaryBox(
                        title: "Attendance Hours",
                        value: formatDuration(
                          attendanceDuration,
                        ),
                        color: Colors.green,
                        icon: Icons.access_time,
                      ),

                      const SizedBox(height: 12),

                      _summaryBox(
                        title: "Login Session Hours",
                        value: formatDuration(
                          loginDuration,
                        ),
                        color: Colors.blue,
                        icon: Icons.login,
                      ),

                      const SizedBox(height: 12),

                      _summaryBox(
                        title: "Half Day",
                        value: halfDay ? "YES" : "NO",
                        color: halfDay
                            ? Colors.red
                            : Colors.green,
                        icon: halfDay
                            ? Icons.warning
                            : Icons.check_circle,
                      ),
                    ],
                  )    : Row(
                    children: [

                      Expanded(
                        child: _summaryBox(
                          title: "Attendance Hours",
                          value: formatDuration(
                            attendanceDuration,
                          ),
                          color: Colors.green,
                          icon: Icons.access_time,
                        ),
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child: _summaryBox(
                          title: "Login Session Hours",
                          value: formatDuration(
                            loginDuration,
                          ),
                          color: Colors.blue,
                          icon: Icons.login,
                        ),
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child: _summaryBox(
                          title: "Half Day",
                          value: halfDay ? "YES" : "NO",
                          color: halfDay
                              ? Colors.red
                              : Colors.green,
                          icon: halfDay
                              ? Icons.warning
                              : Icons.check_circle,
                        ),
                      ),

                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

        ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
                  const Text(
                    "Selected Day Activity",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  ...selectedAttendance
                      .map(
                        (item) => Card(
                      child: ListTile(
                        leading:
                        const Icon(
                          Icons
                              .access_time,
                          color:
                          Colors.green,
                        ),
                        title: Text(
                          item
                              .attendanceStatus,
                        ),
                        subtitle:
                        Text(
                          "IN : ${formatTime(item.checkIn)}\n"
                              "OUT : ${item.checkOut == null ? '--' : formatTime(item.checkOut!)}",
                        ),
                        isThreeLine:
                        true,
                        trailing: Column(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [

                            Text(
                              formatDuration(
                                item.totalDuration,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              item.totalDuration.inMinutes < 270
                                  ? "Half Day"
                                  : "Full Day",
                              style: TextStyle(
                                color:
                                item.totalDuration.inMinutes < 270
                                    ? Colors.red
                                    : Colors.green,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  ...selectedSessions
                      .map(
                        (session) => Card(
                      child: ListTile(
                        leading:
                        const Icon(
                          Icons.login,
                          color:
                          Colors.blue,
                        ),
                        title:
                        const Text(
                          "Login Session",
                        ),
                        subtitle:
                        Text(
                          "LOGIN : ${formatTime(session.loginTime)}\n"
                              "LOGOUT : ${session.logoutTime == null ? '--' : formatTime(session.logoutTime!)}",
                        ),
                        isThreeLine:
                        true,
                        trailing:
                        Text(
                          formatDuration(
                            session
                                .sessionDuration,
                          ),
                        ),
                      ),
                    ),
                  ),

                  if (selectedAttendance
                      .isEmpty &&
                      selectedSessions
                          .isEmpty)
                    const Card(
                      child: Padding(
                        padding:
                        EdgeInsets.all(
                          20,
                        ),
                        child: Center(

                          child: Text(
                            "No Activity Found",
                          ),
                        ),
                      ),
                    ),
                ],
              ),

          ],
          ),
        ),
      );
    }
  }