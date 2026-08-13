import 'dart:convert';
import 'package:http/http.dart' as http;

class GoogleSheetService {
  static const String sheetUrl =
      'https://script.google.com/macros/s/AKfycbz2BuJ1LaVo45qkez_XTNkXtlR_gdDV4m_TJuVtWH9ZuyPxk4BmaxtO0H1Lx1F3KAs6/exec';

// ==========================================
// COMMON POST METHOD
// ==========================================

  static Future<bool> _sendData(
      Map<String, dynamic> payload,
      ) async {
    try {
      final response = await http.post(
        Uri.parse(sheetUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );


    print(
    'Google Sheet Response: ${response.body}',
    );

    return response.statusCode == 200;
    } catch (e) {
    print(
    'Google Sheet Service Error: $e',
    );
    return false;
    }


  }

// ==========================================
// EMPLOYEE REGISTRATION
// SHEET 1
// ==========================================

  static Future<bool> addEmployee({
    required String name,
    required String email,
    required String role,
  }) async {
    return await _sendData({
      'type': 'employee',


        'name': name,

        'email': email,

        'role': role,

        'createdAt':
        DateTime.now().toIso8601String(),
  });


  }

// ==========================================
// ATTENDANCE REPORT
// SHEET 2
// ==========================================

  static Future<bool> addAttendance({
  required String date,


  required String employeeName,

  required String email,

  required String checkIn,

  required String checkOut,

  required String checkInDuration,

  required String loginTime,

  required String logoutTime,

  required String loginDuration,


}) async {
return await _sendData({
'type': 'attendance',

'date': date,

'employeeName': employeeName,

'email': email,

'checkIn': checkIn,

'checkOut': checkOut,

'checkInDuration':
checkInDuration,

'loginTime': loginTime,

'logoutTime': logoutTime,

'loginDuration':
loginDuration,

'createdAt':
DateTime.now().toIso8601String(),
});

}


// ==========================================
// DAILY SUMMARY
// SHEET 3
// ==========================================

  static Future<bool> updateDailySummary({
    required String date,
    required String employeeName,
    required String email,
    required String attendanceDuration,
    required String loginDuration,
    required String halfDay,
  }) async {
    return await _sendData({
      'type': 'dailySummary',

      'date': date,
      'employeeName': employeeName,
      'email': email,

      'attendanceDuration': attendanceDuration,
      'loginDuration': loginDuration,
      'halfDay': halfDay,
    });
  }
}
