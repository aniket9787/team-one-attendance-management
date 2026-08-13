import 'package:flutter/material.dart';

class DashboardChatCard extends StatefulWidget {
  final int totalMembers;
  final int onlineMembers;
  final int unreadMessages;
  final String lastMessage;
  final String lastMessageTime;
  final VoidCallback? onTap;

  const DashboardChatCard({
    super.key,
    required this.totalMembers,
    required this.onlineMembers,
    required this.unreadMessages,
    required this.lastMessage,
    required this.lastMessageTime,
    this.onTap,
  });

  @override
  State<DashboardChatCard> createState() =>
      _DashboardChatCardState();
}

class _DashboardChatCardState
    extends State<DashboardChatCard> {

  bool hovered = false;

  @override
  Widget build(BuildContext context) {

    final width = MediaQuery.of(context).size.width;

    final bool isPhone = width < 600;

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
          EdgeInsets.all(
            isPhone ? 16 : 20,
          ),

          decoration: BoxDecoration(

            color: Colors.white,

            borderRadius:
            BorderRadius.circular(20),

            border: Border.all(

              color: hovered
                  ? Colors.blue
                  : Colors.grey.shade200,

            ),

            boxShadow: [

              BoxShadow(

                color:
                Colors.blue.withOpacity(
                  hovered ? .15 : .08,
                ),

                blurRadius:
                hovered ? 20 : 10,

                offset:
                const Offset(0, 6),

              ),

            ],

          ),

          child: Column(

            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [

              //--------------------------------
              // Header
              //--------------------------------

              Row(

                children: [

                  Container(

                    padding:
                    const EdgeInsets.all(14),

                    decoration:
                    BoxDecoration(

                      color:
                      Colors.blue.shade50,

                      borderRadius:
                      BorderRadius.circular(16),

                    ),

                    child: const Icon(

                      Icons.groups_rounded,

                      color: Colors.blue,

                      size: 32,

                    ),

                  ),

                  const SizedBox(width: 16),

                  Expanded(

                    child: Column(

                      crossAxisAlignment:
                      CrossAxisAlignment.start,

                      children: [

                        Text(

                          "Company Group",

                          style: TextStyle(

                            fontSize:
                            isPhone
                                ? 18
                                : 21,

                            fontWeight:
                            FontWeight.bold,

                          ),

                        ),

                        const SizedBox(height: 4),

                        Text(

                          "${widget.totalMembers} Members",

                          style: TextStyle(

                            color:
                            Colors.grey.shade600,

                          ),

                        ),

                      ],

                    ),

                  ),

                  if (widget.unreadMessages > 0)

                    CircleAvatar(

                      radius: 14,

                      backgroundColor:
                      Colors.red,

                      child: Text(

                        widget.unreadMessages
                            .toString(),

                        style:
                        const TextStyle(

                          color:
                          Colors.white,

                          fontWeight:
                          FontWeight.bold,

                          fontSize: 12,

                        ),

                      ),

                    ),

                ],

              ),

              const SizedBox(height: 18),

              //--------------------------------
              // Online Users
              //--------------------------------

              Row(

                children: [

                  const Icon(

                    Icons.circle,

                    color: Colors.green,

                    size: 12,

                  ),

                  const SizedBox(width: 8),

                  Text(

                    "${widget.onlineMembers} Members Online",

                    style: const TextStyle(

                      fontWeight:
                      FontWeight.w600,

                    ),

                  ),

                ],

              ),

              const SizedBox(height: 14),

              //--------------------------------
              // Last Message
              //--------------------------------

              Text(

                widget.lastMessage,

                maxLines: 2,

                overflow:
                TextOverflow.ellipsis,

                style: TextStyle(

                  color:
                  Colors.grey.shade700,

                ),

              ),

              const SizedBox(height: 10),

              Row(

                children: [

                  Icon(

                    Icons.access_time,

                    size: 16,

                    color:
                    Colors.grey.shade600,

                  ),

                  const SizedBox(width: 6),

                  Text(

                    widget.lastMessageTime,

                    style: TextStyle(

                      color:
                      Colors.grey.shade600,

                    ),

                  ),

                ],

              ),

              const SizedBox(height: 18),

              //--------------------------------
              // Open Chat Button
              //--------------------------------

              SizedBox(

                width: double.infinity,

                child: ElevatedButton.icon(

                  onPressed: widget.onTap,

                  icon: const Icon(
                    Icons.chat_bubble,
                  ),

                  label: const Text(
                    "Open Company Chat",
                  ),

                  style:
                  ElevatedButton.styleFrom(

                    backgroundColor:
                    Colors.blue,

                    foregroundColor:
                    Colors.white,

                    padding:
                    const EdgeInsets.symmetric(
                      vertical: 14,
                    ),

                    shape:
                    RoundedRectangleBorder(

                      borderRadius:
                      BorderRadius.circular(
                        14,
                      ),

                    ),

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