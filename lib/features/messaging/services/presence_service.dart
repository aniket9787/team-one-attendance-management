
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

class PresenceService with WidgetsBindingObserver {
PresenceService._();

static final PresenceService instance =
PresenceService._();

final FirebaseFirestore _firestore =
FirebaseFirestore.instance;

final FirebaseAuth _auth =
FirebaseAuth.instance;

StreamSubscription<User?>? _authSubscription;

bool _initialized = false;

// ==========================
// INITIALIZE
// ==========================

Future<void> initialize() async {
if (_initialized) return;

_initialized = true;

WidgetsBinding.instance.addObserver(this);

_authSubscription =
_auth.authStateChanges().listen(
(user) async {
if (user == null) return;

await setOnline();
},
);
}

// ==========================
// CURRENT USER
// ==========================

String? get currentUserId =>
_auth.currentUser?.uid;

DocumentReference<Map<String, dynamic>>
get _employeeRef {
return _firestore
    .collection('employees')
    .doc(currentUserId);
}

// ==========================
// ONLINE
// ==========================

Future<void> setOnline() async {
if (currentUserId == null) return;

await _employeeRef.set({
'isOnline': true,
'lastSeen':
FieldValue.serverTimestamp(),
}, SetOptions(merge: true));
}

// ==========================
// OFFLINE
// ==========================

Future<void> setOffline() async {
if (currentUserId == null) return;

await _employeeRef.set({
'isOnline': false,
'lastSeen':
FieldValue.serverTimestamp(),
}, SetOptions(merge: true));
}

// ==========================
// UPDATE LAST SEEN
// ==========================

Future<void> updateLastSeen() async {
if (currentUserId == null) return;

await _employeeRef.update({
'lastSeen':
FieldValue.serverTimestamp(),
});
}

// ==========================
// APP LIFECYCLE
// ==========================

@override
void didChangeAppLifecycleState(
AppLifecycleState state,
) {
switch (state) {
case AppLifecycleState.resumed:
setOnline();
break;

case AppLifecycleState.inactive:
updateLastSeen();
break;

case AppLifecycleState.paused:
setOffline();
break;

case AppLifecycleState.detached:
setOffline();
break;

case AppLifecycleState.hidden:
setOffline();
break;
}
}

// ==========================
// USER STREAM
// ==========================

Stream<DocumentSnapshot<Map<String, dynamic>>>
userPresenceStream(
String uid,
) {
return _firestore
    .collection('employees')
    .doc(uid)
    .snapshots();
}

// ==========================
// DISPOSE
// ==========================

Future<void> dispose() async {
WidgetsBinding.instance
    .removeObserver(this);

await _authSubscription?.cancel();
}
}
