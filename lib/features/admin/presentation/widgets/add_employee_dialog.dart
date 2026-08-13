import 'package:flutter/material.dart';
import '../../data/employee_service.dart';
import 'employee_form.dart';

import '../../models/employee_model.dart';

class AddEmployeeDialog extends StatefulWidget {
  const AddEmployeeDialog({super.key});

  @override
  State<AddEmployeeDialog> createState() =>
      _AddEmployeeDialogState();
}

class _AddEmployeeDialogState
    extends State<AddEmployeeDialog> {

final EmployeeService _service =
EmployeeService.instance;

final _formKey =
GlobalKey<FormState>();

final employeeIdController =
TextEditingController();

final nameController =
TextEditingController();

final emailController =
TextEditingController();

final phoneController =
TextEditingController();

final departmentController =
TextEditingController();

final roleController =
TextEditingController();

final salaryController =
TextEditingController();

bool loading = false;


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
Future<void> saveEmployee() async {

if (!_formKey.currentState!.validate()) {
return;
}

setState(() {
loading = true;
});

try {

  final employee = EmployeeModel(

    employeeId:
    employeeIdController.text.trim(),

    uid: "",

    name:
    nameController.text.trim(),

    email:
    emailController.text.trim(),

    phone:
    phoneController.text.trim(),

    department:
    departmentController.text.trim(),

    role:
    roleController.text.trim(),

    monthlySalary:
    double.tryParse(
      salaryController.text,
    ) ??
        0,

    profileImage: "",

    isActive: true,

    isOnline: false,

  );

  await _service.addEmployee(
    employee,
  );


if (!mounted) return;

Navigator.pop(context);

ScaffoldMessenger.of(context)
.showSnackBar(

const SnackBar(

content: Text(
"Employee Added Successfully",
),

),

);

} catch (e) {

setState(() {
loading = false;
});

ScaffoldMessenger.of(context)
.showSnackBar(

SnackBar(
content: Text(e.toString()),
),

);

}

}
@override
Widget build(BuildContext context) {

  return AlertDialog(

    title: const Text(
      "Add Employee",
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

        showEmployeeId: true,

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
            : saveEmployee,

        icon: loading

            ? const SizedBox(

          height: 18,

          width: 18,

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
              ? "Saving..."
              : "Save Employee",

        ),

      ),

    ],

  );

}

}



