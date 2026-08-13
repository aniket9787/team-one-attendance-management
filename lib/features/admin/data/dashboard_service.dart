import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/dashboard_summary_model.dart';

class DashboardService {
  DashboardService();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<DashboardSummaryModel> getDashboardSummary() async {
    //----------------------------------------
    // Employees
    //----------------------------------------

    final employeeSnapshot =
    await _firestore
        .collection("employees")
        .get();

    final totalEmployees =
        employeeSnapshot.docs.length;

    final activeEmployees =
        employeeSnapshot.docs
            .where(
              (e) =>
          (e.data()["isActive"] ?? false) ==
              true,
        )
            .length;

    final inactiveEmployees =
        totalEmployees - activeEmployees;

    //----------------------------------------
    // Attendance
    //----------------------------------------

    final attendanceSnapshot =
    await _firestore
        .collection("attendance")
        .get();

    int presentToday = 0;
    int absentToday = 0;
    int onLeaveToday = 0;

    for (final doc in attendanceSnapshot.docs) {
      final status =
      (doc.data()["status"] ?? "")
          .toString()
          .toLowerCase();

      if (status == "present") {
        presentToday++;
      }

      if (status == "absent") {
        absentToday++;
      }

      if (status == "leave") {
        onLeaveToday++;
      }
    }

    //----------------------------------------
    // Leave Requests
    //----------------------------------------

    final leaveSnapshot =
    await _firestore
        .collection("leave_requests")
        .get();

    final pendingLeaves =
        leaveSnapshot.docs
            .where(
              (e) =>
          e["status"] == "Pending",
        )
            .length;

    final approvedLeaves =
        leaveSnapshot.docs
            .where(
              (e) =>
          e["status"] == "Approved",
        )
            .length;

    //----------------------------------------
    // Announcements
    //----------------------------------------

    final announcementSnapshot =
    await _firestore
        .collection("announcements")
        .get();

    final totalAnnouncements =
        announcementSnapshot.docs.length;

    //----------------------------------------
    // Documents
    //----------------------------------------

    final documentSnapshot =
    await _firestore
        .collection("documents")
        .get();

    final totalDocuments =
        documentSnapshot.docs.length;

    //----------------------------------------

    return DashboardSummaryModel(
      totalEmployees: totalEmployees,
      activeEmployees: activeEmployees,
      inactiveEmployees: inactiveEmployees,
      presentToday: presentToday,
      absentToday: absentToday,
      onLeaveToday: onLeaveToday,
      pendingLeaves: pendingLeaves,
      approvedLeaves: approvedLeaves,
      totalAnnouncements: totalAnnouncements,
      totalDocuments: totalDocuments,
    );
  }
}