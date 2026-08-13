class PayrollModel {

final String employeeId;

final String employeeName;

final String role;

final int presentDays;

final int halfDays;

final int absentDays;

final double monthlySalary;

final double calculatedSalary;

final double deductions;

final double bonus;

const PayrollModel({

required this.employeeId,

required this.employeeName,

required this.role,

required this.presentDays,

required this.halfDays,

required this.absentDays,

required this.monthlySalary,

required this.calculatedSalary,

this.deductions = 0,

this.bonus = 0,

});


double get netSalary {

return calculatedSalary +

bonus -

deductions;

}

double get attendancePercentage {

final totalDays =

presentDays +

halfDays +

absentDays;

if (totalDays == 0) {

return 0;

}

return ((presentDays +

(halfDays * 0.5)) /

totalDays) *

100;

}

String get attendanceStatus {

if (attendancePercentage >= 90) {

return "Excellent";

}

if (attendancePercentage >= 75) {

return "Good";

}

if (attendancePercentage >= 50) {

return "Average";

}

return "Poor";

}



factory PayrollModel.fromMap(
Map<String, dynamic> map,
) {

return PayrollModel(

employeeId:
map["employeeId"] ?? "",

employeeName:
map["employeeName"] ?? "",

role:
map["role"] ?? "",

presentDays:
map["presentDays"] ?? 0,

halfDays:
map["halfDays"] ?? 0,

absentDays:
map["absentDays"] ?? 0,

monthlySalary:
(map["monthlySalary"] ?? 0)
.toDouble(),

calculatedSalary:
(map["calculatedSalary"] ?? 0)
.toDouble(),

deductions:
(map["deductions"] ?? 0)
.toDouble(),

bonus:
(map["bonus"] ?? 0)
.toDouble(),

);

}



Map<String, dynamic> toMap() {

return {

"employeeId": employeeId,

"employeeName": employeeName,

"role": role,

"presentDays": presentDays,

"halfDays": halfDays,

"absentDays": absentDays,

"monthlySalary": monthlySalary,

"calculatedSalary": calculatedSalary,

"deductions": deductions,

"bonus": bonus,

"netSalary": netSalary,

};

}



PayrollModel copyWith({

String? employeeId,

String? employeeName,

String? role,

int? presentDays,

int? halfDays,

int? absentDays,

double? monthlySalary,

double? calculatedSalary,

double? deductions,

double? bonus,

}) {

return PayrollModel(

employeeId:
employeeId ?? this.employeeId,

employeeName:
employeeName ?? this.employeeName,

role:
role ?? this.role,

presentDays:
presentDays ?? this.presentDays,

halfDays:
halfDays ?? this.halfDays,

absentDays:
absentDays ?? this.absentDays,

monthlySalary:
monthlySalary ?? this.monthlySalary,

calculatedSalary:
calculatedSalary ??
this.calculatedSalary,

deductions:
deductions ?? this.deductions,

bonus:
bonus ?? this.bonus,

);

}


factory PayrollModel.empty() {

  return const PayrollModel(

    employeeId: "",

    employeeName: "",

    role: "",

    presentDays: 0,

    halfDays: 0,

    absentDays: 0,

    monthlySalary: 0,

    calculatedSalary: 0,

    deductions: 0,

    bonus: 0,

  );

}

}

