import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/attendance_model.dart';


import 'google_sheet_service.dart';


class AttendanceService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  // ==========================
  // COLLECTION REFERENCE
  // ==========================

  CollectionReference<Map<String, dynamic>>
  get _attendanceCollection {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception(
        'User not logged in',
      );
    }

    return _firestore
        .collection('employees')
        .doc(user.uid)
        .collection('attendance');
  }


  // ==========================
  // CHECK IN
  // ==========================

  Future<void> checkIn() async {
    final checkedIn =
    await isCheckedIn();

    if (checkedIn) {
      return;
    }

    await _attendanceCollection.add({
      'checkIn': Timestamp.now(),
      'checkOut': null,
      'status': 'checked_in',
      'createdAt': Timestamp.now(),
      'workedSeconds': 0,
    });
  }

  // ==========================
  // CHECK OUT
  // ==========================

  // ==========================
// CHECK OUT
// ==========================

  Future<void> checkOut({
    String? report,
  }) async {
    final snapshot =
    await _attendanceCollection
        .where(
      'status',
      isEqualTo: 'checked_in',
    )
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return;
    }

    final doc = snapshot.docs.first;

    final checkInTime =
    (doc['checkIn'] as Timestamp).toDate();

    final currentWorkedSeconds =
    (doc.data()['workedSeconds'] ?? 0) as int;

    final sessionSeconds =
        DateTime.now()
            .difference(checkInTime)
            .inSeconds;


    final attendanceDuration =
    Duration(seconds: sessionSeconds);

    final formattedAttendanceDuration =
        '${attendanceDuration.inHours.toString().padLeft(2, '0')}:'
        '${(attendanceDuration.inMinutes % 60).toString().padLeft(2, '0')}:'
        '${(attendanceDuration.inSeconds % 60).toString().padLeft(2, '0')}';


