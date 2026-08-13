import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/payroll_model.dart';

class PayrollService {

PayrollService();

final FirebaseFirestore _firestore =
FirebaseFirestore.instance;

//-----------------------------------------
// Payroll Collection
//-----------------------------------------

CollectionReference<Map<String, dynamic>>
get payrollCollection {

return _firestore.collection(
"payroll",
);

}

//-----------------------------------------
// Payroll Document
//-----------------------------------------

DocumentReference<Map<String, dynamic>>
payrollDoc(
String employeeId,
) {

return payrollCollection.doc(
employeeId,
);

}


//-----------------------------------------
// Get All Payroll
//-----------------------------------------

Stream<List<PayrollModel>>
getPayroll() {

return payrollCollection

.snapshots()

.map((snapshot) {

return snapshot.docs.map((doc) {

return PayrollModel.fromMap(
doc.data(),
);

}).toList();

});

}


//-----------------------------------------
// Add Payroll
//-----------------------------------------

Future<void> addPayroll(
PayrollModel payroll,
) async {

await payrollDoc(
payroll.employeeId,
).set(
payroll.toMap(),
);

}


//-----------------------------------------
// Update Payroll
//-----------------------------------------

Future<void> updatePayroll(
PayrollModel payroll,
) async {

await payrollDoc(
payroll.employeeId,
).update(
payroll.toMap(),
);

}


//-----------------------------------------
// Delete Payroll
//-----------------------------------------

Future<void> deletePayroll(
String employeeId,
) async {

await payrollDoc(
employeeId,
).delete();

}


//-----------------------------------------
// Get Payroll By Employee
//-----------------------------------------

Future<PayrollModel?> getPayrollByEmployee(
String employeeId,
) async {

final document =
await payrollDoc(
employeeId,
).get();

if (!document.exists) {

return null;

}

return PayrollModel.fromMap(
document.data()!,
);

}



//-----------------------------------------
// Check Payroll Exists
//-----------------------------------------

Future<bool> payrollExists(
String employeeId,
) async {

final document =
await payrollDoc(
employeeId,
).get();

return document.exists;

}


}