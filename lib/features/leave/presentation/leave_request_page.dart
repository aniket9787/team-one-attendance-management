import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/leave_service.dart';
import '../domain/leave_model.dart';

class LeaveRequestPage extends StatefulWidget {
  const LeaveRequestPage({super.key});

  @override
  State<LeaveRequestPage> createState() =>
      _LeaveRequestPageState();
}

class _LeaveRequestPageState
    extends State<LeaveRequestPage> {
final LeaveService leaveService =
LeaveService();

final reasonController =
TextEditingController();

String leaveType = "Casual Leave";

DateTime? startDate;
DateTime? endDate;

bool isLoading = false;

final List<String> leaveTypes = [
"Casual Leave",
"Sick Leave",
"Earned Leave",
"Emergency Leave",
"Work From Home",
];

Future<void> pickStartDate() async {
final picked =
await showDatePicker(
context: context,
initialDate: DateTime.now(),
firstDate: DateTime.now(),
lastDate: DateTime(2035),
);

if (picked != null) {
setState(() {
startDate = picked;

if (endDate != null &&
endDate!.isBefore(
startDate!)) {
endDate = null;
}
});
}
}

Future<void> pickEndDate() async {
if (startDate == null) {
ScaffoldMessenger.of(context)
.showSnackBar(
const SnackBar(
content: Text(
"Select Start Date First",
),
),
);
return;
}

final picked =
await showDatePicker(
context: context,
initialDate: startDate!,
firstDate: startDate!,
lastDate: DateTime(2035),
);

if (picked != null) {
setState(() {
endDate = picked;
});
}
}

@override
void dispose() {
reasonController.dispose();
super.dispose();
}

@override
Widget build(BuildContext context) {
final user =
FirebaseAuth.instance.currentUser;

return Scaffold(
backgroundColor:
const Color(0xffF5F7FA),

appBar: AppBar(
centerTitle: true,
title: const Text(
"Leave Request",
),
),

body: Column(
children: [

Expanded(
child:
SingleChildScrollView(
padding:
const EdgeInsets.all(
16,
),

child: Column(
crossAxisAlignment:
CrossAxisAlignment
.start,

children: [

const Text(
"Apply Leave",
style: TextStyle(
fontSize: 22,
fontWeight:
FontWeight.bold,
),
),

const SizedBox(
height: 20),

DropdownButtonFormField<
String>(
value: leaveType,

decoration:
InputDecoration(
labelText:
"Leave Type",

border:
OutlineInputBorder(
borderRadius:
BorderRadius.circular(
12,
),
),
),

items: leaveTypes
.map(
(e) =>
DropdownMenuItem(
value: e,
child:
Text(e),
),
)
.toList(),

onChanged: (value) {
if (value == null)
return;

setState(() {
leaveType =
value;
});
},
),

const SizedBox(
height: 20),

Row(
children: [

Expanded(
child:
OutlinedButton.icon(
onPressed:
pickStartDate,

icon: const Icon(
Icons
.calendar_today,
),

label: Text(
startDate ==
null
? "Start Date"
: "${startDate!.day}/${startDate!.month}/${startDate!.year}",
),
),
),

const SizedBox(
width: 10),

Expanded(
child:
OutlinedButton.icon(
onPressed:
pickEndDate,

icon: const Icon(
Icons.event,
),

label: Text(
endDate ==
null
? "End Date"
: "${endDate!.day}/${endDate!.month}/${endDate!.year}",
),
),
),
],
),

const SizedBox(
height: 20),

TextField(
controller:
reasonController,

maxLines: 5,

decoration:
InputDecoration(
labelText:
"Reason",

border:
OutlineInputBorder(
borderRadius:
BorderRadius.circular(
12,
),
),
),
),

const SizedBox(
height: 25),

SizedBox(
width:
double.infinity,

height: 50,

child:
ElevatedButton.icon(
icon: isLoading
? const SizedBox(
width: 18,
height: 18,
child:
CircularProgressIndicator(
color: Colors
.white,
strokeWidth:
2,
),
)
: const Icon(
Icons.send,
),

label: const Text(
"Submit Leave Request",
),

  onPressed: isLoading
      ? null
      : () async {
    setState(() {
      isLoading = true;
    });

    try {
      if (startDate == null) {
        throw Exception(
          "Please select Start Date",
        );
      }

      if (endDate == null) {
        throw Exception(
          "Please select End Date",
        );
      }

      if (reasonController.text
          .trim()
          .isEmpty) {
        throw Exception(
          "Please enter leave reason",
        );
      }

      await leaveService.applyLeave(
        employeeName:
        user?.displayName ??
            user?.email ??
            "Employee",
        employeeEmail:
        user?.email ?? "",
        leaveType: leaveType,
        startDate: startDate!,
        endDate: endDate!,
        reason: reasonController.text
            .trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          backgroundColor:
          Colors.green,
          content: Text(
            "Leave Request Submitted Successfully",
          ),
        ),
      );

      reasonController.clear();

      setState(() {
        startDate = null;
        endDate = null;
        leaveType =
        "Casual Leave";
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          backgroundColor:
          Colors.red,
          content: Text(
            e.toString().replaceAll(
                "Exception: ", ""),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  },

),
),

const SizedBox(height: 30),

const Text(
"My Leave Requests",
style: TextStyle(
fontSize: 20,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 15),

StreamBuilder<List<LeaveModel>>(
stream: leaveService.leaveStream(),
builder: (context, snapshot) {
if (snapshot.connectionState ==
ConnectionState.waiting) {
return const Center(
child:
CircularProgressIndicator(),
);
}

if (!snapshot.hasData ||
snapshot.data!.isEmpty) {
return const Padding(
padding:
EdgeInsets.all(20),
child: Center(
child: Text(
"No Leave Requests",
),
),
);
}

List<LeaveModel> myLeaves =
snapshot.data!
.where(
(leave) =>
leave.employeeId ==
user?.uid,
)
.toList();

if (myLeaves.isEmpty) {
return const Padding(
padding:
EdgeInsets.all(20),
child: Center(
child: Text(
"No Leave Requests",
),
),
);
}

return Column(
children: myLeaves.map(
(leave) {

// PART 3 STARTS HERE


return Card(
elevation: 3,
margin: const EdgeInsets.only(bottom: 12),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(15),
),
child: Padding(
padding: const EdgeInsets.all(16),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [

Row(
children: [

CircleAvatar(
backgroundColor:
leave.status == "Approved"
? Colors.green.shade100
: leave.status == "Rejected"
? Colors.red.shade100
: Colors.orange.shade100,
child: Icon(
Icons.event_note,
color: leave.status == "Approved"
? Colors.green
: leave.status == "Rejected"
? Colors.red
: Colors.orange,
),
),

const SizedBox(width: 15),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [

Text(
leave.leaveType,
style: const TextStyle(
fontSize: 17,
fontWeight:
FontWeight.bold,
),
),

const SizedBox(height: 5),

Text(
"${leave.startDate.day}/${leave.startDate.month}/${leave.startDate.year}"
"  →  "
"${leave.endDate.day}/${leave.endDate.month}/${leave.endDate.year}",
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
decoration: BoxDecoration(
color: leave.status ==
"Approved"
? Colors.green
: leave.status ==
"Rejected"
? Colors.red
: Colors.orange,
borderRadius:
BorderRadius.circular(
20,
),
),
child: Text(
leave.status,
style: const TextStyle(
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

const Icon(
Icons.timelapse,
color: Colors.blue,
),

const SizedBox(width: 8),

Text(
"${leave.totalDays} Day(s)",
style: const TextStyle(
fontWeight:
FontWeight.bold,
),
),
],
),

const SizedBox(height: 12),

const Text(
"Reason",
style: TextStyle(
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 6),

Text(
leave.reason,
style: TextStyle(
color: Colors.grey.shade700,
height: 1.4,
),
),
],
),
),
);
},
).toList(),
);
},
),
],
),
),
),
],
),
);
}
}