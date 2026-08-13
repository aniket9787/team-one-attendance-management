import 'package:flutter/material.dart';

import '../data/leave_service.dart';
import '../domain/leave_model.dart';

class LeaveManagementPage extends StatefulWidget {
  const LeaveManagementPage({super.key});

  @override
  State<LeaveManagementPage> createState() =>
      _LeaveManagementPageState();
}

class _LeaveManagementPageState
    extends State<LeaveManagementPage> {
final LeaveService leaveService =
LeaveService();

final TextEditingController searchController =
TextEditingController();

String selectedFilter = "All";

final List<String> filters = [
"All",
"Pending",
"Approved",
"Rejected",
];

@override
void dispose() {
searchController.dispose();
super.dispose();
}

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: const Color(0xffF5F7FA),

appBar: AppBar(
centerTitle: true,
elevation: 0,
title: const Text(
"Leave Management",
),
),

body: Column(
children: [

//==================================
// SUMMARY CARDS
//==================================

Padding(
padding: const EdgeInsets.all(16),
child: Row(
children: [

Expanded(
child: _summaryCard(
"Pending",
Icons.timelapse,
Colors.orange,
),
),

const SizedBox(width: 10),

Expanded(
child: _summaryCard(
"Approved",
Icons.check_circle,
Colors.green,
),
),

const SizedBox(width: 10),

Expanded(
child: _summaryCard(
"Rejected",
Icons.cancel,
Colors.red,
),
),
],
),
),

//==================================
// SEARCH
//==================================

Padding(
padding: const EdgeInsets.symmetric(
horizontal: 16,
),
child: TextField(
controller: searchController,

decoration: InputDecoration(
hintText: "Search Employee",

prefixIcon: const Icon(
Icons.search,
),

filled: true,

fillColor: Colors.white,

border: OutlineInputBorder(
borderRadius:
BorderRadius.circular(
14,
),
borderSide: BorderSide.none,
),
),

onChanged: (_) {
setState(() {});
},
),
),

const SizedBox(height: 15),

//==================================
// FILTERS
//==================================

SizedBox(
height: 45,

child: ListView.builder(
scrollDirection: Axis.horizontal,

itemCount: filters.length,

itemBuilder:
(context, index) {

final filter =
filters[index];

return Padding(
padding:
const EdgeInsets.only(
left: 12,
),
child: ChoiceChip(
label: Text(filter),

selected:
selectedFilter ==
filter,

onSelected: (_) {
setState(() {
selectedFilter =
filter;
});
},
),
);
},
),
),

const SizedBox(height: 15),

//==================================
// LEAVE LIST
//==================================

Expanded(
child: StreamBuilder<
List<LeaveModel>>(
stream:
leaveService.leaveStream(),

builder:
(context, snapshot) {

if (snapshot.connectionState ==
ConnectionState.waiting) {
return const Center(
child:
CircularProgressIndicator(),
);
}

if (!snapshot.hasData ||
snapshot.data!.isEmpty) {
return const Center(
child: Text(
"No Leave Requests",
),
);
}

List<LeaveModel> leaves =
snapshot.data!;

// SEARCH

if (searchController
.text
.isNotEmpty) {

leaves = leaves.where(
(leave) {

return leave
.employeeName
.toLowerCase()
.contains(
searchController
.text
.toLowerCase(),
);

},
).toList();
}

// FILTER

if (selectedFilter != "All") {

leaves = leaves.where(
(leave) {

return leave.status ==
selectedFilter;

},
).toList();
}

return ListView.builder(
padding:
const EdgeInsets.all(
15,
),

itemCount:
leaves.length,

itemBuilder:
(context, index) {

final leave =
leaves[index];

// PART 2 STARTS HERE


return Card(
elevation: 4,
margin: const EdgeInsets.only(
bottom: 15,
),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(
16,
),
),
child: Padding(
padding: const EdgeInsets.all(
16,
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [

//====================================
// EMPLOYEE DETAILS
//====================================

Row(
children: [

CircleAvatar(
radius: 26,
backgroundColor:
Colors.blue.shade100,
child: Text(
leave.employeeName
.isNotEmpty
? leave.employeeName[0]
.toUpperCase()
: "E",
style:
const TextStyle(
fontSize: 20,
fontWeight:
FontWeight.bold,
),
),
),

const SizedBox(width: 15),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment
.start,
children: [

Text(
leave.employeeName,
style:
const TextStyle(
fontSize: 18,
fontWeight:
FontWeight.bold,
),
),

const SizedBox(height: 5),

Text(
leave.employeeEmail,
style: TextStyle(
color: Colors
.grey.shade700,
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
color:
leave.status ==
"Approved"
? Colors.green
: leave.status ==
"Rejected"
? Colors.red
: Colors.orange,
borderRadius:
BorderRadius.circular(
25,
),
),
child: Text(
leave.status,
style:
const TextStyle(
color:
Colors.white,
fontWeight:
FontWeight.bold,
),
),
),
],
),

const Divider(height: 30),

//====================================
// LEAVE TYPE
//====================================

Row(
children: [

const Icon(
Icons.category,
color: Colors.blue,
),

const SizedBox(width: 8),

Text(
leave.leaveType,
style:
const TextStyle(
fontWeight:
FontWeight.bold,
fontSize: 15,
),
),
],
),

const SizedBox(height: 15),

//====================================
// START & END DATE
//====================================

Row(
children: [

Expanded(
child: Row(
children: [

const Icon(
Icons.calendar_today,
size: 18,
),

const SizedBox(width: 6),

Expanded(
child: Text(
"${leave.startDate.day}/${leave.startDate.month}/${leave.startDate.year}",
),
),
],
),
),

Expanded(
child: Row(
children: [

const Icon(
Icons.event,
size: 18,
),

const SizedBox(width: 6),

Expanded(
child: Text(
"${leave.endDate.day}/${leave.endDate.month}/${leave.endDate.year}",
),
),
],
),
),
],
),

const SizedBox(height: 15),

//====================================
// TOTAL DAYS
//====================================

Row(
children: [

const Icon(
Icons.timelapse,
color: Colors.green,
),

const SizedBox(width: 8),

Text(
"${leave.totalDays} Day(s)",
style:
const TextStyle(
fontWeight:
FontWeight.bold,
),
),
],
),

const SizedBox(height: 15),

//====================================
// REASON
//====================================

const Text(
"Reason",
style: TextStyle(
fontWeight:
FontWeight.bold,
),
),

const SizedBox(height: 6),

Text(
leave.reason,
style: TextStyle(
color:
Colors.grey.shade700,
height: 1.4,
),
),

const SizedBox(height: 20),

// PART 3 STARTS HERE


  //====================================
  // ACTION BUTTONS
  //====================================

  Row(
    children: [

      if (leave.status == "Pending")
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            onPressed: () async {
              await leaveService.approveLeave(
                leave.id,
                "Admin",
              );

              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Leave Approved Successfully",
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.check,
              color: Colors.white,
            ),
            label: const Text(
              "Approve",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),

      if (leave.status == "Pending")
        const SizedBox(width: 10),

      if (leave.status == "Pending")
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              await leaveService.rejectLeave(
                leave.id,
                "Admin",
              );

              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Leave Rejected Successfully",
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.close,
              color: Colors.white,
            ),
            label: const Text(
              "Reject",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),

      if (leave.status != "Pending")
        Expanded(
          child: ElevatedButton.icon(
            onPressed: null,
            icon: const Icon(
              Icons.done,
            ),
            label: Text(
              leave.status,
            ),
          ),
        ),
    ],
  ),

  const SizedBox(height: 10),

  SizedBox(
    width: double.infinity,
    child: OutlinedButton.icon(
      icon: const Icon(
        Icons.delete,
        color: Colors.red,
      ),
      label: const Text(
        "Delete Request",
        style: TextStyle(
          color: Colors.red,
        ),
      ),
      onPressed: () async {

        final confirm =
        await showDialog<bool>(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: const Text(
                "Delete Leave",
              ),
              content: const Text(
                "Are you sure you want to delete this leave request?",
              ),
              actions: [

                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      false,
                    );
                  },
                  child: const Text(
                    "Cancel",
                  ),
                ),

                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      true,
                    );
                  },
                  child: const Text(
                    "Delete",
                  ),
                ),
              ],
            );
          },
        );

        if (confirm == true) {

          await leaveService.deleteLeave(
            leave.id,
          );

          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Leave Deleted",
              ),
            ),
          );
        }
      },
    ),
  ),
],
),
),
);
},
);
},
),
),
],
),
);
}

Widget _summaryCard(
    String title,
    IconData icon,
    Color color,
    ) {
  return Container(
    height: 90,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(
        15,
      ),
    ),
    child: Column(
      mainAxisAlignment:
      MainAxisAlignment.center,
      children: [

        Icon(
          icon,
          color: Colors.white,
        ),

        const SizedBox(height: 8),

        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}
}