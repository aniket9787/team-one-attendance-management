import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/leave_model.dart';

class LeaveService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>>
  get _leaveCollection =>
      _firestore.collection(
        'leave_requests',
      );

  // ==========================
  // APPLY LEAVE
  // ==========================

  Future<void> applyLeave({
    required String employeeName,
    required String employeeEmail,
    required String leaveType,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception(
        'User not logged in',
      );
    }

    final totalDays =
        endDate
            .difference(startDate)
            .inDays +
            1;

    final leave = LeaveModel(
      id: '',
      employeeId: user.uid,
      employeeName: employeeName,
      employeeEmail: employeeEmail,
      leaveType: leaveType,
      startDate: startDate,
      endDate: endDate,
      totalDays: totalDays,
      reason: reason,
      status: 'Pending',
      approvedBy: '',
      appliedAt: Timestamp.now(),
      approvedAt: null,
    );

    await _leaveCollection.add(
      leave.toMap(),
    );
  }

  // ==========================
  // EMPLOYEE LEAVE HISTORY
  // ==========================

  Future<List<LeaveModel>>
  getMyLeaves() async {
    final user = _auth.currentUser;

    if (user == null) {
      return [];
    }

    final snapshot =
    await _leaveCollection
        .where(
      'employeeId',
      isEqualTo: user.uid,
    )
        .orderBy(
      'appliedAt',
      descending: true,
    )
        .get();

    return snapshot.docs
        .map(
          (e) =>
          LeaveModel.fromDocument(
            e,
          ),
    )
        .toList();
  }

  // ==========================
  // ADMIN - ALL LEAVES
  // ==========================

  Future<List<LeaveModel>>
  getAllLeaves() async {
    final snapshot =
    await _leaveCollection
        .orderBy(
      'appliedAt',
      descending: true,
    )
        .get();

    return snapshot.docs
        .map(
          (e) =>
          LeaveModel.fromDocument(
            e,
          ),
    )
        .toList();
  }

  // ==========================
  // APPROVE LEAVE
  // ==========================

  Future<void> approveLeave(
      String leaveId,
      String adminName,
      ) async {
    await _leaveCollection
        .doc(leaveId)
        .update({
      'status': 'Approved',
      'approvedBy': adminName,
      'approvedAt':
      FieldValue.serverTimestamp(),
    });
  }

  // ==========================
  // REJECT LEAVE
  // ==========================

  Future<void> rejectLeave(
      String leaveId,
      String adminName,
      ) async {
    await _leaveCollection
        .doc(leaveId)
        .update({
      'status': 'Rejected',
      'approvedBy': adminName,
      'approvedAt':
      FieldValue.serverTimestamp(),
    });
  }

  // ==========================
  // DELETE LEAVE
  // ==========================

  Future<void> deleteLeave(
      String leaveId,
      ) async {
    await _leaveCollection
        .doc(leaveId)
        .delete();
  }

  // ==========================
  // PENDING COUNT
  // ==========================

  Future<int> pendingCount() async {
    final snapshot =
    await _leaveCollection
        .where(
      'status',
      isEqualTo: 'Pending',
    )
        .get();

    return snapshot.docs.length;
  }

  // ==========================
  // APPROVED COUNT
  // ==========================

  Future<int> approvedCount() async {
    final snapshot =
    await _leaveCollection
        .where(
      'status',
      isEqualTo: 'Approved',
    )
        .get();

    return snapshot.docs.length;
  }

  // ==========================
  // REJECTED COUNT
  // ==========================

  Future<int> rejectedCount() async {
    final snapshot =
    await _leaveCollection
        .where(
      'status',
      isEqualTo: 'Rejected',
    )
        .get();

    return snapshot.docs.length;
  }

  // ==========================
  // LIVE STREAM
  // ==========================

  Stream<List<LeaveModel>>
  leaveStream() {
    return _leaveCollection
        .orderBy(
      'appliedAt',
      descending: true,
    )
        .snapshots()
        .map(
          (snapshot) =>
          snapshot.docs
              .map(
                (doc) =>
                LeaveModel.fromDocument(
                  doc,
                ),
          )
              .toList(),
    );
  }
}