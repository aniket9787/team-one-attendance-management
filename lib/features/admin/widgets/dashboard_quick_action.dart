import 'package:flutter/material.dart';

class DashboardQuickAction extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const DashboardQuickAction({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<DashboardQuickAction> createState() =>
      _DashboardQuickActionState();
}

class _DashboardQuickActionState
    extends State<DashboardQuickAction> {

  bool hovered = false;

  @override
  Widget build(BuildContext context) {

    final width = MediaQuery.of(context).size.width;

    final bool isSmallPhone = width < 380;
    final bool isPhone = width < 600;
    final bool isTablet = width >= 600 && width < 1000;

    return AnimatedScale(

      duration: const Duration(milliseconds: 180),

      scale: hovered ? 1.02 : 1,

      child: InkWell(

        onTap: widget.onTap,

        borderRadius: BorderRadius.circular(22),

        onHover: (value) {

          setState(() {

            hovered = value;

          });

        },

        child: AnimatedContainer(

          duration: const Duration(milliseconds: 250),

          padding: EdgeInsets.all(

            isSmallPhone
                ? 10
                : isPhone
                ? 12
                : isTablet
                ? 16
                : 18,

          ),

          decoration: BoxDecoration(

            color: Colors.white,

            borderRadius: BorderRadius.circular(22),

            border: Border.all(

              color: hovered
                  ? widget.color
                  : Colors.grey.shade200,

            ),

            boxShadow: [

              BoxShadow(

                color: widget.color.withOpacity(

                  hovered ? .18 : .08,

                ),

                blurRadius: hovered ? 16 : 8,

                offset: const Offset(0, 5),

              ),

            ],

          ),

          child: LayoutBuilder(

            builder: (context, constraints) {

              return Column(

                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  //--------------------------------
                  // Icon
                  //--------------------------------

                  Container(

                    padding: EdgeInsets.all(

                      isSmallPhone ? 8 : 10,

                    ),

                    decoration: BoxDecoration(

                      color:
                      widget.color.withOpacity(.12),

                      borderRadius:
                      BorderRadius.circular(14),

                    ),

                    child: Icon(

                      widget.icon,

                      color: widget.color,

                      size: isSmallPhone
                          ? 22
                          : isPhone
                          ? 24
                          : 28,

                    ),

                  ),

                  const Spacer(),

                  //--------------------------------
                  // Title
                  //--------------------------------

                  Text(

                    widget.title,

                    maxLines: 2,

                    overflow: TextOverflow.ellipsis,

                    style: TextStyle(

                      fontSize: isSmallPhone
                          ? 13
                          : isPhone
                          ? 14
                          : 16,

                      fontWeight: FontWeight.bold,

                    ),

                  ),

                  const SizedBox(height: 3),

                  //--------------------------------
                  // Subtitle
                  //--------------------------------

                  Flexible(

                    child: Text(

                      widget.subtitle,

                      maxLines: 2,

                      overflow: TextOverflow.ellipsis,

                      style: TextStyle(

                        fontSize: isSmallPhone
                            ? 10
                            : 11,

                        color: Colors.grey.shade600,

                      ),

                    ),

                  ),

                  const SizedBox(height: 6),

                  //--------------------------------
                  // Bottom Row
                  //--------------------------------

                  Row(

                    children: [

                      Expanded(

                        child: Text(

                          "Open",

                          overflow: TextOverflow.ellipsis,

                          style: TextStyle(

                            color: widget.color,

                            fontWeight: FontWeight.bold,

                            fontSize: isSmallPhone
                                ? 11
                                : 12,

                          ),

                        ),

                      ),

                      AnimatedContainer(

                        duration: const Duration(

                          milliseconds: 250,

                        ),

                        padding: EdgeInsets.all(

                          isSmallPhone ? 5 : 6,

                        ),

                        decoration: BoxDecoration(

                          color: hovered
                              ? widget.color
                              : Colors.grey.shade100,

                          shape: BoxShape.circle,

                        ),

                        child: Icon(

                          Icons.arrow_forward,

                          size: isSmallPhone
                              ? 14
                              : 16,

                          color: hovered
                              ? Colors.white
                              : widget.color,

                        ),

                      ),

                    ],

                  ),

                ],

              );

            },

          ),

        ),

      ),

    );

  }

}