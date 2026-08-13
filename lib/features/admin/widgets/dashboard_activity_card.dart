import 'package:flutter/material.dart';

class DashboardActivityCard extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String time;
  final VoidCallback? onTap;

  const DashboardActivityCard({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.time,
    this.onTap,
  });

  @override
  State<DashboardActivityCard> createState() =>
      _DashboardActivityCardState();
}

class _DashboardActivityCardState
    extends State<DashboardActivityCard> {

  bool hovered = false;

  @override
  Widget build(BuildContext context) {

    final width = MediaQuery.of(context).size.width;

    final bool isPhone = width < 600;

    return AnimatedScale(

      duration: const Duration(milliseconds: 180),

      scale: hovered ? 1.01 : 1,

      child: InkWell(

        onTap: widget.onTap,

        borderRadius: BorderRadius.circular(20),

        onHover: (value) {

          setState(() {

            hovered = value;

          });

        },

        child: AnimatedContainer(

          duration: const Duration(milliseconds: 250),

          margin: const EdgeInsets.only(bottom: 14),

          padding: EdgeInsets.all(
            isPhone ? 16 : 20,
          ),

          decoration: BoxDecoration(

            color: Colors.white,

            borderRadius: BorderRadius.circular(20),

            border: Border.all(

              color: hovered
                  ? widget.color
                  : Colors.grey.shade200,

            ),

            boxShadow: [

              BoxShadow(

                color: widget.color.withOpacity(
                  hovered ? .15 : .08,
                ),

                blurRadius:
                hovered ? 18 : 10,

                offset: const Offset(0, 6),

              ),

            ],

          ),

          child: Row(

            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [

              //----------------------------------
              // Timeline Icon
              //----------------------------------

              Column(

                children: [

                  CircleAvatar(

                    radius:
                    isPhone ? 22 : 26,

                    backgroundColor:
                    widget.color.withOpacity(.12),

                    child: Icon(

                      widget.icon,

                      color: widget.color,

                      size:
                      isPhone ? 22 : 26,

                    ),

                  ),

                  Container(

                    width: 2,

                    height: 55,

                    color: Colors.grey.shade300,

                  ),

                ],

              ),

              const SizedBox(width: 18),

              //----------------------------------
              // Details
              //----------------------------------

              Expanded(

                child: Column(

                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    Row(

                      children: [

                        Expanded(

                          child: Text(

                            widget.title,

                            maxLines: 1,

                            overflow:
                            TextOverflow.ellipsis,

                            style: TextStyle(

                              fontSize:
                              isPhone ? 16 : 18,

                              fontWeight:
                              FontWeight.bold,

                            ),

                          ),

                        ),

                        Text(

                          widget.time,

                          style: TextStyle(

                            color:
                            Colors.grey.shade600,

                            fontSize:
                            isPhone ? 11 : 12,

                          ),

                        ),

                      ],

                    ),

                    const SizedBox(height: 8),

                    Text(

                      widget.subtitle,

                      maxLines: 2,

                      overflow:
                      TextOverflow.ellipsis,

                      style: TextStyle(

                        color:
                        Colors.grey.shade700,

                        fontSize:
                        isPhone ? 13 : 14,

                      ),

                    ),

                    const SizedBox(height: 14),

                    Row(

                      children: [

                        Text(

                          "View Details",

                          style: TextStyle(

                            color: widget.color,

                            fontWeight:
                            FontWeight.bold,

                          ),

                        ),

                        const SizedBox(width: 6),

                        Icon(

                          Icons.arrow_forward,

                          size: 18,

                          color: widget.color,

                        ),

                      ],

                    ),

                  ],

                ),

              ),

            ],

          ),

        ),

      ),

    );

  }

}