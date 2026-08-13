import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
  });

  @override
  State<SettingsPage> createState() =>
      _SettingsPageState();
}

class _SettingsPageState
    extends State<SettingsPage> {


bool notifications = true;

bool biometricLogin = false;

bool darkMode = false;

final companyNameController =
TextEditingController(
text: "Stallion One",
);

final workingHoursController =
TextEditingController(
text: "09:30 AM - 06:30 PM",
);

final emailController =
TextEditingController(
text: "admin@stallionone.com",
);


@override
void dispose() {

companyNameController.dispose();

workingHoursController.dispose();

emailController.dispose();

super.dispose();

}


@override
Widget build(BuildContext context) {

return Scaffold(

appBar: AppBar(

title: const Text(
"Settings",
),

centerTitle: true,

),

body: ListView(

padding: const EdgeInsets.all(16),

children: [


const Text(

"Company Information",

style: TextStyle(

fontSize: 20,

fontWeight: FontWeight.bold,

),

),

const SizedBox(height: 20),

TextField(

controller: companyNameController,

decoration: const InputDecoration(

labelText: "Company Name",

prefixIcon: Icon(Icons.business),

border: OutlineInputBorder(),

),

),

const SizedBox(height: 15),

TextField(

controller: emailController,

decoration: const InputDecoration(

labelText: "Company Email",

prefixIcon: Icon(Icons.email),

border: OutlineInputBorder(),

),

),

const SizedBox(height: 15),

TextField(

controller: workingHoursController,

decoration: const InputDecoration(

labelText: "Working Hours",

prefixIcon: Icon(Icons.access_time),

border: OutlineInputBorder(),

),

),

const SizedBox(height: 30),



const Text(

"Application Settings",

style: TextStyle(

fontSize: 20,

fontWeight: FontWeight.bold,

),

),

const SizedBox(height: 15),

SwitchListTile(

value: notifications,

title: const Text(
"Enable Notifications",
),

secondary: const Icon(
Icons.notifications,
),

onChanged: (value) {

setState(() {

notifications = value;

});

},

),

SwitchListTile(

value: biometricLogin,

title: const Text(
"Biometric Login",
),

secondary: const Icon(
Icons.fingerprint,
),

onChanged: (value) {

setState(() {

biometricLogin = value;

});

},

),

SwitchListTile(

value: darkMode,

title: const Text(
"Dark Mode",
),

secondary: const Icon(
Icons.dark_mode,
),

onChanged: (value) {

setState(() {

darkMode = value;

});

},

),

const SizedBox(height: 30),


SizedBox(

width: double.infinity,

height: 50,

child: ElevatedButton.icon(

onPressed: () {

ScaffoldMessenger.of(context).showSnackBar(

const SnackBar(

content: Text(
"Settings Saved Successfully",
),

),

);

},

icon: const Icon(
Icons.save,
),

label: const Text(
"Save Settings",
),

),

),

const SizedBox(height: 30),


Card(

child: ListTile(

leading: const Icon(
Icons.info,
),

title: const Text(
"About Stallion One",
),

subtitle: const Text(

"Version 1.0.0\n"
"Employee Management System",

),

),

),

],

),

);

}

}

