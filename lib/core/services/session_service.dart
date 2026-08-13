import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/session_model.dart';
import 'attendance_service.dart';

class SessionService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>>
  get _sessionCollection {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User not logged in');
    }

    return _firestore
        .collection('employees')
        .doc(user.uid)
        .collection('sessions');
  }

  // ==========================
  // LOGIN
  // ==========================

  Future<void> login() async {
    final activeSession =
    await _sessionCollection
        .where(
      'status',
      isEqualTo: 'Logged In',
    )
        .limit(1)
        .get();

    if (activeSession.docs.isNotEmpty) {
      return;
    }

    await _sessionCollection.add({
      'loginTime': Timestamp.now(),
      'logoutTime': null,
      'status': 'Logged In',
      'createdAt': Timestamp.now(),
    });

    // AUTO CHECK-IN
    final attendanceService =
    AttendanceService();

    final alreadyCheckedIn =
    await attendanceService.isCheckedIn();

    if (!alreadyCheckedIn) {
      await attendanceService.checkIn();
    }
  }

  // ==========================
  // LOGOUT
  // ==========================

  Future<void> logout() async {
    final activeSession =
    await _sessionCollection
        .where(
      'status',
      isEqualTo: 'Logged In',
    )
        .limit(1)
        .get();

    if (activeSession.docs.isEmpty) {
      return;
    }

    await activeSession.docs.first.reference
        .update({
      'logoutTime': Timestamp.now(),
      'status': 'Logged Out',
    });
  }

  // ==========================
  // IS LOGGED IN
  // ==========================

  Future<bool> isLoggedIn() async {
    final snapshot =
    await _sessionCollection
        .where(
      'status',
      isEqualTo: 'Logged In',
    )
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  // ==========================
  // CURRENT SESSION
  // ==========================

  Future<SessionModel?> currentSession() async {
    final snapshot =
    await _sessionCollection
        .where(
      'status',
      isEqualTo: 'Logged In',
    )
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    return SessionModel.fromFirestore(
      snapshot.docs.first,
    );
  }

  // ==========================
  // SESSION HISTORY
  // ==========================

  Future<List<SessionModel>>
  sessionHistory() async {
    final snapshot =
    await _sessionCollection
        .orderBy(
      'loginTime',
      descending: true,
    )
        .get();

    return snapshot.docs
        .map(
          (doc) =>
          SessionModel.fromFirestore(doc),
    )
        .toList();
  }

  // ==========================
  // LIVE SESSION TIMER
  // ==========================

  Stream<Duration>
  liveSessionTimer() async* {
    while (true) {
      final session =
      await currentSession();

      if (session == null) {
        yield Duration.zero;
      } else {
        yield DateTime.now().difference(
          session.loginTime,
        );
      }

      await Future.delayed(
        const Duration(seconds: 1),
      );
    }
  }
}