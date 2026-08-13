import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/admin_attendance_service.dart';
import '../../domain/attendance_report_model.dart';

class AttendanceReportPage
    extends StatefulWidget {
  const AttendanceReportPage({
    super.key,
  });

  @override
  State<AttendanceReportPage>
  createState() =>
      _AttendanceReportPageState();
}

class _AttendanceReportPageState
    extends State<AttendanceReportPage> {
  String selectedFilter = 'Today';

  final TextEditingController searchController =
  TextEditingController();

  final AdminAttendanceService attendanceService =
  AdminAttendanceService();

  List<AttendanceReportModel> reports = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadReports();
  }

  Future<void> loadReports() async {
    final data =
    await attendanceService.getAttendanceReports();

    if (!mounted) return;

    setState(() {
      reports = data;
      isLoading = false;
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredReports =
    reports.where((report) {
      final query =
      searchController.text
          .toLowerCase()
          .trim();

      if (query.isEmpty) {
        return true;
      }

      return report.employeeName
          .toLowerCase()
          .contains(query) ||
          report.email
              .toLowerCase()
              .contains(query);
    }).toList();

    final totalEmployees =
        reports
            .map((e) => e.employeeId)
            .toSet()
            .length;

    final fullDays =
        reports
            .where((e) => !e.halfDay)
            .length;

    final halfDays =
        reports
            .where((e) => e.halfDay)
            .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Attendance Reports',
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding:
            const EdgeInsets.all(16),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics:
              const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.8,
              children: [
                _SummaryCard(
                  title:
                  'Employees',
                  value:
                  totalEmployees
                      .toString(),
                  icon:
                  Icons.people,
                ),
                _SummaryCard(
                  title:
                  'Full Day',
                  value:
                  fullDays
                      .toString(),
                  icon: Icons
                      .check_circle,
                ),
                _SummaryCard(
                  title:
                  'Half Day',
                  value:
                  halfDays
                      .toString(),
                  icon:
                  Icons.timelapse,
                ),
                _SummaryCard(
                  title:
                  'Records',
                  value: reports
                      .length
                      .toString(),
                  icon:
                  Icons.list_alt,
                ),
              ],
            ),
          ),

          Padding(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: TextField(
              controller:
              searchController,
              decoration:
              InputDecoration(
                hintText:
                'Search Employee',
                prefixIcon:
                const Icon(
                  Icons.search,
                ),
                border:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(
                    12,
                  ),
                ),
              ),
              onChanged: (_) {
                setState(() {});
              },
            ),
          ),

          const SizedBox(height: 12),

          Container(
            color:
            Colors.grey.shade200,
            padding:
            const EdgeInsets.all(
                12),
            child: const Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Employee',
                    style: TextStyle(
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child:
                  Text('Date'),
                ),
                Expanded(
                  child: Text(
                    'In',
                  ),
                ),
                Expanded(
                  child: Text(
                    'Out',
                  ),
                ),
                Expanded(
                  child: Text(
                    'Hours',
                  ),
                ),
                Expanded(
                  child: Text(
                    'Status',
                  ),
                ),
              ],
            ),
          ),

          if (isLoading)
            const Expanded(
              child: Center(
                child:
                CircularProgressIndicator(),
              ),
            )
          else
            Expanded(
              child:
              ListView.builder(
                itemCount:
                filteredReports
                    .length,
                itemBuilder:
                    (context,
                    index) {
                  final report =
                  filteredReports[
                  index];

                  return Container(
                    padding:
                    const EdgeInsets.all(
                        12),
                    decoration:
                    const BoxDecoration(
                      border: Border(
                        bottom:
                        BorderSide(
                          color: Colors
                              .black12,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                            children: [
                              Text(
                                report
                                    .employeeName,
                                style:
                                const TextStyle(
                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),
                              Text(
                                report
                                    .role,
                                style:
                                const TextStyle(
                                  fontSize:
                                  11,
                                  color: Colors
                                      .grey,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Expanded(
                          child: Text(
                            DateFormat(
                              'dd-MMM',
                            ).format(
                              report.date,
                            ),
                          ),
                        ),

                        Expanded(
                          child: Text(
                            report.checkIn ==
                                null
                                ? '-'
                                : DateFormat(
                              'hh:mm a',
                            ).format(
                              report
                                  .checkIn!,
                            ),
                          ),
                        ),

                        Expanded(
                          child: Text(
                            report.checkOut ==
                                null
                                ? '-'
                                : DateFormat(
                              'hh:mm a',
                            ).format(
                              report
                                  .checkOut!,
                            ),
                          ),
                        ),

                        Expanded(
                          child: Text(
                            report
                                .attendanceHoursText,
                          ),
                        ),

                        Expanded(
                          child: Text(
                            report
                                .status,
                            style:
                            TextStyle(
                              color: report
                                  .halfDay
                                  ? Colors
                                  .orange
                                  : Colors
                                  .green,
                              fontWeight:
                              FontWeight
                                  .w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}


class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.center,
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                  Text(title),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}