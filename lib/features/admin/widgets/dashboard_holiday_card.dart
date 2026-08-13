import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:stallion_one/features/holidays/domain/holiday_model.dart';

class DashboardHolidayCard extends StatefulWidget {
  final HolidayModel holiday;
  final VoidCallback? onTap;

  const DashboardHolidayCard({
    super.key,
    required this.holiday,
    this.onTap,
  });

  @override
  State<DashboardHolidayCard> createState() =>
      _DashboardHolidayCardState();
}

class _DashboardHolidayCardState
    extends State<DashboardHolidayCard> {

  bool hovered = false;

  @override
  Widget build(BuildContext context) {

    final width =
        MediaQuery.of(context).size.width;

    final bool isPhone =
        width < 600;

    final date =
    DateFormat("dd")
        .format(widget.holiday.holidayDate);

    final month =
    DateFormat("MMM")
        .format(widget.holiday.holidayDate);

    final day =
    DateFormat("EEEE")
        .format(widget.holiday.holidayDate);

    return AnimatedScale(

      duration:
      const Duration(milliseconds: 180),

      scale: hovered ? 1.01 : 1,

      child: InkWell(

        onTap: widget.onTap,

        borderRadius:
        BorderRadius.circular(20),

        onHover: (value) {

          setState(() {

            hovered = value;

          });

        },

        child: AnimatedContainer(

          duration:
          const Duration(milliseconds: 250),

          margin:
          const EdgeInsets.only(bottom: 16),

          padding:
          EdgeInsets.all(isPhone ? 16 : 20),

          decoration: BoxDecoration(

            color: Colors.white,

            borderRadius:
            BorderRadius.circular(20),

            border: Border.all(

              color: hovered
                  ? Colors.orange
                  : Colors.grey.shade200,

            ),

            boxShadow: [

              BoxShadow(

                color: Colors.orange.withOpacity(
                  hovered ? .15 : .08,
                ),

                blurRadius:
                hovered ? 18 : 10,

                offset:
                const Offset(0, 6),

              ),

            ],

          ),

          child: Row(

            children: [

              //----------------------------------
              // Calendar
              //----------------------------------

              Container(

                width:
                isPhone ? 64 : 74,

                height:
                isPhone ? 74 : 84,

                decoration: BoxDecoration(

                  borderRadius:
                  BorderRadius.circular(16),

                  color:
                  Colors.orange.shade50,

                ),

                child: Column(

                  children: [

                    Container(

                      width: double.infinity,

                      padding:
                      const EdgeInsets.symmetric(
                        vertical: 6,
                      ),

                      decoration: const BoxDecoration(

                        color: Colors.orange,

                        borderRadius:
                        BorderRadius.vertical(
                          top:
                          Radius.circular(16),
                        ),

                      ),

                      child: Text(

                        month,

                        textAlign:
                        TextAlign.center,

                        style:
                        const TextStyle(

                          color: Colors.white,

                          fontWeight:
                          FontWeight.bold,

                        ),

                      ),

                    ),

                    Expanded(

                      child: Center(

                        child: Text(

                          date,

                          style:
                          TextStyle(

                            fontSize:
                            isPhone
                                ? 24
                                : 30,

                            fontWeight:
                            FontWeight.bold,

                          ),

                        ),

                      ),

                    ),

                  ],

                ),

              ),

              const SizedBox(width: 18),

              //----------------------------------
              // Holiday Details
              //----------------------------------

              Expanded(

                child: Column(

                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    Text(

                      widget.holiday.title,

                      maxLines: 2,

                      overflow:
                      TextOverflow.ellipsis,

                      style:
                      TextStyle(

                        fontSize:
                        isPhone
                            ? 17
                            : 20,

                        fontWeight:
                        FontWeight.bold,

                      ),

                    ),

                    const SizedBox(height: 6),

                    Text(

                      day,

                      style:
                      TextStyle(

                        color:
                        Colors.grey.shade600,

                      ),

                    ),

                    const SizedBox(height: 8),

                    Text(

                      widget.holiday.description,

                      maxLines: 2,

                      overflow:
                      TextOverflow.ellipsis,

                    ),

                    const SizedBox(height: 12),

                    Row(

                      children: [

                        Icon(

                          Icons.flag,

                          size: 18,

                          color:
                          Colors.orange.shade700,

                        ),

                        const SizedBox(width: 6),

                        Expanded(

                          child: Text(

                            widget.holiday.holidayType,

                            overflow:
                            TextOverflow
                                .ellipsis,

                            style:
                            const TextStyle(

                              fontWeight:
                              FontWeight.w600,

                            ),

                          ),

                        ),

                      ],

                    ),

                  ],

                ),

              ),

              //----------------------------------
              // Badge
              //----------------------------------

              Container(

                padding:
                const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),

                decoration: BoxDecoration(

                  color: widget.holiday.isOptional
                      ? Colors.blue
                      : Colors.green,

                  borderRadius:
                  BorderRadius.circular(20),

                ),

                child: Text(

                  widget.holiday.isOptional
                      ? "Optional"
                      : "Mandatory",

                  style:
                  const TextStyle(

                    color: Colors.white,

                    fontWeight:
                    FontWeight.bold,

                    fontSize: 11,

                  ),

                ),

              ),

            ],

          ),

        ),

      ),

    );

  }

}