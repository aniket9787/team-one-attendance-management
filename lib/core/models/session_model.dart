import 'package:cloud_firestore/cloud_firestore.dart';

class SessionModel {
  final String id;
  final DateTime loginTime;
  final DateTime? logoutTime;

  SessionModel({
    required this.id,
    required this.loginTime,
    this.logoutTime,
  });

  factory SessionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return SessionModel(
      id: doc.id,
      loginTime: (data['loginTime'] as Timestamp).toDate(),
      logoutTime: data['logoutTime'] != null
          ? (data['logoutTime'] as Timestamp).toDate()
          : null,
    );
  }

  Duration get sessionDuration {
    if (logoutTime == null) {
      return DateTime.now().difference(loginTime);
    }

    return logoutTime!.difference(loginTime);
  }

  bool get isActive => logoutTime == null;

  // HH:MM:SS FORMAT
  String get formattedDuration {
    final duration = sessionDuration;

    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toMap() {
    return {
      'loginTime': Timestamp.fromDate(loginTime),
      'logoutTime': logoutTime != null
          ? Timestamp.fromDate(logoutTime!)
          : null,
    };
  }
}