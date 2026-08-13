import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/payroll_service.dart';
import '../../domain/payroll_model.dart';
import '../widgets/payroll_summary_widget.dart';

class PayrollManagementPage extends StatefulWidget {
  const PayrollManagementPage({super.key});

  @override
  State<PayrollManagementPage> createState() =>
      _PayrollManagementPageState();
}
class _PayrollManagementPageState
    extends State<PayrollManagementPage> {
final PayrollService _payrollService =
PayrollService();

//-----------------------------------------
// Search
//-----------------------------------------

final TextEditingController
searchController =
TextEditingController();

//-----------------------------------------
// Payroll Data
//-----------------------------------------

List<PayrollModel> payrollList = [];

List<PayrollModel> filteredPayroll = [];

//-----------------------------------------
// Loading
//-----------------------------------------

bool loading = true;

//-----------------------------------------
// Summary
//-----------------------------------------

double totalSalary = 0;

double totalBonus = 0;

double totalDeduction = 0;

double totalNetSalary = 0;

//-----------------------------------------
// Stream
//-----------------------------------------

StreamSubscription<
    List<PayrollModel>>? payrollSubscription;


@override
void initState() {
  super.initState();

  loadPayroll();
}

@override
void dispose() {

  payrollSubscription?.cancel();

  searchController.dispose();

  super.dispose();

}

//-----------------------------------------
// Load Payroll
//-----------------------------------------

void loadPayroll() {

  payrollSubscription?.cancel();

  payrollSubscription =
      _payrollService
          .getPayroll()
          .listen((data) {

        payrollList = data;

        filterPayroll();

      });

}


//-----------------------------------------
// Search Payroll
//-----------------------------------------

void filterPayroll() {

  final query =
  searchController.text
      .trim()
      .toLowerCase();

  if (query.isEmpty) {

    filteredPayroll =
        List.from(payrollList);

  } else {

    filteredPayroll =
        payrollList.where((payroll) {

          return payroll.employeeName
              .toLowerCase()
              .contains(query) ||

              payroll.employeeId
                  .toLowerCase()
                  .contains(query);

        }).toList();

  }

  totalSalary = 0;
  totalBonus = 0;
  totalDeduction = 0;
  totalNetSalary = 0;

  for (final payroll in filteredPayroll) {

    totalSalary +=
        payroll.monthlySalary;

    totalBonus +=
        payroll.bonus;

    totalDeduction +=
        payroll.deductions;

    totalNetSalary +=
        payroll.netSalary;

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

        title: const Text(
          "Payroll Management",
        ),

        centerTitle: true,

        actions: [

          IconButton(

            icon: const Icon(
              Icons.refresh,
            ),

            onPressed: loadPayroll,

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


            TextField(

            controller:
            searchController,

            decoration:
            InputDecoration(

              hintText:
              "Search Employee...",

              prefixIcon:
              const Icon(
                Icons.search,
              ),

              suffixIcon:
              searchController
                  .text
                  .isNotEmpty

                  ? IconButton(

                icon:
                const Icon(
                  Icons.clear,
                ),

                onPressed: () {

                  searchController
                      .clear();

                  filterPayroll();

                },

              )

                  : null,

              border:
              OutlineInputBorder(

                borderRadius:
                BorderRadius.circular(
                  12,
                ),

              ),

            ),

            onChanged: (_) {

              filterPayroll();

            },

          ),

        const SizedBox(height: 20),


        Row(

          children: [

            Expanded(

              child:
              PayrollSummaryWidget(

                title:
                "Salary",

                value:
                totalSalary,

                icon:
                Icons.account_balance_wallet,

                color:
                Colors.blue,

              ),

            ),

            const SizedBox(width: 10),

            Expanded(

              child:
              PayrollSummaryWidget(

                title:
                "Bonus",

                value:
                totalBonus,

                icon:
                Icons.add_circle,

                color:
                Colors.green,

              ),

            ),

            const SizedBox(width: 10),

            Expanded(

              child:
              PayrollSummaryWidget(

                title:
                "Deduction",

                value:
                totalDeduction,

                icon:
                Icons.remove_circle,

                color:
                Colors.red,

              ),

            ),

            const SizedBox(width: 10),

            Expanded(

              child:
              PayrollSummaryWidget(

                title:
                "Net Salary",

                value:
                totalNetSalary,

                icon:
                Icons.payments,

                color:
                Colors.orange,

              ),

            ),

          ],

        ),

        const SizedBox(height: 20),



        Expanded(

          child: filteredPayroll.isEmpty

              ? const Center(

            child: Text(

              "No Payroll Records Found",

              style: TextStyle(
                fontSize: 18,
              ),

            ),

          )

              : ListView.builder(

            itemCount:
            filteredPayroll.length,

            itemBuilder:
                (context, index) {

              final payroll =
              filteredPayroll[index];

              return Card(

                margin:
                const EdgeInsets.only(
                  bottom: 12,
                ),

                elevation: 2,

                child: ListTile(

                  leading:
                  const CircleAvatar(

                    child: Icon(
                      Icons.person,
                    ),

                  ),

                  title: Text(

                    payroll.employeeName,

                    style: const TextStyle(
                      fontWeight:
                      FontWeight.bold,
                    ),

                  ),

                  subtitle: Column(

                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [

                      Text(
                        "Employee ID : ${payroll.employeeId}",
                      ),

                      Text(
                        "Basic Salary : ₹${payroll.monthlySalary.toStringAsFixed(2)}",
                      ),

                      Text(
                        "Net Salary : ₹${payroll.netSalary.toStringAsFixed(2)}",
                      ),

                    ],

                  ),

                  trailing: PopupMenuButton<String>(

                    onSelected: (value) {

                      if (value ==
                          "generate") {

                        ScaffoldMessenger.of(
                            context)
                            .showSnackBar(

                          SnackBar(

                            content: Text(
                              "Generate Payslip for ${payroll.employeeName}",
                            ),

                          ),

                        );

                      }

                      if (value ==
                          "delete") {

                        ScaffoldMessenger.of(
                            context)
                            .showSnackBar(

                          SnackBar(

                            content: Text(
                              "Delete Payroll of ${payroll.employeeName}",
                            ),

                          ),

                        );

                      }

                    },

                    itemBuilder:
                        (context) => [

                      const PopupMenuItem(

                        value:
                        "generate",

                        child: Text(
                          "Generate Payslip",
                        ),

                      ),

                      const PopupMenuItem(

                        value:
                        "delete",

                        child: Text(
                          "Delete Payroll",
                        ),

                      ),

                    ],

                  ),

                ),

              );

            },

          ),

        ),

              ],

          ),

      ),

  );

}
}
