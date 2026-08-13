import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceModel {
  final String id;
  final DateTime checkIn;
  final DateTime? checkOut;
  final String report;

  AttendanceModel({
    required this.id,
    required this.checkIn,
    this.checkOut,
    this.report = '',
  });

  factory AttendanceModel.fromFirestore(
      DocumentSnapshot doc,
      ) {
    final data = doc.data() as Map<String, dynamic>;

    return AttendanceModel(
      id: doc.id,
      checkIn: (data['checkIn'] as Timestamp).toDate(),
      checkOut: data['checkOut'] != null
          ? (data['checkOut'] as Timestamp).toDate()
          : null,
      report: data['report'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'checkIn': Timestamp.fromDate(checkIn),
      'checkOut': checkOut != null
          ? Timestamp.fromDate(checkOut!)
          : null,
      'report': report,
    };
  }

  Duration get totalDuration {
    if (checkOut == null) {
      return DateTime.now().difference(checkIn);
    }

    return checkOut!.difference(checkIn);
  }

  bool get isActive => checkOut == null;

  String get attendanceStatus {
    return checkOut == null
        ? 'Checked In'
        : 'Checked Out';
  }

  // ==========================
  // NEW HELPERS
  // ==========================

  String get formattedDate {
    return "${checkIn.day.toString().padLeft(2, '0')}/"
        "${checkIn.month.toString().padLeft(2, '0')}/"
        "${checkIn.year}";
  }

  String get formattedCheckIn {
    return _formatTime(checkIn);
  }

  String get formattedCheckOut {
    if (checkOut == null) return "-";
    return _formatTime(checkOut!);
  }

  String get formattedDuration {
    return _formatDuration(totalDuration);
  }

  static String _formatTime(DateTime date) {
    int hour = date.hour % 12;
    if (hour == 0) hour = 12;

    final minute =
    date.minute.toString().padLeft(2, '0');

    final period =
    date.hour >= 12 ? "PM" : "AM";

    return "$hour:$minute $period";
  }

  static String _formatDuration(Duration d) {
    String two(int n) =>
        n.toString().padLeft(2, '0');

    return "${two(d.inHours)}:"
        "${two(d.inMinutes.remainder(60))}:"
        "${two(d.inSeconds.remainder(60))}";
  }
}