import 'package:flutter/material.dart';

import '../../data/employee_service.dart';
import '../../models/employee_model.dart';
import '../widgets/employee_form.dart';

class EditEmployeeDialog extends StatefulWidget {
  final String employeeId;
  final Map<String, dynamic> employee;

  const EditEmployeeDialog({
    super.key,
    required this.employeeId,
    required this.employee,
  });

  @override
  State<EditEmployeeDialog> createState() =>
      _EditEmployeeDialogState();
}

class _EditEmployeeDialogState
    extends State<EditEmployeeDialog> {

final EmployeeService _service =
EmployeeService.instance;

final _formKey =
GlobalKey<FormState>();

late TextEditingController employeeIdController;
late TextEditingController nameController;
late TextEditingController emailController;
late TextEditingController phoneController;
late TextEditingController departmentController;
late TextEditingController roleController;
late TextEditingController salaryController;

bool loading = false;

@override
void initState() {
super.initState();

employeeIdController = TextEditingController(
text: widget.employee["employeeId"] ?? "",
);

nameController = TextEditingController(
text: widget.employee["name"] ?? "",
);

emailController = TextEditingController(
text: widget.employee["email"] ?? "",
);

phoneController = TextEditingController(
text: widget.employee["phone"] ?? "",
);

departmentController = TextEditingController(
text: widget.employee["department"] ?? "",
);

roleController = TextEditingController(
text: widget.employee["role"] ?? "",
);

salaryController = TextEditingController(
text: (widget.employee["monthlySalary"] ?? 0)
.toString(),
);
}

@override
void dispose() {

employeeIdController.dispose();

nameController.dispose();

emailController.dispose();

phoneController.dispose();

departmentController.dispose();

roleController.dispose();

salaryController.dispose();

super.dispose();

}

Future<void> updateEmployee() async {

if (!_formKey.currentState!.validate()) {
return;
}

setState(() {
loading = true;
});

try {

  final employee = EmployeeModel(

    employeeId: widget.employeeId,

    uid: widget.employee["uid"] ?? "",

    name: nameController.text.trim(),

    email: emailController.text.trim(),

    phone: phoneController.text.trim(),

    department:
    departmentController.text.trim(),

    role: roleController.text.trim(),

    monthlySalary:
    double.tryParse(
      salaryController.text,
    ) ??
        0,

    profileImage:
    widget.employee["profileImage"] ?? "",

    isActive:
    widget.employee["isActive"] ?? true,

    isOnline:
    widget.employee["isOnline"] ?? false,

    joiningDate:
    widget.employee["joiningDate"],

    createdAt:
    widget.employee["createdAt"],

    updatedAt: null,

  );

  await _service.updateEmployee(
    employee,
  );
if (!mounted) return;

Navigator.pop(context);

ScaffoldMessenger.of(context).showSnackBar(

const SnackBar(

content: Text(
"Employee Updated Successfully",
),

),

);

} catch (e) {

if (mounted) {

ScaffoldMessenger.of(context).showSnackBar(

SnackBar(
content: Text(e.toString()),
),

);

}

} finally {

if (mounted) {

setState(() {
loading = false;
});

}

}

}


@override
Widget build(BuildContext context) {

  return AlertDialog(

    title: const Text(
      "Edit Employee",
    ),

    content: SizedBox(

      width: 500,

      child: EmployeeForm(

        formKey: _formKey,

        employeeIdController:
        employeeIdController,

        nameController:
        nameController,

        emailController:
        emailController,

        phoneController:
        phoneController,

        departmentController:
        departmentController,

        roleController:
        roleController,

        salaryController:
        salaryController,

        // Employee ID cannot be edited
        showEmployeeId: false,

      ),

    ),

    actions: [

      TextButton(

        onPressed: loading
            ? null
            : () {

          Navigator.pop(context);

        },

        child: const Text(
          "Cancel",
        ),

      ),

      ElevatedButton.icon(

        onPressed:
        loading
            ? null
            : updateEmployee,

        icon: loading

            ? const SizedBox(

          width: 18,

          height: 18,

          child:
          CircularProgressIndicator(
            strokeWidth: 2,
          ),

        )

            : const Icon(
          Icons.save,
        ),

        label: Text(

          loading
              ? "Updating..."
              : "Update Employee",

        ),

      ),

    ],

  );

}

}