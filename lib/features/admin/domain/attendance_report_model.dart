class AttendanceReportModel {
  final String employeeId;
  final String employeeName;
  final String email;
  final String role;

  final DateTime date;

  final DateTime? checkIn;
  final DateTime? checkOut;

  final DateTime? loginTime;
  final DateTime? logoutTime;

  final Duration attendanceHours;
  final Duration loginHours;

  final bool halfDay;

  const AttendanceReportModel({
    required this.employeeId,
    required this.employeeName,
    required this.email,
    required this.role,
    required this.date,
    this.checkIn,
    this.checkOut,
    this.loginTime,
    this.logoutTime,
    required this.attendanceHours,
    required this.loginHours,
    required this.halfDay,
  });

  String get status {
    return halfDay
        ? 'Half Day'
        : 'Full Day';
  }

  String formatDuration(
      Duration duration,
      ) {
    final hours =
        duration.inHours;

    final minutes =
        duration.inMinutes % 60;

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}';
  }

  String get attendanceHoursText =>
      formatDuration(
        attendanceHours,
      );

  String get loginHoursText =>
      formatDuration(
        loginHours,
      );
}