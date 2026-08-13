import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/employee_service.dart';
import '../../models/employee_model.dart';


import '../widgets/add_employee_dialog.dart';
import '../widgets/edit_employee_dialog.dart';
import '../widgets/employee_card.dart';
import '../widgets/employee_search_bar.dart';
import '../widgets/employee_summary_card.dart';

class EmployeesManagementPage extends StatefulWidget {
  const EmployeesManagementPage({
    super.key,
  });

  @override
  State<EmployeesManagementPage> createState() =>
      _EmployeesManagementPageState();
}

class _EmployeesManagementPageState
    extends State<EmployeesManagementPage> {

//-----------------------------------------
// Services
//-----------------------------------------

final EmployeeService _employeeService =
EmployeeService.instance;

//-----------------------------------------
// Search
//-----------------------------------------

final TextEditingController
searchController =
TextEditingController();

//-----------------------------------------
// Employee Data
//-----------------------------------------

List<EmployeeModel> employees = [];

List<EmployeeModel> filteredEmployees = [];

//-----------------------------------------
// Loading
//-----------------------------------------

bool loading = true;

//-----------------------------------------
// Summary
//-----------------------------------------

int totalEmployees = 0;

int activeEmployees = 0;

int inactiveEmployees = 0;

//-----------------------------------------
// Stream
//-----------------------------------------

StreamSubscription<
List<EmployeeModel>>? employeeSubscription;


@override
void initState() {
super.initState();

loadEmployees();
}


@override
void dispose() {

employeeSubscription?.cancel();

searchController.dispose();

super.dispose();

}


//-----------------------------------------
// Load Employees
//-----------------------------------------

void loadEmployees() {

employeeSubscription?.cancel();

employeeSubscription =
_employeeService
.getEmployees()
.listen((data) {

employees = data;

filterEmployees();

});

}


//-----------------------------------------
// Search Employees
//-----------------------------------------

void filterEmployees() {

final query =
searchController.text
.trim()
.toLowerCase();

if (query.isEmpty) {

filteredEmployees =
List.from(employees);

} else {

filteredEmployees =
employees.where((employee) {

return employee.name
.toLowerCase()
.contains(query) ||

employee.email
.toLowerCase()
.contains(query) ||

employee.employeeId
.toLowerCase()
.contains(query) ||

employee.phone
.toLowerCase()
.contains(query) ||

employee.department
.toLowerCase()
.contains(query) ||

employee.role
.toLowerCase()
.contains(query);

}).toList();

}

totalEmployees =
filteredEmployees.length;

activeEmployees =
filteredEmployees
.where(
(e) => e.isActive,
)
.length;

inactiveEmployees =
filteredEmployees
.where(
(e) => !e.isActive,
)
.length;

if (mounted) {

setState(() {
loading = false;
});

}

}


@override
Widget build(BuildContext context) {

return Scaffold(

backgroundColor:
const Color(0xFFF5F7FA),

appBar: AppBar(

title: const Text(
"Employees Management",
),

centerTitle: true,

actions: [

IconButton(

icon: const Icon(
Icons.refresh,
),

onPressed: loadEmployees,

),

],

),

floatingActionButton:
FloatingActionButton.extended(

onPressed: () async {

await showDialog(

context: context,

builder: (_) =>
const AddEmployeeDialog(),

);

},

icon: const Icon(
Icons.person_add,
),

label: const Text(
"Add Employee",
),

),

body: loading

? const Center(
child:
CircularProgressIndicator(),
)

: Padding(

padding:
const EdgeInsets.all(16),

child: Column(

children: [


EmployeeSearchBar(

controller:
searchController,

onChanged: (value) {

filterEmployees();

},

onClear: () {

searchController.clear();

filterEmployees();

},

),

const SizedBox(height: 20),

Row(

children: [

Expanded(

child:
EmployeeSummaryCard(

title:
"Employees",

value:
totalEmployees
.toString(),

icon:
Icons.people,

color:
Colors.blue,

),

),

const SizedBox(width: 10),

Expanded(

child:
EmployeeSummaryCard(

title:
"Active",

value:
activeEmployees
.toString(),

icon: Icons
.check_circle,

color:
Colors.green,

),

),

const SizedBox(width: 10),

Expanded(

child:
EmployeeSummaryCard(

title:
"Inactive",

value:
inactiveEmployees
.toString(),

icon:
Icons.cancel,

color:
Colors.red,

),

),

],

),

const SizedBox(height: 20),


Expanded(

child: filteredEmployees.isEmpty

? const Center(

child: Text(

"No Employees Found",

style: TextStyle(
fontSize: 18,
),

),

)

: ListView.builder(

itemCount:
filteredEmployees.length,

itemBuilder:
(context, index) {

final employee =
filteredEmployees[index];

return EmployeeCard(

employee: {

"employeeId":
employee.employeeId,

"name":
employee.name,

"email":
employee.email,

"phone":
employee.phone,

"department":
employee.department,

"role":
employee.role,

"monthlySalary":
employee.monthlySalary,

"profileImage":
employee.profileImage,

"isActive":
employee.isActive,

"isOnline":
employee.isOnline,

"createdAt":
employee.createdAt,

},

onAttendance: () {

ScaffoldMessenger.of(
context,
).showSnackBar(

SnackBar(

content: Text(
"Attendance for ${employee.name}",
),

),

);

},


onEdit: () async {

await showDialog(

context: context,

builder: (_) {

return EditEmployeeDialog(

employeeId:
employee.employeeId,

employee: {

"employeeId":
employee.employeeId,

"uid":
employee.uid,

"name":
employee.name,

"email":
employee.email,

"phone":
employee.phone,

"department":
employee.department,

"role":
employee.role,

"monthlySalary":
employee.monthlySalary,

"profileImage":
employee.profileImage,

"isActive":
employee.isActive,

"isOnline":
employee.isOnline,

"joiningDate":
employee.joiningDate,

"createdAt":
employee.createdAt,

},

);

},

);

},


onDeactivate: () async {

if (employee.isActive) {

await _employeeService
.deactivateEmployee(
employee.employeeId,
);

} else {

await _employeeService
.activateEmployee(
employee.employeeId,
);

}

},

);

},

),

),


],

),

),

);

}

}