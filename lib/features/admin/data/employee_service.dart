import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/employee_model.dart';

class EmployeeService {

EmployeeService._();

static final EmployeeService instance =
EmployeeService._();

final FirebaseFirestore _firestore =
FirebaseFirestore.instance;

CollectionReference<Map<String, dynamic>>
get employeesCollection {

return _firestore.collection(
"employees",
);

}

DocumentReference<Map<String, dynamic>>
employeeDoc(
String employeeId,
) {

return employeesCollection.doc(
employeeId,
);

}

//---------------------------------------
// Get All Employees
//---------------------------------------

Stream<List<EmployeeModel>>
getEmployees() {

return employeesCollection

.orderBy(
"createdAt",
descending: true,
)

.snapshots()

.map((snapshot) {

return snapshot.docs.map((doc) {

return EmployeeModel.fromMap(
doc.data(),
);

}).toList();

});

}

//---------------------------------------
// Add Employee
//---------------------------------------

Future<void> addEmployee(
EmployeeModel employee,
) async {

final data =
employee.toMap();

data["joiningDate"] =
FieldValue.serverTimestamp();

data["createdAt"] =
FieldValue.serverTimestamp();

data["updatedAt"] =
FieldValue.serverTimestamp();

await employeeDoc(
employee.employeeId,
).set(data);

}

//---------------------------------------
// Update Employee
//---------------------------------------

Future<void> updateEmployee(
EmployeeModel employee,
) async {

final data =
employee.toMap();

data["updatedAt"] =
FieldValue.serverTimestamp();

await employeeDoc(
employee.employeeId,
).update(data);

}


//---------------------------------------
// Activate Employee
//---------------------------------------

Future<void> activateEmployee(
String employeeId,
) async {

await employeeDoc(
employeeId,
).update({

"isActive": true,

"updatedAt":
FieldValue.serverTimestamp(),

});

}

//---------------------------------------
// Deactivate Employee
//---------------------------------------

Future<void> deactivateEmployee(
String employeeId,
) async {

await employeeDoc(
employeeId,
).update({

"isActive": false,

"updatedAt":
FieldValue.serverTimestamp(),

});

}

//---------------------------------------
// Delete Employee
//---------------------------------------

Future<void> deleteEmployee(
String employeeId,
) async {

await employeeDoc(
employeeId,
).delete();

}

//---------------------------------------
// Get Employee By ID
//---------------------------------------

Future<EmployeeModel?> getEmployee(
String employeeId,
) async {

final document =
await employeeDoc(
employeeId,
).get();

if (!document.exists) {
return null;
}

return EmployeeModel.fromMap(
document.data()!,
);

}

//---------------------------------------
// Get Employees Once
//---------------------------------------

  Future<List<EmployeeModel>> getEmployeesOnce() async {

    final snapshot = await employeesCollection
        .orderBy(
      "createdAt",
      descending: true,
    )
        .get();

    return snapshot.docs
        .map(
          (doc) => EmployeeModel.fromMap(
        doc.data(),
      ),
    )
        .toList();
  }

//---------------------------------------
// Check Employee Exists
//---------------------------------------

Future<bool> employeeExists(
String employeeId,
) async {

final document =
await employeeDoc(
employeeId,
).get();

return document.exists;

}


}