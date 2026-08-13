import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/attendance_report_model.dart';

class AdminAttendanceService {
  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  Future<List<AttendanceReportModel>>
  getAttendanceReports() async {
    final employees =
    await firestore
        .collection('employees')
        .get();

    List<AttendanceReportModel>
    reports = [];

    for (final employee
    in employees.docs) {
      final employeeData =
      employee.data();

      final employeeId =
          employee.id;

      final employeeName =
          employeeData['name'] ??
              '';

      final email =
          employeeData['email'] ??
              '';

      final role =
          employeeData['role'] ??
              '';

      final attendanceSnapshot =
      await firestore
          .collection(
        'employees',
      )
          .doc(employeeId)
          .collection(
        'attendance',
      )
          .get();

      for (final attendanceDoc
      in attendanceSnapshot
          .docs) {
        final attendanceData =
        attendanceDoc.data();

        final checkIn =
        attendanceData[
        'checkIn']
            !=
            null
            ? (attendanceData[
        'checkIn']
        as Timestamp)
            .toDate()
            : null;

        final checkOut =
        attendanceData[
        'checkOut']
            !=
            null
            ? (attendanceData[
        'checkOut']
        as Timestamp)
            .toDate()
            : null;

        Duration
        attendanceHours =
            Duration.zero;

        if (checkIn != null &&
            checkOut != null) {
          attendanceHours =
              checkOut
                  .difference(
                checkIn,
              );
        }

        reports.add(
          AttendanceReportModel(
            employeeId:
            employeeId,
            employeeName:
            employeeName,
            email: email,
            role: role,
            date:
            checkIn ??
                DateTime
                    .now(),
            checkIn:
            checkIn,
            checkOut:
            checkOut,
            loginTime: null,
            logoutTime: null,
            attendanceHours:
            attendanceHours,
            loginHours:
            Duration.zero,
            halfDay:
            attendanceHours
                .inMinutes <
                270,
          ),
        );
      }
    }

    reports.sort(
          (a, b) =>
          b.date.compareTo(
            a.date,
          ),
    );

    return reports;
  }
}