// =====================================
// TOTAL ATTENDANCE FOR TODAY
// =====================================

    final totalWorkedSeconds =
        currentWorkedSeconds + sessionSeconds;

    final totalAttendanceDuration =
    Duration(seconds: totalWorkedSeconds);

    final formattedTotalAttendance =
        '${totalAttendanceDuration.inHours.toString().padLeft(2, '0')}:'
        '${(totalAttendanceDuration.inMinutes % 60).toString().padLeft(2, '0')}:'
        '${(totalAttendanceDuration.inSeconds % 60).toString().padLeft(2, '0')}';

    await doc.reference.update({
      'checkOut': Timestamp.now(),
      'status': 'checked_out',
      'report': report ?? '',
      'workedSeconds':
      currentWorkedSeconds + sessionSeconds,
    });



    final user = _auth.currentUser;

    if (user != null) {

      print('Sending Attendance To Google Sheet...');



      final sessionCollection = _firestore
          .collection('employees')
          .doc(user.uid)
          .collection('sessions');

      final sessionSnapshot = await sessionCollection
          .orderBy('loginTime', descending: true)
          .limit(1)
          .get();

      String loginTime = '';
      String logoutTime = '';
      String loginDuration = '';

      if (sessionSnapshot.docs.isNotEmpty) {
        final sessionData =
        sessionSnapshot.docs.first.data();

        final login =
        (sessionData['loginTime'] as Timestamp)
            .toDate();

        final logout = DateTime.now();

        final duration =
        logout.difference(login);

        loginTime = login.toString();

        logoutTime = logout.toString();

        loginDuration =
        '${duration.inHours.toString().padLeft(2, '0')}:'
            '${(duration.inMinutes % 60).toString().padLeft(2, '0')}:'
            '${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
      }

      final result =
      await GoogleSheetService.addAttendance(
        date: DateTime.now().toString(),

        employeeName:
        user.displayName ??
            user.email ??
            'Employee',

        email:
        user.email ?? '',

        checkIn:
        checkInTime.toString(),

        checkOut:
        DateTime.now().toString(),

        checkInDuration:
        formattedAttendanceDuration,

        loginTime: loginTime,

        logoutTime: logoutTime,

        loginDuration: loginDuration,
      );

      print(
        'Attendance Sheet Sync Result: $result',
      );


      // =====================================
// SHEET 3 DAILY SUMMARY
// =====================================

      final halfDay =
      totalAttendanceDuration.inMinutes < 270
          ? "YES"
          : "NO";

      final summaryResult =
      await GoogleSheetService.updateDailySummary(
        date:
        "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}",

        employeeName:
        user.displayName ??
            user.email ??
            "Employee",

        email:
        user.email ?? "",

        attendanceDuration:
        formattedTotalAttendance,

        loginDuration:
        loginDuration,

        halfDay:
        halfDay,
      );

      print(
        "Daily Summary Sync Result: $summaryResult",
      );
    }


    if (user == null) {
      return;
    }

    final sessionCollection =
    _firestore
        .collection('employees')
        .doc(user.uid)
        .collection('sessions');

    final activeSession =
    await sessionCollection
        .where(
      'status',
      isEqualTo: 'Logged In',
    )
        .limit(1)
        .get();

    if (activeSession.docs.isNotEmpty) {
      await activeSession.docs.first.reference.update({
        'logoutTime': Timestamp.now(),
        'status': 'Logged Out',
      });
    }
  }
  // ==========================
  // CURRENT STATUS
  // ==========================

  Future<bool> isCheckedIn() async {
    final snapshot =
    await _attendanceCollection
        .where(
      'status',
      isEqualTo:
      'checked_in',
    )
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }


  Future<int> getTodayWorkedSeconds() async {
    final now = DateTime.now();

    final startOfDay = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final endOfDay =
    startOfDay.add(const Duration(days: 1));

    final snapshot = await _attendanceCollection
        .where(
      'checkIn',
      isGreaterThanOrEqualTo:
      Timestamp.fromDate(startOfDay),
    )
        .where(
      'checkIn',
      isLessThan:
      Timestamp.fromDate(endOfDay),
    )
        .get();

    int total = 0;

    for (final doc in snapshot.docs) {
      total +=
      (doc.data()['workedSeconds'] ?? 0)
      as int;
    }

    return total;
  }

  // ==========================
  // CURRENT CHECK IN TIME
  // ==========================

  Future<DateTime?> getCheckInTime()
  async {
    final snapshot =
    await _attendanceCollection
        .where(
      'status',
      isEqualTo:
      'checked_in',
    )
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    return (snapshot.docs.first[
    'checkIn'] as Timestamp)
        .toDate();
  }

  // ==========================
  // LIVE TIMER
  // ==========================

  Stream<Duration> liveTimer() async* {
    while (true) {
      try {
        final todaySeconds =
        await getTodayWorkedSeconds();

        final checkInTime =
        await getCheckInTime();

        if (checkInTime == null) {
          yield Duration(
            seconds: todaySeconds,
          );
        } else {
          final runningSeconds =
              DateTime.now()
                  .difference(checkInTime)
                  .inSeconds;

          yield Duration(
            seconds:
            todaySeconds + runningSeconds,
          );
        }
      } catch (_) {
        yield Duration.zero;
      }

      await Future.delayed(
        const Duration(seconds: 1),
      );
    }
  }
  // ==========================
  // HISTORY
  // ==========================

  Future<List<AttendanceModel>>
  attendanceHistory() async {
    final snapshot =
    await _attendanceCollection
        .orderBy(
      'checkIn',
      descending: true,
    )
        .get();

    return snapshot.docs
        .map(
          (doc) =>
          AttendanceModel
              .fromFirestore(
            doc,
          ),
    )
        .toList();
  }

  // ==========================
  // TODAY RECORD
  // ==========================

  Future<AttendanceModel?>
  todayAttendance() async {
    final now = DateTime.now();

    final startOfDay =
    DateTime(
      now.year,
      now.month,
      now.day,
    );

    final endOfDay =
    startOfDay.add(
      const Duration(days: 1),
    );

    final snapshot =
    await _attendanceCollection
        .where(
      'checkIn',
      isGreaterThanOrEqualTo:
      Timestamp.fromDate(
        startOfDay,
      ),
    )
        .where(
      'checkIn',
      isLessThan:
      Timestamp.fromDate(
        endOfDay,
      ),
    )
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    return AttendanceModel.fromFirestore(
      snapshot.docs.first,
    );
  }

  // ==========================
  // DELETE RECORD
  // ==========================

  Future<void> deleteAttendance(
      String documentId,
      ) async {
    await _attendanceCollection
        .doc(documentId)
        .delete();
  }
}