import 'package:flutter/material.dart';

import '../../admin/models/employee_model.dart';



class EmployeeDirectoryCard extends StatelessWidget {
  final EmployeeModel employee;

  const EmployeeDirectoryCard({
    super.key,
    required this.employee,
  });

  @override
  Widget build(BuildContext context) {

    final screenWidth =
        MediaQuery.of(context).size.width;

    final isMobile =
        screenWidth < 600;

    return Card(

      margin: const EdgeInsets.only(
        bottom: 16,
      ),

      elevation: 3,

      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(18),
      ),

      child: Padding(

        padding:
        const EdgeInsets.all(18),

        child: Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            //-----------------------------------
            // Header
            //-----------------------------------

            Row(

              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                CircleAvatar(

                  radius: isMobile
                      ? 28
                      : 34,

                  backgroundColor:
                  Colors.blue.shade100,

                  backgroundImage:
                  employee
                      .profileImage
                      .isNotEmpty
                      ? NetworkImage(
                    employee.profileImage,
                  )
                      : null,

                  child: employee.profileImage.isEmpty
                      ? Text(
                    employee.name.isNotEmpty
                        ? employee.name[0].toUpperCase()
                        : "E",
                    style:
                    TextStyle(
                      fontSize:
                      isMobile
                          ? 20
                          : 24,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  )
                      : null,

                ),

                const SizedBox(width: 16),

                Expanded(

                  child: Column(

                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [

                      Text(

                        employee.name,

                        style:
                        TextStyle(

                          fontSize:
                          isMobile
                              ? 18
                              : 20,

                          fontWeight:
                          FontWeight.bold,

                        ),

                      ),

                      const SizedBox(height: 4),

                      Text(
                        employee.role,
                      ),

                      const SizedBox(height: 4),

                      Text(
                        employee.email,
                      ),

                    ],

                  ),

                ),

                Container(

                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),

                  decoration: BoxDecoration(

                    color:
                    employee.isOnline
                        ? Colors.green
                        : Colors.grey,

                    borderRadius:
                    BorderRadius.circular(
                      20,
                    ),

                  ),

                  child: Text(

                    employee.isOnline
                        ? "Online"
                        : "Offline",

                    style:
                    const TextStyle(
                      color: Colors.white,
                      fontWeight:
                      FontWeight.bold,
                    ),

                  ),

                ),

              ],

            ),

            const SizedBox(height: 20),

            const Divider(),

            const SizedBox(height: 12),

            //-----------------------------------
            // Details
            //-----------------------------------

            _infoRow(
              Icons.business,
              "Department",
              employee.department,
            ),

            _infoRow(
              Icons.work,
              "Role",
              employee.role,
            ),

            _infoRow(
              Icons.phone,
              "Phone",
              employee.phone,
            ),

            _infoRow(
              Icons.email,
              "Email",
              employee.email,
            ),

          ],

        ),

      ),

    );

  }

  Widget _infoRow(
      IconData icon,
      String title,
      String value,
      ) {

    return Padding(

      padding:
      const EdgeInsets.only(
        bottom: 10,
      ),

      child: Row(

        children: [

          Icon(
            icon,
            color: Colors.blue,
            size: 20,
          ),

          const SizedBox(width: 10),

          SizedBox(

            width: 100,

            child: Text(

              title,

              style:
              const TextStyle(
                fontWeight:
                FontWeight.bold,
              ),

            ),

          ),

          Expanded(
            child: Text(value),
          ),

        ],

      ),

    );

  }

}