import 'package:flutter/material.dart';

class DashboardStatCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const DashboardStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  State<DashboardStatCard> createState() =>
      _DashboardStatCardState();
}

class _DashboardStatCardState
    extends State<DashboardStatCard> {

  bool hovered = false;

  @override
  Widget build(BuildContext context) {

    final width = MediaQuery.of(context).size.width;

    final isPhone = width < 600;
    final isSmallPhone = width < 380;

    return AnimatedScale(
      duration: const Duration(milliseconds: 180),
      scale: hovered ? 1.02 : 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: widget.onTap,
        onHover: (value) {
          setState(() {
            hovered = value;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),

          padding: EdgeInsets.all(
            isSmallPhone
                ? 12
                : isPhone
                ? 14
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
                color: widget.color.withOpacity(.12),
                blurRadius: hovered ? 18 : 10,
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

                  //-----------------------------------
                  // Top Row
                  //-----------------------------------

                  Row(

                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,

                    children: [

                      Container(

                        padding: EdgeInsets.all(
                          isSmallPhone ? 8 : 10,
                        ),

                        decoration: BoxDecoration(

                          color:
                          widget.color.withOpacity(.12),

                          borderRadius:
                          BorderRadius.circular(12),

                        ),

                        child: Icon(

                          widget.icon,

                          color: widget.color,

                          size: isSmallPhone
                              ? 20
                              : isPhone
                              ? 22
                              : 26,

                        ),

                      ),

                      Icon(
                        Icons.trending_up,
                        color: Colors.green,
                        size: isSmallPhone ? 16 : 20,
                      ),
                    ],
                  ),

                  const Spacer(),

                  //-----------------------------------
                  // Value
                  //-----------------------------------

                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.value,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: isSmallPhone
                            ? 22
                            : isPhone
                            ? 26
                            : 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 4),

                  //-----------------------------------
                  // Title
                  //-----------------------------------

                  Flexible(
                    child: Text(
                      widget.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isSmallPhone
                            ? 11
                            : isPhone
                            ? 13
                            : 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
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