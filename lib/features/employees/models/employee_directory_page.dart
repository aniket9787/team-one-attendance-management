import 'dart:async';

import 'package:flutter/material.dart';

import '../../admin/data/employee_service.dart';
import '../../admin/models/employee_model.dart';
import 'employee_directory_card.dart';



class EmployeeDirectoryPage extends StatefulWidget {
  const EmployeeDirectoryPage({
    super.key,
  });

  @override
  State<EmployeeDirectoryPage> createState() =>
      _EmployeeDirectoryPageState();
}

class _EmployeeDirectoryPageState
    extends State<EmployeeDirectoryPage> {

  //-----------------------------------------
  // Service
  //-----------------------------------------

  final EmployeeService _employeeService =
      EmployeeService.instance;

  //-----------------------------------------
  // Employee List
  //-----------------------------------------

  List<EmployeeModel> employees = [];

  List<EmployeeModel> filteredEmployees = [];

  //-----------------------------------------
  // Search
  //-----------------------------------------

  final TextEditingController searchController =
  TextEditingController();

  //-----------------------------------------
  // Loading
  //-----------------------------------------

  bool loading = true;

  //-----------------------------------------
  // Stream
  //-----------------------------------------

  StreamSubscription<List<EmployeeModel>>?
  employeeSubscription;

  @override
  void initState() {
    super.initState();

    loadEmployees();
  }

  @override
  void dispose() {

    employeeSubscription?.cancel();

    searchController.dispose();

    super.dispose();

  }

  //-----------------------------------------
  // Load Employees
  //-----------------------------------------

  void loadEmployees() {

    employeeSubscription?.cancel();

    employeeSubscription =
        _employeeService
            .getEmployees()
            .listen((data) {

          employees = data;

          filterEmployees();

        });

  }

  //-----------------------------------------
  // Search
  //-----------------------------------------

  void filterEmployees() {

    final query =
    searchController.text
        .trim()
        .toLowerCase();

    if (query.isEmpty) {

      filteredEmployees =
          List.from(employees);

    } else {

      filteredEmployees =
          employees.where((employee) {

            return employee.name
                .toLowerCase()
                .contains(query) ||

                employee.email
                    .toLowerCase()
                    .contains(query) ||

                employee.role
                    .toLowerCase()
                    .contains(query);

          }).toList();

    }

    if (mounted) {

      setState(() {

        loading = false;

      });

    }

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      const Color(0xFFF5F7FA),

      appBar: AppBar(

        centerTitle: true,

        title: const Text(
          "Employee Directory",
        ),

        actions: [

          IconButton(

            onPressed: () {

              setState(() {

                loading = true;

              });

              loadEmployees();

            },

            icon: const Icon(
              Icons.refresh,
            ),

          ),

        ],

      ),

      body: loading

          ? const Center(
        child:
        CircularProgressIndicator(),
      )

          : Padding(

        padding:
        const EdgeInsets.all(16),

        child: Column(

          children: [

            //---------------------------------
            // Search Bar
            //---------------------------------

            Center(

              child: ConstrainedBox(

                constraints:
                const BoxConstraints(
                  maxWidth: 700,
                ),

                child: TextFormField(

                  controller:
                  searchController,

                  onChanged: (value) {

                    filterEmployees();

                  },

                  decoration:
                  InputDecoration(

                    hintText:
                    "Search Employee",

                    prefixIcon:
                    const Icon(
                      Icons.search,
                    ),

                    filled: true,

                    fillColor:
                    Colors.white,

                    border:
                    OutlineInputBorder(

                      borderRadius:
                      BorderRadius.circular(
                        15,
                      ),

                    ),

                    enabledBorder:
                    OutlineInputBorder(

                      borderRadius:
                      BorderRadius.circular(
                        15,
                      ),

                      borderSide:
                      BorderSide(
                        color: Colors.grey.shade300,
                      ),

                    ),

                  ),

                ),

              ),

            ),

            const SizedBox(
              height: 20,
            ),

            //---------------------------------
            // Employee Count
            //---------------------------------

            Padding(

              padding:
              const EdgeInsets.symmetric(
                horizontal: 4,
              ),

              child: Align(

                alignment:
                Alignment.centerLeft,

                child: Text(

                  "Total Employees : ${filteredEmployees.length}",

                  style:
                  const TextStyle(

                    fontSize: 18,

                    fontWeight:
                    FontWeight.bold,

                  ),

                ),

              ),

            ),

            const SizedBox(
              height: 15,
            ),

            //---------------------------------
            // Employee List
            //---------------------------------

            Expanded(

              child:

              filteredEmployees
                  .isEmpty

                  ? const Center(

                child: Text(

                  "No Employees Found",

                  style: TextStyle(
                    fontSize: 18,
                  ),

                ),

              )

                  : Center(

                child:
                ConstrainedBox(

                  constraints:
                  const BoxConstraints(
                    maxWidth: 900,
                  ),

                  child:
                  ListView.builder(

                    itemCount:
                    filteredEmployees
                        .length,

                    itemBuilder:
                        (context,
                        index) {

                      final employee =
                      filteredEmployees[
                      index];

                      return EmployeeDirectoryCard(

                        employee:
                        employee,

                      );

                    },

                  ),

                ),

              ),

            ),

          ],

        ),

      ),

    );

  }

}