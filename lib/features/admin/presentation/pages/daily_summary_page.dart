import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DailySummaryPage extends StatefulWidget {
  const DailySummaryPage({super.key});

  @override
  State<DailySummaryPage> createState() =>
      _DailySummaryPageState();
}

class _DailySummaryPageState
    extends State<DailySummaryPage> {

final FirebaseFirestore _firestore =
FirebaseFirestore.instance;

bool loading = true;

List<QueryDocumentSnapshot> attendance = [];

int totalEmployees = 0;
int presentEmployees = 0;
int halfDayEmployees = 0;
int absentEmployees = 0;

int checkedIn = 0;
int checkedOut = 0;

double totalHours = 0;

@override
void initState() {
super.initState();
loadSummary();
}

Future<void> loadSummary() async {
try {

// Employees
final employeeSnapshot =
await _firestore
.collection("employees")
.get();

totalEmployees =
employeeSnapshot.docs.length;

// Today's Attendance
final attendanceSnapshot =
await _firestore
.collectionGroup("attendance")
.orderBy(
"checkIn",
descending: true,
)
.get();

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

presentEmployees = 0;
halfDayEmployees = 0;
absentEmployees = 0;

checkedIn = 0;
checkedOut = 0;

totalHours = 0;

for (final doc in attendance) {

final data =
doc.data() as Map<String, dynamic>;

final workedSeconds =
(data["workedSeconds"] ?? 0) as int;

final status =
data["status"] ?? "";

totalHours +=
workedSeconds / 3600;

if (workedSeconds >= 32400) {

presentEmployees++;

} else if (workedSeconds >= 16200) {

halfDayEmployees++;

} else {

absentEmployees++;
}

if (status == "checked_in") {
  checkedIn++;
} else if (status == "checked_out") {
  checkedOut++;
}
}
}

String formatHours(double hours) {

return hours.toStringAsFixed(1);
}

String formatDate(Timestamp? timestamp) {

if (timestamp == null) {
return "--";
}

final date =
timestamp.toDate();

return
"${date.day}/${date.month}/${date.year}";
}

String formatTime(Timestamp? timestamp) {

if (timestamp == null) {
return "--";
}

final date =
timestamp.toDate();

int hour =
date.hour % 12;

if (hour == 0) {
hour = 12;
}

final minute =
date.minute
.toString()
.padLeft(2, "0");

final period =
date.hour >= 12
? "PM"
: "AM";

return "$hour:$minute $period";
}

@override
Widget build(BuildContext context) {


return Scaffold(
backgroundColor: const Color(0xFFF5F7FA),

appBar: AppBar(
title: const Text("Daily Summary"),
centerTitle: true,
),

body: loading
? const Center(
child: CircularProgressIndicator(),
)
: SingleChildScrollView(
padding: const EdgeInsets.all(16),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [

const Text(
"Today's Summary",
style: TextStyle(
fontSize: 24,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 20),

//========================================
// SUMMARY CARDS
//========================================

Row(
children: [

Expanded(
child: _SummaryCard(
title: "Present",
value: presentEmployees.toString(),
icon: Icons.check_circle,
color: Colors.green,
),
),

const SizedBox(width: 12),

Expanded(
child: _SummaryCard(
title: "Absent",
value: absentEmployees.toString(),
icon: Icons.cancel,
color: Colors.red,
),
),
],
),

const SizedBox(height: 12),

Row(
children: [

Expanded(
child: _SummaryCard(
title: "Half Day",
value: halfDayEmployees.toString(),
icon: Icons.timelapse,
color: Colors.orange,
),
),

const SizedBox(width: 12),

Expanded(
child: _SummaryCard(
title: "Employees",
value: totalEmployees.toString(),
icon: Icons.people,
color: Colors.blue,
),
),
],
),

const SizedBox(height: 25),

//========================================
// TODAY STATISTICS
//========================================

Card(
elevation: 3,
shape: RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(16),
),
child: Padding(
padding:
const EdgeInsets.all(16),
child: Column(
children: [

ListTile(
leading: const Icon(
Icons.schedule,
color: Colors.blue,
),
title: const Text(
"Total Working Hours",
),
trailing: Text(
"${formatHours(totalHours)} hrs",
style: const TextStyle(
fontWeight:
FontWeight.bold,
),
),
),

const Divider(),

ListTile(
leading: const Icon(
Icons.login,
color: Colors.green,
),
title: const Text(
"Checked In",
),
trailing: Text(
checkedIn.toString(),
style: const TextStyle(
fontWeight:
FontWeight.bold,
),
),
),

const Divider(),

ListTile(
leading: const Icon(
Icons.logout,
color: Colors.red,
),
title: const Text(
"Checked Out",
),
trailing: Text(
checkedOut.toString(),
style: const TextStyle(
fontWeight:
FontWeight.bold,
),
),
),
],
),
),
),

const SizedBox(height: 25),

const Text(
"Today's Attendance Activity",
style: TextStyle(
fontSize: 22,
fontWeight: FontWeight.bold,
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

final employeeName =
(data["employeeName"] ?? "")
    .toString();

final avatarLetter =
employeeName.isNotEmpty
    ? employeeName[0].toUpperCase()
    : "?";

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

  CircleAvatar(
    backgroundColor: Colors.blue.shade100,
    child: Text(avatarLetter),
  ),

const SizedBox(width: 12),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [

Text(
employeeName,
style:
const TextStyle(
fontSize: 17,
fontWeight:
FontWeight.bold,
),
),

Text(
formatDate(checkIn),
style: TextStyle(
color: Colors
.grey.shade600,
),
),
],
),
),

Container(
padding:
const EdgeInsets.symmetric(
horizontal: 12,
vertical: 6,
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

const Divider(height: 25),

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
title:
const Text("Check In"),
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
title:
const Text("Check Out"),
subtitle: Text(
formatTime(checkOut),
),
),
),
],
),

const SizedBox(height: 10),

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

const Divider(height: 25),

const Text(
"Today's Report",
style: TextStyle(
fontWeight:
FontWeight.bold,
),
),

const SizedBox(height: 8),

Text(
report,
style: TextStyle(
color: Colors.grey.shade700,
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

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(16),
      ),
      child: Padding(
        padding:
        const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 12,
        ),
        child: Column(
          children: [

            CircleAvatar(
              radius: 26,
              backgroundColor:
              color.withOpacity(0.12),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),

            const SizedBox(height: 14),

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
              textAlign: TextAlign.center,
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