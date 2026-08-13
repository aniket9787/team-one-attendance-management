import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../holidays/domain/holiday_model.dart';

class HolidayCard extends StatelessWidget {
  final HolidayModel holiday;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const HolidayCard({
    super.key,
    required this.holiday,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final bool isMobile = width < 600;

    final bool isTablet =
        width >= 600 && width < 1000;

    final date =
    DateFormat("dd MMM yyyy")
        .format(holiday.holidayDate);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Padding(
        padding: EdgeInsets.all(
          isMobile ? 14 : 20,
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [

            //-----------------------------------
            // Top Row
            //-----------------------------------

            Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [

                CircleAvatar(
                  radius:
                  isMobile ? 24 : 28,
                  backgroundColor:
                  Colors.blue.shade100,
                  child: Icon(
                    Icons.event,
                    color: Colors.blue,
                    size:
                    isMobile ? 24 : 28,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [

                      Text(
                        holiday.title,
                        maxLines: 2,
                        overflow:
                        TextOverflow
                            .ellipsis,
                        style: TextStyle(
                          fontWeight:
                          FontWeight.bold,
                          fontSize: isMobile
                              ? 17
                              : 20,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        holiday.description,
                        maxLines: 3,
                        overflow:
                        TextOverflow
                            .ellipsis,
                        style: TextStyle(
                          color: Colors
                              .grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),

                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == "edit") {
                      onEdit();
                    }

                    if (value ==
                        "delete") {
                      onDelete();
                    }
                  },
                  itemBuilder: (_) => const [

                    PopupMenuItem(
                      value: "edit",
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text("Edit"),
                        ],
                      ),
                    ),

                    PopupMenuItem(
                      value: "delete",
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          SizedBox(width: 8),
                          Text("Delete"),
                        ],
                      ),
                    ),

                  ],
                ),
              ],
            ),

            const SizedBox(height: 18),

            //-----------------------------------
            // Information
            //-----------------------------------

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [

                _InfoChip(
                  icon:
                  Icons.calendar_today,
                  text: date,
                  color: Colors.blue,
                ),

                _InfoChip(
                  icon: Icons.category,
                  text:
                  holiday.holidayType,
                  color: Colors.orange,
                ),

                _InfoChip(
                  icon: holiday.isOptional
                      ? Icons.star
                      : Icons.check_circle,
                  text:
                  holiday.isOptional
                      ? "Optional"
                      : "Mandatory",
                  color: holiday.isOptional
                      ? Colors.deepPurple
                      : Colors.green,
                ),

              ],
            ),

            const SizedBox(height: 18),

            //-----------------------------------
            // Bottom
            //-----------------------------------

            if (!isMobile)

              Row(
                children: [

                  const Spacer(),

                  OutlinedButton.icon(
                    onPressed: onEdit,
                    icon:
                    const Icon(Icons.edit),
                    label:
                    const Text("Edit"),
                  ),

                  const SizedBox(width: 12),

                  ElevatedButton.icon(
                    style:
                    ElevatedButton.styleFrom(
                      backgroundColor:
                      Colors.red,
                      foregroundColor:
                      Colors.white,
                    ),
                    onPressed: onDelete,
                    icon: const Icon(
                      Icons.delete,
                    ),
                    label: const Text(
                      "Delete",
                    ),
                  ),

                ],
              ),

            if (isMobile)

              Column(
                children: [

                  SizedBox(
                    width: double.infinity,
                    child:
                    OutlinedButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(
                        Icons.edit,
                      ),
                      label: const Text(
                        "Edit Holiday",
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child:
                    ElevatedButton.icon(
                      style:
                      ElevatedButton
                          .styleFrom(
                        backgroundColor:
                        Colors.red,
                        foregroundColor:
                        Colors.white,
                      ),
                      onPressed:
                      onDelete,
                      icon: const Icon(
                        Icons.delete,
                      ),
                      label: const Text(
                        "Delete Holiday",
                      ),
                    ),
                  ),

                ],
              ),

          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(
        icon,
        size: 18,
        color: color,
      ),
      label: Text(
        text,
        overflow:
        TextOverflow.ellipsis,
      ),
      backgroundColor:
      color.withOpacity(.08),
      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(30),
      ),
    );
  }
}