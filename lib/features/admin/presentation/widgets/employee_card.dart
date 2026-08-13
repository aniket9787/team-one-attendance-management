import 'package:flutter/material.dart';

class EmployeeCard extends StatelessWidget {
final Map<String, dynamic> employee;

final VoidCallback onAttendance;

final VoidCallback onEdit;

final VoidCallback onDeactivate;

const EmployeeCard({
super.key,
required this.employee,
required this.onAttendance,
required this.onEdit,
required this.onDeactivate,
});

String formatDate(dynamic timestamp) {
if (timestamp == null) {
return "--";
}

final date = timestamp.toDate();

return "${date.day}/${date.month}/${date.year}";
}

@override
Widget build(BuildContext context) {

final profileImage =
employee["profileImage"] ?? "";

final isActive =
employee["isActive"] ?? true;

final isOnline =
employee["isOnline"] ?? false;

final joiningDate =
formatDate(employee["createdAt"]);


return Card(

margin: const EdgeInsets.symmetric(
horizontal: 16,
vertical: 8,
),

elevation: 3,

shape: RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(18),
),

child: Padding(

padding:
const EdgeInsets.all(16),

child: Column(

crossAxisAlignment:
CrossAxisAlignment.start,

children: [

//------------------------------------
// HEADER
//------------------------------------

Row(

children: [

CircleAvatar(

radius: 34,

backgroundColor:
Colors.blue.shade100,

backgroundImage:
profileImage
.toString()
.isNotEmpty
? NetworkImage(
profileImage,
)
: null,

child:
profileImage
.toString()
.isEmpty
? Text(

(employee["name"] ??
"E")
.toString()
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
CrossAxisAlignment.start,

children: [

Text(

employee["name"] ??
"",

style:
const TextStyle(

fontSize: 19,

fontWeight:
FontWeight.bold,

),

),

const SizedBox(height: 4),

Text(
"Employee ID : ${employee["employeeId"]}",
),

const SizedBox(height: 4),

Text(
employee["email"] ?? "",
),

],

),

),
Column(

children: [

Container(

padding:
const EdgeInsets.symmetric(
horizontal: 12,
vertical: 5,
),

decoration:
BoxDecoration(

color: isOnline
? Colors.green
: Colors.grey,

borderRadius:
BorderRadius.circular(20),

),

child: Text(

isOnline
? "Online"
: "Offline",

style:
const TextStyle(

color: Colors.white,

fontWeight:
FontWeight.bold,

),

),

),

const SizedBox(height: 8),

Container(

padding:
const EdgeInsets.symmetric(
horizontal: 12,
vertical: 5,
),

decoration:
BoxDecoration(

color: isActive
? Colors.green
: Colors.red,

borderRadius:
BorderRadius.circular(20),

),

child: Text(

isActive
? "Active"
: "Inactive",

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

],

),

const SizedBox(height: 18),

const Divider(),

const SizedBox(height: 10),

  //------------------------------------
  // EMPLOYEE DETAILS
  //------------------------------------

  _infoRow(
    Icons.business,
    "Department",
    employee["department"] ?? "N/A",
  ),

  _infoRow(
    Icons.work,
    "Role",
    employee["role"] ?? "N/A",
  ),

  _infoRow(
    Icons.phone,
    "Phone",
    employee["phone"] ?? "N/A",
  ),

  _infoRow(
    Icons.currency_rupee,
    "Monthly Salary",
    "₹${employee["monthlySalary"] ?? 0}",
  ),

  _infoRow(
    Icons.calendar_today,
    "Joining Date",
    joiningDate,
  ),

  const SizedBox(height: 20),

  //------------------------------------
  // ACTION BUTTONS
  //------------------------------------

  Row(

    children: [

      Expanded(

        child: ElevatedButton.icon(

          onPressed: onAttendance,

          icon: const Icon(
            Icons.bar_chart,
          ),

          label: const Text(
            "Attendance",
          ),

          style: ElevatedButton.styleFrom(

            backgroundColor:
            Colors.blue,

            foregroundColor:
            Colors.white,

          ),

        ),

      ),

      const SizedBox(width: 10),

      Expanded(

        child: ElevatedButton.icon(

          onPressed: onEdit,

          icon: const Icon(
            Icons.edit,
          ),

          label: const Text(
            "Edit",
          ),

          style: ElevatedButton.styleFrom(

            backgroundColor:
            Colors.orange,

            foregroundColor:
            Colors.white,

          ),

        ),

      ),

    ],

  ),

  const SizedBox(height: 10),

  SizedBox(

    width: double.infinity,

    child: OutlinedButton.icon(

      onPressed: onDeactivate,

      icon: const Icon(
        Icons.block,
        color: Colors.red,
      ),

      label: const Text(
        "Deactivate Employee",
        style: TextStyle(
          color: Colors.red,
        ),
      ),

    ),

  ),

],

),

),

);

}

//------------------------------------
// INFO ROW
//------------------------------------

Widget _infoRow(
    IconData icon,
    String title,
    String value,
    ) {

  return Padding(

    padding:
    const EdgeInsets.only(
      bottom: 10,
    ),

    child: Row(

      children: [

        Icon(
          icon,
          color: Colors.blue,
          size: 20,
        ),

        const SizedBox(width: 10),

        SizedBox(

          width: 120,

          child: Text(

            title,

            style: const TextStyle(

              fontWeight:
              FontWeight.bold,

            ),

          ),

        ),

        Expanded(
          child: Text(value),
        ),

      ],

    ),

  );

}

}





