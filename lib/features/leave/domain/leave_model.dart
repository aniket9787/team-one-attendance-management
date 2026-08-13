import 'package:cloud_firestore/cloud_firestore.dart';

class LeaveModel {
  final String id;

  final String employeeId;
  final String employeeName;
  final String employeeEmail;

  final String leaveType;

  final DateTime startDate;
  final DateTime endDate;

  final int totalDays;

  final String reason;

  final String status;

  final String approvedBy;

  final Timestamp? appliedAt;
  final Timestamp? approvedAt;

  const LeaveModel({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.employeeEmail,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.reason,
    required this.status,
    required this.approvedBy,
    this.appliedAt,
    this.approvedAt,
  });

  factory LeaveModel.fromDocument(
      DocumentSnapshot doc,
      ) {
    final data =
    doc.data() as Map<String, dynamic>;

    return LeaveModel(
      id: doc.id,

      employeeId:
      data['employeeId'] ?? '',

      employeeName:
      data['employeeName'] ?? '',

      employeeEmail:
      data['employeeEmail'] ?? '',

      leaveType:
      data['leaveType'] ?? '',

      startDate:
      (data['startDate']
      as Timestamp)
          .toDate(),

      endDate:
      (data['endDate']
      as Timestamp)
          .toDate(),

      totalDays:
      data['totalDays'] ?? 1,

      reason:
      data['reason'] ?? '',

      status:
      data['status'] ?? 'Pending',

      approvedBy:
      data['approvedBy'] ?? '',

      appliedAt:
      data['appliedAt'],

      approvedAt:
      data['approvedAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'employeeId': employeeId,
      'employeeName': employeeName,
      'employeeEmail': employeeEmail,

      'leaveType': leaveType,

      'startDate':
      Timestamp.fromDate(
        startDate,
      ),

      'endDate':
      Timestamp.fromDate(
        endDate,
      ),

      'totalDays': totalDays,

      'reason': reason,

      'status': status,

      'approvedBy': approvedBy,

      'appliedAt':
      appliedAt ??
          FieldValue.serverTimestamp(),

      'approvedAt': approvedAt,
    };
  }

  bool get isPending =>
      status == "Pending";

  bool get isApproved =>
      status == "Approved";

  bool get isRejected =>
      status == "Rejected";
}