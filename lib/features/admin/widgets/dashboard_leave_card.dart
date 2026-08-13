import 'package:flutter/material.dart';

import '../../leave/domain/leave_model.dart';


class DashboardLeaveCard extends StatelessWidget {
  final LeaveModel leave;

  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback? onTap;

  const DashboardLeaveCard({
    super.key,
    required this.leave,
    required this.onApprove,
    required this.onReject,
    this.onTap,
  });

  Color get statusColor {
    switch (leave.status.toLowerCase()) {
      case "approved":
        return Colors.green;

      case "rejected":
        return Colors.red;

      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final bool isMobile = width < 600;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),

      elevation: 3,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),

      child: InkWell(
        borderRadius: BorderRadius.circular(20),

        onTap: onTap,

        child: Padding(
          padding: const EdgeInsets.all(18),

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [

              //----------------------------------
              // Header
              //----------------------------------

              Row(
                children: [

                  CircleAvatar(
                    radius: isMobile ? 24 : 28,
                    backgroundColor:
                    Colors.orange.shade100,

                    child: Icon(
                      Icons.event_note,
                      color: Colors.orange.shade700,
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,

                      children: [

                        Text(
                          leave.employeeName,

                          maxLines: 1,

                          overflow:
                          TextOverflow.ellipsis,

                          style: TextStyle(
                            fontSize:
                            isMobile ? 16 : 18,

                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          leave.leaveType,

                          style: TextStyle(
                            color:
                            Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),

                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius:
                      BorderRadius.circular(20),
                    ),

                    child: Text(
                      leave.status,

                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight:
                        FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              //----------------------------------
              // Reason
              //----------------------------------

              Text(
                leave.reason,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,

                style: TextStyle(
                  color: Colors.grey.shade700,
                ),
              ),

              const SizedBox(height: 14),

              //----------------------------------
              // Dates
              //----------------------------------

              Row(
                children: [

                  const Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: Colors.blue,
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      "${leave.startDate.day}/${leave.startDate.month}/${leave.startDate.year}"
                          "  →  "
                          "${leave.endDate.day}/${leave.endDate.month}/${leave.endDate.year}",
                    ),
                  ),

                ],
              ),

              const SizedBox(height: 18),

              //----------------------------------
              // Buttons
              //----------------------------------

              if (leave.status == "Pending")

                Row(
                  children: [

                    Expanded(
                      child: ElevatedButton.icon(

                        onPressed: onApprove,

                        style:
                        ElevatedButton.styleFrom(
                          backgroundColor:
                          Colors.green,
                          foregroundColor:
                          Colors.white,
                        ),

                        icon: const Icon(
                          Icons.check,
                        ),

                        label: const Text(
                          "Approve",
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child:
                      OutlinedButton.icon(

                        onPressed: onReject,

                        icon: const Icon(
                          Icons.close,
                          color: Colors.red,
                        ),

                        label: const Text(
                          "Reject",
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
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