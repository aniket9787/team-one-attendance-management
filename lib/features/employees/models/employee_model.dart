
import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeModel {
final String uid;
final String name;
final String email;
final String role;

final String profileImage;

final bool isActive;
final bool isOnline;

final String fcmToken;

final Timestamp? createdAt;
final Timestamp? lastSeen;

const EmployeeModel({
required this.uid,
required this.name,
required this.email,
required this.role,
required this.profileImage,
required this.isActive,
required this.isOnline,
required this.fcmToken,
this.createdAt,
this.lastSeen,
});

factory EmployeeModel.fromFirestore(
String id,
Map<String, dynamic> json,
) {
return EmployeeModel(
uid: json['uid'] ?? id,

name: json['name'] ?? '',

email: json['email'] ?? '',

role: json['role'] ?? 'Employee',

profileImage:
json['profileImage'] ?? '',

isActive:
json['isActive'] ?? true,

isOnline:
json['isOnline'] ?? false,

fcmToken:
json['fcmToken'] ?? '',

createdAt:
json['createdAt'],

lastSeen:
json['lastSeen'],
);
}

factory EmployeeModel.fromDocument(
DocumentSnapshot doc,
) {
final data =
doc.data() as Map<String, dynamic>;

return EmployeeModel.fromFirestore(
doc.id,
data,
);
}

Map<String, dynamic> toMap() {
return {
'uid': uid,
'name': name,
'email': email,
'role': role,
'profileImage': profileImage,
'isActive': isActive,
'isOnline': isOnline,
'fcmToken': fcmToken,
'createdAt': createdAt,
'lastSeen': lastSeen,
};
}

EmployeeModel copyWith({
String? uid,
String? name,
String? email,
String? role,
String? profileImage,
bool? isActive,
bool? isOnline,
String? fcmToken,
Timestamp? createdAt,
Timestamp? lastSeen,
}) {
return EmployeeModel(
uid: uid ?? this.uid,
name: name ?? this.name,
email: email ?? this.email,
role: role ?? this.role,
profileImage:
profileImage ??
this.profileImage,
isActive:
isActive ?? this.isActive,
isOnline:
isOnline ?? this.isOnline,
fcmToken:
fcmToken ?? this.fcmToken,
createdAt:
createdAt ?? this.createdAt,
lastSeen:
lastSeen ?? this.lastSeen,
);
}

String get initials {
if (name.isEmpty) {
return 'E';
}

final words =
name.trim().split(' ');

if (words.length == 1) {
return words.first[0]
    .toUpperCase();
}

return '${words.first[0]}${words.last[0]}'
    .toUpperCase();
}

bool get hasProfileImage =>
profileImage.isNotEmpty;

@override
String toString() {
return '''
EmployeeModel(
  uid: $uid,
  name: $name,
  email: $email,
  role: $role,
  isOnline: $isOnline
)
''';
}
}
