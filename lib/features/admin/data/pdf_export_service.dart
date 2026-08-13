import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../domain/payroll_model.dart';
import 'payroll_service.dart';

class PdfExportService {

static Future<void> generatePayrollPdf(
PayrollModel employee,
int month,
int year,
) async {

final pdf = pw.Document();

final daysInMonth =
DateTime(
year,
month + 1,
0,
).day;

final perDaySalary =
employee.monthlySalary /
daysInMonth;

pdf.addPage(

pw.MultiPage(

pageFormat:
PdfPageFormat.a4,

margin:
const pw.EdgeInsets.all(30),

build: (context) {

return [

//---------------------------------------------------
// COMPANY HEADER
//---------------------------------------------------

pw.Center(

child: pw.Column(

children: [

pw.Text(

"STALLION ONE",

style: pw.TextStyle(

fontSize: 28,

fontWeight:
pw.FontWeight.bold,

),
),

pw.SizedBox(height: 5),

pw.Text(

"Employee Payroll Payslip",

style: const pw.TextStyle(

fontSize: 16,

),
),

pw.SizedBox(height: 15),

pw.Divider(),
],
),
),

//---------------------------------------------------
// EMPLOYEE INFORMATION
//---------------------------------------------------

pw.SizedBox(height: 20),

pw.Text(

"Employee Information",

style: pw.TextStyle(

fontSize: 18,

fontWeight:
pw.FontWeight.bold,

),
),

pw.SizedBox(height: 12),

pw.Table(

border: pw.TableBorder.all(

color: PdfColors.grey400,

),

children: [

_tableRow(
"Employee Name",
employee.employeeName,
),

_tableRow(
"Employee ID",
employee.employeeId,
),

_tableRow(
"Role",
employee.role,
),

_tableRow(
"Month",
"$month / $year",
),
],
),

//---------------------------------------------------
// SALARY DETAILS
//---------------------------------------------------

pw.SizedBox(height: 25),

pw.Text(

"Salary Details",

style: pw.TextStyle(

fontSize: 18,

fontWeight:
pw.FontWeight.bold,

),
),

pw.SizedBox(height: 12),

pw.Table(

border: pw.TableBorder.all(

color: PdfColors.grey400,

),

children: [

_tableRow(
"Monthly Salary",
"₹ ${employee.monthlySalary.toStringAsFixed(2)}",
),

_tableRow(
"Per Day Salary",
"₹ ${perDaySalary.toStringAsFixed(2)}",
),

_tableRow(
"Present Days",
employee.presentDays.toString(),
),

_tableRow(
"Half Days",
employee.halfDays.toString(),
),

_tableRow(
"Absent Days",
employee.absentDays.toString(),
),

_tableRow(
"Calculated Salary",
"₹ ${employee.calculatedSalary.toStringAsFixed(2)}",
),
],
),

pw.SizedBox(height: 25),

pw.Container(

padding:
const pw.EdgeInsets.all(15),

decoration: pw.BoxDecoration(

color: PdfColors.green50,

borderRadius:
pw.BorderRadius.circular(8),

),

child: pw.Row(

mainAxisAlignment:
pw.MainAxisAlignment.spaceBetween,

children: [

pw.Text(

"Net Salary",

style: pw.TextStyle(

fontSize: 18,

fontWeight:
pw.FontWeight.bold,

),
),

pw.Text(

"₹ ${employee.calculatedSalary.toStringAsFixed(2)}",

style: pw.TextStyle(

color: PdfColors.green800,

fontSize: 20,

fontWeight:
pw.FontWeight.bold,

),
),
],
),
),

pw.SizedBox(height: 30),

  //---------------------------------------------------
  // FOOTER
  //---------------------------------------------------

  pw.Divider(),

  pw.SizedBox(height: 10),

  pw.Text(
    "Generated Date : ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
    style: const pw.TextStyle(
      fontSize: 12,
    ),
  ),

  pw.SizedBox(height: 5),

  pw.Text(
    "Generated Automatically by Stallion One HRMS",
    style: pw.TextStyle(
      fontSize: 11,
      color: PdfColors.grey700,
    ),
  ),

  pw.SizedBox(height: 25),

  pw.Center(
    child: pw.Text(
      "***** This is a computer generated payslip *****",
      style: pw.TextStyle(
        fontSize: 10,
        color: PdfColors.grey600,
      ),
    ),
  ),

];
},
),
);

//---------------------------------------------------
// SAVE PDF
//---------------------------------------------------

final directory =
await getApplicationDocumentsDirectory();

final file = File(
  "${directory.path}/Payroll_${employee.employeeName}_${month}_$year.pdf",
);

await file.writeAsBytes(
  await pdf.save(),
);

//---------------------------------------------------
// PRINT / SHARE PDF
//---------------------------------------------------

await Printing.sharePdf(
  bytes: await pdf.save(),
  filename:
  "Payroll_${employee.employeeName}_$month-$year.pdf",
);
}

//---------------------------------------------------
// TABLE ROW
//---------------------------------------------------

static pw.TableRow _tableRow(
    String title,
    String value,
    ) {
  return pw.TableRow(
    children: [

      pw.Padding(
        padding:
        const pw.EdgeInsets.all(10),
        child: pw.Text(
          title,
          style: pw.TextStyle(
            fontWeight:
            pw.FontWeight.bold,
          ),
        ),
      ),

      pw.Padding(
        padding:
        const pw.EdgeInsets.all(10),
        child: pw.Text(value),
      ),
    ],
  );
}
}