
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/employee_model.dart';

class EmployeeService {
final FirebaseFirestore _firestore =
FirebaseFirestore.instance;

CollectionReference<Map<String, dynamic>>
get _employees =>
_firestore.collection(
'employees',
);

// ==========================
// GET ALL EMPLOYEES
// ==========================

Stream<List<EmployeeModel>>
getEmployees() {
return _employees
    .orderBy(
'createdAt',
descending: true,
)
    .snapshots()
    .map(
(snapshot) =>
snapshot.docs
    .map(
(doc) =>
EmployeeModel
    .fromDocument(
doc,
),
)
    .toList(),
);
}

// ==========================
// GET EMPLOYEE BY ID
// ==========================

Future<EmployeeModel?>
getEmployeeById(
String uid,
) async {
final doc =
await _employees
    .doc(uid)
    .get();

if (!doc.exists) {
return null;
}

return EmployeeModel
    .fromDocument(doc);
}

// ==========================
// EMPLOYEE STREAM
// ==========================

Stream<EmployeeModel?>
employeeStream(
String uid,
) {
return _employees
    .doc(uid)
    .snapshots()
    .map(
(doc) {
if (!doc.exists) {
return null;
}

return EmployeeModel
    .fromDocument(doc);
},
);
}

// ==========================
// UPDATE PROFILE IMAGE
// ==========================

Future<void>
updateProfileImage({
required String uid,
required String imageUrl,
}) async {
await _employees
    .doc(uid)
    .update({
'profileImage': imageUrl,
});
}

// ==========================
// UPDATE ROLE
// ==========================

Future<void> updateRole({
required String uid,
required String role,
}) async {
await _employees
    .doc(uid)
    .update({
'role': role,
});
}

// ==========================
// UPDATE ACTIVE STATUS
// ==========================

Future<void>
updateActiveStatus({
required String uid,
required bool isActive,
}) async {
await _employees
    .doc(uid)
    .update({
'isActive': isActive,
});
}

// ==========================
// UPDATE ONLINE STATUS
// ==========================

Future<void>
updateOnlineStatus({
required String uid,
required bool isOnline,
}) async {
await _employees
    .doc(uid)
    .update({
'isOnline': isOnline,
'lastSeen':
FieldValue.serverTimestamp(),
});
}

// ==========================
// UPDATE LAST SEEN
// ==========================

Future<void> updateLastSeen(
String uid,
) async {
await _employees
    .doc(uid)
    .update({
'lastSeen':
FieldValue.serverTimestamp(),
});
}

// ==========================
// SAVE FCM TOKEN
// ==========================

Future<void> saveFcmToken({
required String uid,
required String token,
}) async {
await _employees
    .doc(uid)
    .update({
'fcmToken': token,
});
}

// ==========================
// DELETE EMPLOYEE
// ==========================

Future<void> deleteEmployee(
String uid,
) async {
await _employees
    .doc(uid)
    .delete();
}

// ==========================
// SEARCH EMPLOYEES
// ==========================

Stream<List<EmployeeModel>>
searchEmployees(
String query,
) {
return _employees
    .snapshots()
    .map(
(snapshot) =>
snapshot.docs
    .map(
(doc) =>
EmployeeModel
    .fromDocument(
doc,
),
)
    .where(
(employee) =>
employee.name
    .toLowerCase()
    .contains(
query
    .toLowerCase(),
) ||
employee.email
    .toLowerCase()
    .contains(
query
    .toLowerCase(),
) ||
employee.role
    .toLowerCase()
    .contains(
query
    .toLowerCase(),
),
)
    .toList(),
);
}
}
