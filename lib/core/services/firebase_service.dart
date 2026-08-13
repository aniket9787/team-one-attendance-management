
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
FirebaseService._();

static final FirebaseService instance =
FirebaseService._();

final FirebaseAuth auth =
FirebaseAuth.instance;

final FirebaseFirestore firestore =
FirebaseFirestore.instance;

User? get currentUser =>
auth.currentUser;

String? get currentUserId =>
auth.currentUser?.uid;

CollectionReference<Map<String, dynamic>>
get employees =>
firestore.collection(
'employees',
);

CollectionReference<Map<String, dynamic>>
get directChats =>
firestore.collection(
'direct_chats',
);

Future<DocumentSnapshot<Map<String, dynamic>>>
getEmployee(
String uid,
) {
return employees.doc(uid).get();
}

Future<void> updateEmployee(
String uid,
Map<String, dynamic> data,
) {
return employees
    .doc(uid)
    .update(data);
}

Stream<DocumentSnapshot<
Map<String, dynamic>>> employeeStream(
String uid,
) {
return employees
    .doc(uid)
    .snapshots();
}

Future<void> setOnlineStatus(
bool isOnline,
) async {
if (currentUserId == null) return;

await employees
    .doc(currentUserId)
    .update({
'isOnline': isOnline,
'lastSeen':
FieldValue.serverTimestamp(),
});
}

Future<void> updateLastSeen()
async {
if (currentUserId == null) return;

await employees
    .doc(currentUserId)
    .update({
'lastSeen':
FieldValue.serverTimestamp(),
});
}
}
