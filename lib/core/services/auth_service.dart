import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'google_sheet_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<UserCredential> signUp({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {


    final credential =
    await _auth.createUserWithEmailAndPassword(
    email: email,
    password: password,
    );

    final user = credential.user;

    if (user != null) {

    await _firestore
        .collection('employees')
        .doc(user.uid)
        .set({
    'uid': user.uid,
    'name': name,
    'email': email,
    'role': role,
    'isActive': true,
    'profileImage': '',
    'createdAt':
    FieldValue.serverTimestamp(),
    });

    final result =
    await GoogleSheetService.addEmployee(
    name: name,
    email: email,
    role: role,
    );

    debugPrint(
    'Google Sheet Employee Sync: $result',
    );
    }

    return credential;


  }

  Future<UserCredential> login({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential?> signInWithGoogle() async {


    try {

    if (kIsWeb) {

    final provider = GoogleAuthProvider();

    provider.setCustomParameters({
    'prompt': 'select_account',
    });

    final credential =
    await _auth.signInWithPopup(
    provider,
    );

    await _saveGoogleUser(
    credential.user,
    );

    return credential;
    }

    final googleUser =
    await GoogleSignIn().signIn();

    if (googleUser == null) {
    return null;
    }

    final googleAuth =
    await googleUser.authentication;

    final credential =
    GoogleAuthProvider.credential(
    accessToken:
    googleAuth.accessToken,
    idToken:
    googleAuth.idToken,
    );

    final userCredential =
    await _auth.signInWithCredential(
    credential,
    );

    await _saveGoogleUser(
    userCredential.user,
    );

    return userCredential;

    } catch (e) {
    throw Exception(
    'Google Sign In Failed: $e',
    );
    }


  }

  Future<void> _saveGoogleUser(
      User? user) async {

    if (user == null) return;

    final doc = await _firestore
        .collection('employees')
        .doc(user.uid)
        .get();

    if (!doc.exists) {

    await _firestore
        .collection('employees')
        .doc(user.uid)
        .set({
    'uid': user.uid,
    'name':
    user.displayName ?? '',
    'email':
    user.email ?? '',
    'role': 'Employee',
    'isActive': true,
    'profileImage':
    user.photoURL ?? '',
    'createdAt':
    FieldValue.serverTimestamp(),
    });

    await GoogleSheetService
        .addEmployee(
    name:
    user.displayName ?? '',
    email:
    user.email ?? '',
    role: 'Employee',
    );
    }


  }

  User? get currentUser =>
      _auth.currentUser;

  Future<void> logout() async {


    try {
    if (!kIsWeb) {
    await GoogleSignIn().signOut();
    }
    } catch (_) {}

    await _auth.signOut();


  }
}
