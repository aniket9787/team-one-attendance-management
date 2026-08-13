import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EmployeeReportPage extends StatefulWidget {
  final String employeeId;
  final String employeeName;

  const EmployeeReportPage({
    super.key,
    required this.employeeId,
    required this.employeeName,
  });

  @override
  State<EmployeeReportPage> createState() =>
      _EmployeeReportPageState();
}

class _EmployeeReportPageState
    extends State<EmployeeReportPage> {
final FirebaseFirestore _firestore =
FirebaseFirestore.instance;

bool loading = true;

Map<String, dynamic>? employeeData;

List<QueryDocumentSnapshot> attendance = [];

int presentDays = 0;
int halfDays = 0;
int absentDays = 0;

double totalHours = 0;

@override
void initState() {
super.initState();
loadEmployeeReport();
}

Future<void> loadEmployeeReport() async {
try {
// Employee Details
final employeeDoc = await _firestore
.collection("employees")
.doc(widget.employeeId)
.get();

// Attendance
final attendanceSnapshot =
await _firestore
.collection("employees")
.doc(widget.employeeId)
.collection("attendance")
.orderBy(
"checkIn",
descending: true,
)
.get();

employeeData = employeeDoc.data();

attendance = attendanceSnapshot.docs;

calculateSummary();

if (!mounted) return;

setState(() {
loading = false;
});
} catch (e) {
debugPrint(e.toString());

if (!mounted) return;

setState(() {
loading = false;
});
}
}

void calculateSummary() {
presentDays = 0;
halfDays = 0;
absentDays = 0;
totalHours = 0;

for (final doc in attendance) {
final data =
doc.data() as Map<String, dynamic>;

final seconds =
(data["workedSeconds"] ?? 0) as int;

final hours =
seconds / 3600;

totalHours += hours;

if (seconds >= 32400) {
// 9 Hours
presentDays++;
} else if (seconds >= 16200) {
// 4.5 Hours
halfDays++;
} else {
absentDays++;
}
}
}

String formatHours(double hours) {
return hours.toStringAsFixed(1);
}

String formatDate(Timestamp? timestamp) {
if (timestamp == null) {
return "N/A";
}

final date = timestamp.toDate();

return
"${date.day}/${date.month}/${date.year}";
}

String formatTime(Timestamp? timestamp) {
if (timestamp == null) {
return "--";
}

final date = timestamp.toDate();

int hour = date.hour % 12;

if (hour == 0) hour = 12;

final minute =
date.minute.toString().padLeft(2, "0");

final period =
date.hour >= 12 ? "PM" : "AM";

return "$hour:$minute $period";
}

@override
Widget build(BuildContext context) {

return Scaffold(
backgroundColor: const Color(0xFFF5F7FA),

appBar: AppBar(
title: Text(widget.employeeName),
centerTitle: true,
),

body: loading
? const Center(
child: CircularProgressIndicator(),
)
: SingleChildScrollView(
padding: const EdgeInsets.all(16),
child: Column(
children: [

//====================================
// EMPLOYEE PROFILE
//====================================

Card(
elevation: 3,
shape: RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(16),
),
child: Padding(
padding:
const EdgeInsets.all(16),
child: Row(
children: [

CircleAvatar(
radius: 35,
backgroundImage:
employeeData?[
"profileImage"] !=
null &&
employeeData![
"profileImage"]
.toString()
.isNotEmpty
? NetworkImage(
employeeData![
"profileImage"],
)
: null,
child: employeeData?[
"profileImage"] ==
null ||
employeeData![
"profileImage"]
.toString()
.isEmpty
? Text(
widget.employeeName
.substring(0, 1)
.toUpperCase(),
style:
const TextStyle(
fontSize: 24,
fontWeight:
FontWeight.bold,
),
)
: null,
),

const SizedBox(width: 16),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment
.start,
children: [

Text(
widget.employeeName,
style:
const TextStyle(
fontSize: 20,
fontWeight:
FontWeight.bold,
),
),

const SizedBox(
height: 6),

Text(
employeeData?[
"email"] ??
"",
),

const SizedBox(
height: 4),

Text(
"Role : ${employeeData?["role"] ?? ""}",
),

const SizedBox(
height: 4),

Text(
employeeData?[
"isOnline"] ==
true
? "🟢 Online"
: "⚫ Offline",
),
],
),
),
],
),
),
),

const SizedBox(height: 20),

//====================================
// SUMMARY
//====================================

Row(
children: [

Expanded(
child: _SummaryBox(
title: "Present",
value:
presentDays.toString(),
icon:
Icons.check_circle,
),
),

const SizedBox(width: 10),

Expanded(
child: _SummaryBox(
title: "Half Day",
value:
halfDays.toString(),
icon: Icons.timelapse,
),
),
],
),

const SizedBox(height: 10),

Row(
children: [

Expanded(
child: _SummaryBox(
title: "Absent",
value:
absentDays.toString(),
icon: Icons.cancel,
),
),

const SizedBox(width: 10),

Expanded(
child: _SummaryBox(
title: "Hours",
value: formatHours(
totalHours),
icon: Icons.schedule,
),
),
],
),

const SizedBox(height: 25),

const Align(
alignment:
Alignment.centerLeft,
child: Text(
"Attendance History",
style: TextStyle(
fontSize: 20,
fontWeight:
FontWeight.bold,
),
),
),

const SizedBox(height: 15),



if (attendance.isEmpty)
const Card(
child: Padding(
padding: EdgeInsets.all(20),
child: Center(
child: Text(
"No Attendance Records Found",
style: TextStyle(
fontSize: 16,
),
),
),
),
)
else
ListView.builder(
shrinkWrap: true,
physics:
const NeverScrollableScrollPhysics(),
itemCount: attendance.length,
itemBuilder: (context, index) {
final data = attendance[index].data()
as Map<String, dynamic>;

final checkIn =
data["checkIn"] as Timestamp?;

final checkOut =
data["checkOut"] as Timestamp?;

final workedSeconds =
(data["workedSeconds"] ?? 0) as int;

final report =
data["report"] ?? "";

final hours =
workedSeconds / 3600;

String status;

Color statusColor;

if (workedSeconds >= 32400) {
status = "Present";
statusColor = Colors.green;
} else if (workedSeconds >= 16200) {
status = "Half Day";
statusColor = Colors.orange;
} else {
status = "Absent";
statusColor = Colors.red;
}

return Card(
elevation: 3,
margin:
const EdgeInsets.only(
bottom: 12,
),
shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(15),
),
child: Padding(
padding:
const EdgeInsets.all(16),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [

Row(
children: [

const Icon(
Icons.calendar_month,
color: Colors.blue,
),

const SizedBox(width: 8),

Expanded(
child: Text(
formatDate(checkIn),
style:
const TextStyle(
fontWeight:
FontWeight.bold,
fontSize: 16,
),
),
),

Container(
padding:
const EdgeInsets.symmetric(
horizontal: 12,
vertical: 5,
),
decoration:
BoxDecoration(
color: statusColor,
borderRadius:
BorderRadius.circular(
20,
),
),
child: Text(
status,
style:
const TextStyle(
color: Colors.white,
fontWeight:
FontWeight.bold,
),
),
),
],
),

const Divider(
height: 25,
),

Row(
children: [

Expanded(
child: ListTile(
dense: true,
contentPadding:
EdgeInsets.zero,
leading: const Icon(
Icons.login,
color: Colors.green,
),
title: const Text(
"Check In"),
subtitle: Text(
formatTime(checkIn),
),
),
),

Expanded(
child: ListTile(
dense: true,
contentPadding:
EdgeInsets.zero,
leading: const Icon(
Icons.logout,
color: Colors.red,
),
title: const Text(
"Check Out"),
subtitle: Text(
formatTime(checkOut),
),
),
),
],
),

const SizedBox(height: 8),

Row(
children: [

const Icon(
Icons.schedule,
color: Colors.blue,
),

const SizedBox(width: 8),

Text(
"${hours.toStringAsFixed(2)} Hours",
style:
const TextStyle(
fontWeight:
FontWeight.bold,
),
),
],
),

if (report
.toString()
.trim()
.isNotEmpty) ...[

const SizedBox(
height: 15),

const Divider(),

const Text(
"Daily Report",
style: TextStyle(
fontWeight:
FontWeight.bold,
),
),

const SizedBox(
height: 6),

Text(
report,
style: TextStyle(
color:
Colors.grey.shade700,
height: 1.4,
),
),
],
],
),
),
);
},
),

  ],
  ),
  ),
  );
}
}

class _SummaryBox extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _SummaryBox({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(15),
      ),
      child: Padding(
        padding:
        const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 12,
        ),
        child: Column(
          children: [

            CircleAvatar(
              radius: 24,
              backgroundColor:
              Colors.blue.shade50,
              child: Icon(
                icon,
                color: Colors.blue,
                size: 26,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight:
                FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}