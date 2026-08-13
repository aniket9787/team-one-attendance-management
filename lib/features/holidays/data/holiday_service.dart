import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/holiday_model.dart';

class HolidayService {
  HolidayService();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>>
  get _holidayCollection =>
      _firestore.collection("holidays");

  //==================================================
  // ADD HOLIDAY
  //==================================================

  Future<void> addHoliday({
    required String title,
    required String description,
    required String holidayType,
    required DateTime holidayDate,
    required bool isOptional,
  }) async {
    try {
      await _holidayCollection.add({
        "title": title.trim(),
        "description": description.trim(),
        "holidayType": holidayType,
        "holidayDate":
        Timestamp.fromDate(holidayDate),
        "isOptional": isOptional,
        "createdAt":
        FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception(
        "Unable to add holiday.\n$e",
      );
    }
  }

  //==================================================
  // UPDATE HOLIDAY
  //==================================================

  Future<void> updateHoliday({
    required String id,
    required String title,
    required String description,
    required String holidayType,
    required DateTime holidayDate,
    required bool isOptional,
  }) async {
    try {
      await _holidayCollection.doc(id).update({
        "title": title.trim(),
        "description": description.trim(),
        "holidayType": holidayType,
        "holidayDate":
        Timestamp.fromDate(holidayDate),
        "isOptional": isOptional,
      });
    } catch (e) {
      throw Exception(
        "Unable to update holiday.\n$e",
      );
    }
  }

  //==================================================
  // DELETE HOLIDAY
  //==================================================

  Future<void> deleteHoliday(
      String id,
      ) async {
    try {
      await _holidayCollection
          .doc(id)
          .delete();
    } catch (e) {
      throw Exception(
        "Unable to delete holiday.\n$e",
      );
    }
  }

  //==================================================
  // HOLIDAY STREAM
  //==================================================

  Stream<List<HolidayModel>>
  holidayStream() {
    return _holidayCollection
        .orderBy(
      "holidayDate",
      descending: false,
    )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map(
            (doc) =>
            HolidayModel.fromDocument(doc),
      )
          .toList(),
    );
  }

  //==================================================
  // GET ALL HOLIDAYS
  //==================================================

  Future<List<HolidayModel>>
  getAllHolidays() async {
    try {
      final snapshot =
      await _holidayCollection
          .orderBy("holidayDate")
          .get();

      return snapshot.docs
          .map(
            (doc) =>
            HolidayModel.fromDocument(doc),
      )
          .toList();
    } catch (e) {
      throw Exception(
        "Unable to fetch holidays.\n$e",
      );
    }
  }

  //==================================================
  // UPCOMING HOLIDAYS
  //==================================================

  Future<List<HolidayModel>>
  upcomingHolidays() async {
    try {
      final snapshot =
      await _holidayCollection
          .where(
        "holidayDate",
        isGreaterThanOrEqualTo:
        Timestamp.fromDate(
          DateTime.now(),
        ),
      )
          .orderBy("holidayDate")
          .get();

      return snapshot.docs
          .map(
            (doc) =>
            HolidayModel.fromDocument(doc),
      )
          .toList();
    } catch (e) {
      throw Exception(
        "Unable to fetch upcoming holidays.\n$e",
      );
    }
  }

  //==================================================
  // TOTAL HOLIDAY COUNT
  //==================================================

  Future<int> totalHolidayCount() async {
    final snapshot =
    await _holidayCollection.count().get();

    return snapshot.count ?? 0;
  }

  //==================================================
  // OPTIONAL HOLIDAY COUNT
  //==================================================

  Future<int> optionalHolidayCount() async {
    final holidays =
    await getAllHolidays();

    return holidays
        .where((e) => e.isOptional)
        .length;
  }

  //==================================================
  // MANDATORY HOLIDAY COUNT
  //==================================================

  Future<int> mandatoryHolidayCount() async {
    final holidays =
    await getAllHolidays();

    return holidays
        .where((e) => !e.isOptional)
        .length;
  }

  //==================================================
  // NEXT HOLIDAY
  //==================================================

  Future<HolidayModel?> nextHoliday() async {
    final holidays =
    await upcomingHolidays();

    if (holidays.isEmpty) {
      return null;
    }

    return holidays.first;
  }

  //==================================================
  // SEARCH
  //==================================================

  Future<List<HolidayModel>>
  searchHoliday(
      String keyword,
      ) async {
    final holidays =
    await getAllHolidays();

    if (keyword.trim().isEmpty) {
      return holidays;
    }

    final lower =
    keyword.toLowerCase();

    return holidays.where((holiday) {
      return holiday.title
          .toLowerCase()
          .contains(lower) ||
          holiday.description
              .toLowerCase()
              .contains(lower) ||
          holiday.holidayType
              .toLowerCase()
              .contains(lower);
    }).toList();
  }
}