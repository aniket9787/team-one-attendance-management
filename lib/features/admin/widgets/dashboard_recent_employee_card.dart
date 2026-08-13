import 'package:flutter/material.dart';
import 'package:stallion_one/features/admin/models/employee_model.dart';

class DashboardRecentEmployeeCard extends StatefulWidget {
  final EmployeeModel employee;
  final VoidCallback? onTap;

  const DashboardRecentEmployeeCard({
    super.key,
    required this.employee,
    this.onTap,
  });

  @override
  State<DashboardRecentEmployeeCard> createState() =>
      _DashboardRecentEmployeeCardState();
}

class _DashboardRecentEmployeeCardState
    extends State<DashboardRecentEmployeeCard> {

  bool hovered = false;

  @override
  Widget build(BuildContext context) {

    final width = MediaQuery.of(context).size.width;

    final bool isPhone = width < 600;

    return AnimatedScale(

      duration: const Duration(milliseconds: 180),

      scale: hovered ? 1.01 : 1,

      child: InkWell(

        borderRadius: BorderRadius.circular(22),

        onHover: (value) {

          setState(() {

            hovered = value;

          });

        },

        onTap: widget.onTap,

        child: AnimatedContainer(

          duration: const Duration(milliseconds: 250),

          margin: const EdgeInsets.only(bottom: 14),

          padding: EdgeInsets.all(
            isPhone ? 14 : 18,
          ),

          decoration: BoxDecoration(

            color: Colors.white,

            borderRadius: BorderRadius.circular(22),

            border: Border.all(
              color: hovered
                  ? Colors.blue
                  : Colors.grey.shade200,
            ),

            boxShadow: [

              BoxShadow(

                color: Colors.blue.withOpacity(
                  hovered ? .15 : .08,
                ),

                blurRadius:
                hovered ? 18 : 10,

                offset: const Offset(0, 6),

              ),

            ],

          ),

          child: Row(

            children: [

              //---------------------------------
              // Avatar
              //---------------------------------

              Hero(

                tag: widget.employee.uid,

                child: CircleAvatar(

                  radius:
                  isPhone ? 28 : 34,

                  backgroundColor:
                  Colors.blue.shade100,

                  backgroundImage:
                  widget.employee.profileImage
                      .isNotEmpty
                      ? NetworkImage(
                    widget.employee.profileImage,
                  )
                      : null,

                  child:
                  widget.employee.profileImage.isEmpty
                      ? Text(

                    widget.employee.name.isEmpty
                        ? "?"

                        : widget.employee.name
                        .substring(0, 1)
                        .toUpperCase(),

                    style: TextStyle(

                      fontSize:
                      isPhone ? 20 : 24,

                      fontWeight:
                      FontWeight.bold,

                    ),

                  )
                      : null,

                ),

              ),

              const SizedBox(width: 16),

              //---------------------------------
              // Details
              //---------------------------------

              Expanded(

                child: Column(

                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    Text(

                      widget.employee.name,

                      maxLines: 1,

                      overflow:
                      TextOverflow.ellipsis,

                      style: TextStyle(

                        fontSize:
                        isPhone ? 17 : 20,

                        fontWeight:
                        FontWeight.bold,

                      ),

                    ),

                    const SizedBox(height: 4),

                    Text(

                      widget.employee.role,

                      style: TextStyle(

                        color:
                        Colors.grey.shade700,

                        fontSize:
                        isPhone ? 13 : 15,

                      ),

                    ),

                    const SizedBox(height: 4),

                    Text(

                      widget.employee.email,

                      maxLines: 1,

                      overflow:
                      TextOverflow.ellipsis,

                      style: TextStyle(

                        color:
                        Colors.grey.shade600,

                        fontSize:
                        isPhone ? 12 : 14,

                      ),

                    ),

                    const SizedBox(height: 10),

                    Row(

                      children: [

                        Icon(

                          Icons.business,

                          size: 16,

                          color:
                          Colors.grey.shade600,

                        ),

                        const SizedBox(width: 6),

                        Expanded(

                          child: Text(

                            widget.employee.department,

                            maxLines: 1,

                            overflow:
                            TextOverflow.ellipsis,

                            style: TextStyle(

                              color: Colors.grey.shade700,

                              fontSize:
                              isPhone ? 12 : 14,

                            ),

                          ),

                        ),

                      ],

                    ),

                  ],

                ),

              ),

              //---------------------------------
              // Right Side
              //---------------------------------

              Column(

                mainAxisAlignment:
                MainAxisAlignment.center,

                children: [

                  AnimatedContainer(

                    duration:
                    const Duration(
                        milliseconds: 250),

                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),

                    decoration: BoxDecoration(

                      color:
                      widget.employee.isOnline
                          ? Colors.green
                          : Colors.grey,

                      borderRadius:
                      BorderRadius.circular(
                        20,
                      ),

                    ),

                    child: Text(

                      widget.employee.isOnline
                          ? "Online"
                          : "Offline",

                      style: const TextStyle(

                        color: Colors.white,

                        fontSize: 11,

                        fontWeight:
                        FontWeight.bold,

                      ),

                    ),

                  ),

                  const SizedBox(height: 12),

                  CircleAvatar(

                    radius: 16,

                    backgroundColor:
                    Colors.blue.shade50,

                    child: Icon(

                      Icons.arrow_forward_ios,

                      size: 14,

                      color: Colors.blue.shade700,

                    ),

                  ),

                ],

              ),

            ],

          ),

        ),

      ),

    );

  }

}