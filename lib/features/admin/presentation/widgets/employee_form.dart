import 'package:flutter/material.dart';

class EmployeeForm extends StatelessWidget {
final GlobalKey<FormState> formKey;

final TextEditingController employeeIdController;
final TextEditingController nameController;
final TextEditingController emailController;
final TextEditingController phoneController;
final TextEditingController departmentController;
final TextEditingController roleController;
final TextEditingController salaryController;

final bool showEmployeeId;

const EmployeeForm({
super.key,
required this.formKey,
required this.employeeIdController,
required this.nameController,
required this.emailController,
required this.phoneController,
required this.departmentController,
required this.roleController,
required this.salaryController,
this.showEmployeeId = true,
});

@override
Widget build(BuildContext context) {
return Form(
key: formKey,

child: SingleChildScrollView(

child: Column(

children: [

//--------------------------------------
// Employee ID
//--------------------------------------

if (showEmployeeId) ...[

TextFormField(

controller: employeeIdController,

decoration: const InputDecoration(

labelText: "Employee ID",

hintText: "EMP001",

prefixIcon:
Icon(Icons.badge),

border:
OutlineInputBorder(),

),

validator: (value) {

if (value == null ||
value.trim().isEmpty) {

return "Employee ID is required";

}

return null;

},

),

const SizedBox(height: 16),

],

//--------------------------------------
// Employee Name
//--------------------------------------

TextFormField(

controller: nameController,

textCapitalization:
TextCapitalization.words,

decoration: const InputDecoration(

labelText: "Employee Name",

prefixIcon:
Icon(Icons.person),

border:
OutlineInputBorder(),

),

validator: (value) {

if (value == null ||
value.trim().isEmpty) {

return "Employee Name is required";

}

return null;

},

),

const SizedBox(height: 16),

//--------------------------------------
// Email
//--------------------------------------

TextFormField(

controller: emailController,

keyboardType:
TextInputType.emailAddress,

decoration: const InputDecoration(

labelText: "Email",

prefixIcon:
Icon(Icons.email),

border:
OutlineInputBorder(),

),

validator: (value) {

if (value == null ||
value.trim().isEmpty) {

return "Email is required";

}

if (!value.contains("@")) {

return "Enter a valid email";

}

return null;

},

),

const SizedBox(height: 16),

//--------------------------------------
// Phone
//--------------------------------------

TextFormField(

controller: phoneController,

keyboardType:
TextInputType.phone,

decoration: const InputDecoration(

labelText: "Phone Number",

prefixIcon:
Icon(Icons.phone),

border:
OutlineInputBorder(),

),

validator: (value) {

if (value == null ||
value.trim().isEmpty) {

return "Phone Number is required";

}

if (value.length < 10) {

return "Enter valid phone number";

}

return null;

},

),

const SizedBox(height: 16),

  //--------------------------------------
  // Department
  //--------------------------------------

  TextFormField(

    controller: departmentController,

    textCapitalization:
    TextCapitalization.words,

    decoration: const InputDecoration(

      labelText: "Department",

      hintText:
      "Enter Department",

      prefixIcon:
      Icon(Icons.business),

      border:
      OutlineInputBorder(),

    ),

    validator: (value) {

      if (value == null ||
          value.trim().isEmpty) {

        return "Department is required";

      }

      return null;

    },

  ),

  const SizedBox(height: 16),

  //--------------------------------------
  // Role
  //--------------------------------------

  TextFormField(

    controller: roleController,

    textCapitalization:
    TextCapitalization.words,

    decoration: const InputDecoration(

      labelText: "Role",

      hintText:
      "Enter Role",

      prefixIcon:
      Icon(Icons.work),

      border:
      OutlineInputBorder(),

    ),

    validator: (value) {

      if (value == null ||
          value.trim().isEmpty) {

        return "Role is required";

      }

      return null;

    },

  ),

  const SizedBox(height: 16),

  //--------------------------------------
  // Monthly Salary
  //--------------------------------------

  TextFormField(

    controller: salaryController,

    keyboardType:
    const TextInputType.numberWithOptions(
      decimal: true,
    ),

    decoration: const InputDecoration(

      labelText: "Monthly Salary",

      hintText: "25000",

      prefixIcon:
      Icon(Icons.currency_rupee),

      border:
      OutlineInputBorder(),

    ),

    validator: (value) {

      if (value == null ||
          value.trim().isEmpty) {

        return "Salary is required";

      }

      if (double.tryParse(value) ==
          null) {

        return "Enter valid salary";

      }

      return null;

    },

  ),

  const SizedBox(height: 24),

  //--------------------------------------
  // Future Profile Image Placeholder
  //--------------------------------------

  Container(

    width: double.infinity,

    padding:
    const EdgeInsets.all(20),

    decoration: BoxDecoration(

      color: Colors.grey.shade100,

      borderRadius:
      BorderRadius.circular(12),

      border: Border.all(
        color: Colors.grey.shade300,
      ),

    ),

    child: Column(

      children: [

        Icon(

          Icons.image,

          size: 40,

          color: Colors.grey.shade600,

        ),

        const SizedBox(height: 10),

        Text(

          "Profile Image\n(Coming Soon)",

          textAlign: TextAlign.center,

          style: TextStyle(

            color: Colors.grey.shade700,

          ),

        ),

      ],

    ),

  ),

],

),

),

);

}

}