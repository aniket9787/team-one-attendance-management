import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../data/excel_export_service.dart';
import '../../data/payroll_service.dart';
import '../../data/pdf_export_service.dart';
import '../../domain/payroll_model.dart';

class PayslipManagementPage extends StatefulWidget {
  const PayslipManagementPage({super.key});

  @override
  State<PayslipManagementPage> createState() =>
      _PayslipManagementPageState();
}

class _PayslipManagementPageState
    extends State<PayslipManagementPage> {

final FirebaseFirestore _firestore =
FirebaseFirestore.instance;

final PayrollService _payrollService =
PayrollService();

bool loading = true;

int selectedMonth =
DateTime.now().month;

int selectedYear =
DateTime.now().year;

final TextEditingController
searchController =
TextEditingController();

String searchText = "";

List<PayrollModel> payroll = [];

List<PayrollModel> filteredPayroll =
[];

final Map<String,
TextEditingController>
salaryControllers = {};

static const List<String> months = [

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

@override
void initState() {
super.initState();

loadPayroll();

searchController.addListener(() {

searchText =
searchController.text
.trim()
.toLowerCase();

filterEmployees();
});
}

Future<void> loadPayroll() async {

setState(() {
loading = true;
});


for (final employee in payroll) {

salaryControllers[employee.employeeId] =
TextEditingController(
text: employee.monthlySalary
.toStringAsFixed(0),
);
}

filterEmployees();

if (!mounted) return;

setState(() {
loading = false;
});
}

//----------------------------------------------------
// SEARCH
//----------------------------------------------------

void filterEmployees() {

if (searchText.isEmpty) {

filteredPayroll =
List.from(payroll);

} else {

filteredPayroll =
payroll.where((employee) {

return employee.employeeName
.toLowerCase()
.contains(searchText) ||

employee.role
.toLowerCase()
.contains(searchText);

}).toList();
}

if (mounted) {
setState(() {});
}
}

//----------------------------------------------------
// UPDATE SALARY
//----------------------------------------------------

Future<void> updateSalary(
PayrollModel employee) async {

final salary =
double.tryParse(
salaryControllers[
employee.employeeId]
?.text ??
"",
);

if (salary == null ||
salary <= 0) {

ScaffoldMessenger.of(context)
.showSnackBar(
const SnackBar(
content: Text(
"Please enter a valid monthly salary.",
),
),
);

return;
}

final confirm =
await showDialog<bool>(
context: context,
builder: (_) => AlertDialog(
title:
const Text("Update Salary"),
content: Text(
"Update salary for ${employee.employeeName}?",
),
actions: [

TextButton(
onPressed: () {
Navigator.pop(
context, false);
},
child: const Text(
"Cancel",
),
),

ElevatedButton(
onPressed: () {
Navigator.pop(
context, true);
},
child:
const Text("Update"),
),
],
),
);

if (confirm != true) return;

await _firestore
.collection("employees")
.doc(employee.employeeId)
.update({

"monthlySalary": salary,

});

await loadPayroll();

if (!mounted) return;

ScaffoldMessenger.of(context)
.showSnackBar(
SnackBar(
content: Text(
"${employee.employeeName}'s salary updated successfully.",
),
),
);
}

//----------------------------------------------------
// GENERATE PAYSLIP
//----------------------------------------------------

  Future<void> generatePayslip(
      PayrollModel employee,
      ) async {

    final documentId =
        "${selectedYear}_${selectedMonth}_${employee.employeeId}";

    // Check whether the payslip already exists
    final payslipDoc = await _firestore
        .collection("payslips")
        .doc(documentId)
        .get();

    if (payslipDoc.exists) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Payslip already generated for this month.",
          ),
        ),
      );
      return;
    }

    // Confirmation Dialog
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Generate Payslip",
          ),
          content: Text(
            "Generate payslip for ${employee.employeeName}?",
          ),
          actions: [

            TextButton(
              onPressed: () =>
                  Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(context, true),
              child: const Text("Generate"),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    final daysInMonth = DateTime(
      selectedYear,
      selectedMonth + 1,
      0,
    ).day;

    final perDaySalary =
        employee.monthlySalary / daysInMonth;

    final Map<String, dynamic> payslipData = {

      "employeeId": employee.employeeId,

      "employeeName": employee.employeeName,

      "role": employee.role,

      "month": selectedMonth,

      "year": selectedYear,

      "daysInMonth": daysInMonth,

      "monthlySalary": employee.monthlySalary,

      "perDaySalary": perDaySalary,

      "presentDays": employee.presentDays,

      "halfDays": employee.halfDays,

      "absentDays": employee.absentDays,

      "calculatedSalary":
      employee.calculatedSalary,

      "status": "Generated",

      "generatedAt":
      FieldValue.serverTimestamp(),
    };

    // Global Payslip Collection
    await _firestore
        .collection("payslips")
        .doc(documentId)
        .set(payslipData);

    // Employee Payslip History

await _firestore
.collection("employees")
.doc(employee.employeeId)
.collection("payslips")
.doc(documentId)
    .set(payslipData);

if (!mounted) return;

ScaffoldMessenger.of(context)
.showSnackBar(
SnackBar(
content: Text(
"Payslip generated for ${employee.employeeName}.",
),
),
);
}


  Widget _buildRow(
      String title,
      String value, {
        Color valueColor = Colors.black,
      }) {
    return Row(
      mainAxisAlignment:
      MainAxisAlignment.spaceBetween,
      children: [

        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),

        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

@override
void dispose() {



searchController.dispose();

for (final controller
in salaryControllers.values) {
controller.dispose();
}

super.dispose();
}

@override
Widget build(BuildContext context) {

return Scaffold(

backgroundColor: const Color(0xFFF5F7FA),

appBar: AppBar(
elevation: 0,
centerTitle: true,
title: const Text(
"Payroll Management",
style: TextStyle(
fontWeight: FontWeight.bold,
),
),
),

body: loading
? const Center(
child: CircularProgressIndicator(),
)
: Column(

children: [

//----------------------------------
// SEARCH
//----------------------------------

Padding(
padding:
const EdgeInsets.fromLTRB(
16,
16,
16,
8,
),

child: TextField(

controller:
searchController,

decoration:
InputDecoration(

hintText:
"Search employee...",

prefixIcon:
const Icon(
Icons.search,
),

filled: true,

fillColor:
Colors.white,

border:
OutlineInputBorder(

borderRadius:
BorderRadius.circular(
12,
),

borderSide:
BorderSide.none,
),
),
),
),

//----------------------------------
// MONTH + YEAR
//----------------------------------

Padding(

padding:
const EdgeInsets.symmetric(
horizontal: 16,
),

child: Row(

children: [

Expanded(

child:
DropdownButtonFormField<int>(

value:
selectedMonth,

decoration:
const InputDecoration(

labelText:
"Month",

border:
OutlineInputBorder(),
),

items:
List.generate(

12,

(index) {

return DropdownMenuItem(

value:
index + 1,

child: Text(
months[index],
),
);
},
),

onChanged:
(value) async {

if (value ==
null) return;

selectedMonth =
value;

await loadPayroll();
},
),
),

const SizedBox(
width: 15,
),

Expanded(

child:
TextFormField(

initialValue:
selectedYear
.toString(),

keyboardType:
TextInputType.number,

decoration:
const InputDecoration(

labelText:
"Year",

border:
OutlineInputBorder(),
),

onFieldSubmitted:
(value) async {

selectedYear =
int.tryParse(
value,
) ??
DateTime.now()
.year;

await loadPayroll();
},
),
),
],
),
),

const SizedBox(height: 15),

//----------------------------------
// EMPLOYEE LIST
//----------------------------------

Expanded(

child: filteredPayroll.isEmpty

? const Center(
child: Text(
"No Employees Found",
),
)

: ListView.builder(

padding:
const EdgeInsets.only(
bottom: 20,
),

itemCount:
filteredPayroll.length,

itemBuilder:
(context, index) {

final employee =
filteredPayroll[index];

final daysInMonth =
DateTime(
selectedYear,
selectedMonth + 1,
0,
).day;

final perDaySalary =
employee.monthlySalary /
daysInMonth;

return Card(

margin:
const EdgeInsets.symmetric(
horizontal: 16,
vertical: 10,
),

elevation: 3,

shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(
18,
),
),

child: Padding(

padding:
const EdgeInsets.all(
18,
),

child: Column(

crossAxisAlignment:
CrossAxisAlignment
.start,

children: [

CircleAvatar(
radius: 28,
backgroundColor:
Colors.blue.shade100,
child: Text(
employee.employeeName
.substring(0, 1)
.toUpperCase(),
style: const TextStyle(
fontWeight: FontWeight.bold,
fontSize: 22,
),
),
),

const SizedBox(height: 15),

Text(
employee.employeeName,
style: const TextStyle(
fontSize: 20,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 4),

Text(
employee.role,
style: TextStyle(
color: Colors.grey.shade600,
),
),

const SizedBox(height: 20),

TextField(
controller:
salaryControllers[
employee.employeeId],
keyboardType:
const TextInputType.numberWithOptions(
decimal: true,
),
decoration: InputDecoration(
labelText:
"Monthly Salary (₹)",
prefixIcon:
const Icon(
Icons.currency_rupee,
),
border:
OutlineInputBorder(
borderRadius:
BorderRadius.circular(
12,
),
),
),
),

const SizedBox(height: 15),

SizedBox(
width: double.infinity,
child:
ElevatedButton.icon(
icon: const Icon(
Icons.save,
),
label: const Text(
"Update Salary",
),
onPressed: () =>
updateSalary(
employee,
),
),
),

const SizedBox(height: 20),

Container(
padding:
const EdgeInsets.all(
15,
),
decoration:
BoxDecoration(
color:
Colors.grey.shade100,
borderRadius:
BorderRadius.circular(
12,
),
),
child: Column(
children: [

_buildRow(
"Present Days",
employee.presentDays
.toString(),
),

const Divider(),

_buildRow(
"Half Days",
employee.halfDays
.toString(),
),

const Divider(),

_buildRow(
"Absent Days",
employee.absentDays
.toString(),
),

const Divider(),

_buildRow(
"Per Day Salary",
"₹${perDaySalary.toStringAsFixed(2)}",
),

const Divider(),

_buildRow(
"Monthly Salary",
"₹${employee.monthlySalary.toStringAsFixed(2)}",
),

const Divider(),

_buildRow(
"Net Salary",
"₹${employee.calculatedSalary.toStringAsFixed(2)}",
valueColor:
Colors.green,
),
],
),
),

const SizedBox(height: 20),

  Row(
    children: [

      Expanded(
        child: ElevatedButton.icon(
          icon: const Icon(
            Icons.receipt_long,
          ),
          label: const Text(
            "Generate Payslip",
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(50),
          ),
          onPressed: () async {
            await generatePayslip(employee);
          },
        ),
      ),

    ],
  ),

  const SizedBox(height: 12),

  Row(
    children: [

      Expanded(
        child: OutlinedButton.icon(
          icon: const Icon(
            Icons.picture_as_pdf,
            color: Colors.red,
          ),
          label: const Text(
            "Export PDF",
          ),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
          ),
          onPressed: () async {

            await PdfExportService.generatePayrollPdf(
              employee,
              selectedMonth,
              selectedYear,
            );

            if (!mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "PDF exported for ${employee.employeeName}",
                ),
              ),
            );
          },
        ),
      ),

      const SizedBox(width: 10),

      Expanded(
        child: OutlinedButton.icon(
          icon: const Icon(
            Icons.table_chart,
            color: Colors.green,
          ),
          label: const Text(
            "Export Excel",
          ),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
          ),
          onPressed: () async {

            await ExcelExportService.exportPayroll(
              employee,
              selectedMonth,
              selectedYear,
            );

            if (!mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Excel exported for ${employee.employeeName}",
                ),
              ),
            );
          },
        ),
      ),

    ],
  ),

],
),
),
);
},
),
),
],
),
);
}
}