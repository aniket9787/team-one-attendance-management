import 'package:cloud_firestore/cloud_firestore.dart';

class HolidayModel {
  final String id;
  final String title;
  final String description;
  final String holidayType;
  final DateTime holidayDate;
  final bool isOptional;
  final Timestamp? createdAt;

  const HolidayModel({
    required this.id,
    required this.title,
    required this.description,
    required this.holidayType,
    required this.holidayDate,
    required this.isOptional,
    this.createdAt,
  });

  //==========================================
  // FROM FIRESTORE
  //==========================================

  factory HolidayModel.fromDocument(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data()!;

    return HolidayModel(
      id: doc.id,
      title: data["title"] ?? "",
      description: data["description"] ?? "",
      holidayType: data["holidayType"] ?? "General",
      holidayDate:
      (data["holidayDate"] as Timestamp).toDate(),
      isOptional: data["isOptional"] ?? false,
      createdAt: data["createdAt"],
    );
  }

  //==========================================
  // FROM MAP
  //==========================================

  factory HolidayModel.fromMap(
      Map<String, dynamic> map,
      String id,
      ) {
    return HolidayModel(
      id: id,
      title: map["title"] ?? "",
      description: map["description"] ?? "",
      holidayType: map["holidayType"] ?? "General",
      holidayDate:
      (map["holidayDate"] as Timestamp).toDate(),
      isOptional: map["isOptional"] ?? false,
      createdAt: map["createdAt"],
    );
  }

  //==========================================
  // TO MAP
  //==========================================

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "description": description,
      "holidayType": holidayType,
      "holidayDate":
      Timestamp.fromDate(holidayDate),
      "isOptional": isOptional,
      "createdAt":
      createdAt ??
          FieldValue.serverTimestamp(),
    };
  }

  //==========================================
  // COPY WITH
  //==========================================

  HolidayModel copyWith({
    String? id,
    String? title,
    String? description,
    String? holidayType,
    DateTime? holidayDate,
    bool? isOptional,
    Timestamp? createdAt,
  }) {
    return HolidayModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description:
      description ?? this.description,
      holidayType:
      holidayType ?? this.holidayType,
      holidayDate:
      holidayDate ?? this.holidayDate,
      isOptional:
      isOptional ?? this.isOptional,
      createdAt:
      createdAt ?? this.createdAt,
    );
  }

  //==========================================
  // FORMATTED DATE
  //==========================================

  String get formattedDate {
    return "${holidayDate.day.toString().padLeft(2, '0')}/"
        "${holidayDate.month.toString().padLeft(2, '0')}/"
        "${holidayDate.year}";
  }

  //==========================================
  // MONTH NAME
  //==========================================

  String get monthName {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];

    return months[holidayDate.month - 1];
  }

  //==========================================
  // DAY NAME
  //==========================================

  String get dayName {
    const days = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday",
    ];

    return days[holidayDate.weekday - 1];
  }

  //==========================================
  // IS TODAY
  //==========================================

  bool get isToday {
    final now = DateTime.now();

    return holidayDate.day == now.day &&
        holidayDate.month == now.month &&
        holidayDate.year == now.year;
  }

  //==========================================
  // IS PAST
  //==========================================

  bool get isPastHoliday {
    final today = DateTime.now();

    return holidayDate.isBefore(
      DateTime(
        today.year,
        today.month,
        today.day,
      ),
    );
  }

  //==========================================
  // IS UPCOMING
  //==========================================

  bool get isUpcomingHoliday {
    final today = DateTime.now();

    return holidayDate.isAfter(
      DateTime(
        today.year,
        today.month,
        today.day,
      ),
    );
  }

  @override
  String toString() {
    return "HolidayModel("
        "title: $title, "
        "holidayType: $holidayType, "
        "holidayDate: $holidayDate)";
  }
}