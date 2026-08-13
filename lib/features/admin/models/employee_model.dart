import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeModel {

final String employeeId;

final String uid;

final String name;

final String email;

final String phone;

final String department;

final String role;

final double monthlySalary;

final String profileImage;

final bool isActive;

final bool isOnline;

final Timestamp? joiningDate;

final Timestamp? createdAt;

final Timestamp? updatedAt;

const EmployeeModel({

required this.employeeId,

required this.uid,

required this.name,

required this.email,

required this.phone,

required this.department,

required this.role,

required this.monthlySalary,

required this.profileImage,

required this.isActive,

required this.isOnline,

this.joiningDate,

this.createdAt,

this.updatedAt,

});


factory EmployeeModel.fromMap(
Map<String, dynamic> map,
) {

return EmployeeModel(

employeeId:
map["employeeId"] ?? "",

uid:
map["uid"] ?? "",

name:
map["name"] ?? "",

email:
map["email"] ?? "",

phone:
map["phone"] ?? "",

department:
map["department"] ?? "",

role:
map["role"] ?? "",

monthlySalary:
(map["monthlySalary"] ?? 0)
.toDouble(),

profileImage:
map["profileImage"] ?? "",

isActive:
map["isActive"] ?? true,

isOnline:
map["isOnline"] ?? false,

joiningDate:
map["joiningDate"],

createdAt:
map["createdAt"],

updatedAt:
map["updatedAt"],

);

}

Map<String, dynamic> toMap() {

return {

"employeeId": employeeId,

"uid": uid,

"name": name,

"email": email,

"phone": phone,

"department": department,

"role": role,

"monthlySalary": monthlySalary,

"profileImage": profileImage,

"isActive": isActive,

"isOnline": isOnline,

"joiningDate": joiningDate,

"createdAt": createdAt,

"updatedAt": updatedAt,

};

}

EmployeeModel copyWith({

String? employeeId,

String? uid,

String? name,

String? email,

String? phone,

String? department,

String? role,

double? monthlySalary,

String? profileImage,

bool? isActive,

bool? isOnline,

Timestamp? joiningDate,

Timestamp? createdAt,

Timestamp? updatedAt,

}) {

return EmployeeModel(

employeeId:
employeeId ?? this.employeeId,

uid:
uid ?? this.uid,

name:
name ?? this.name,

email:
email ?? this.email,

phone:
phone ?? this.phone,

department:
department ?? this.department,

role:
role ?? this.role,

monthlySalary:
monthlySalary ??
this.monthlySalary,

profileImage:
profileImage ??
this.profileImage,

isActive:
isActive ?? this.isActive,

isOnline:
isOnline ?? this.isOnline,

joiningDate:
joiningDate ??
this.joiningDate,

createdAt:
createdAt ??
this.createdAt,

updatedAt:
updatedAt ??
this.updatedAt,

);

}


factory EmployeeModel.empty() {

return const EmployeeModel(

employeeId: "",

uid: "",

name: "",

email: "",

phone: "",

department: "",

role: "",

monthlySalary: 0,

profileImage: "",

isActive: true,

isOnline: false,

joiningDate: null,

createdAt: null,

updatedAt: null,

);

}

}