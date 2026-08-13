  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter/services.dart';

  class GroupChatPage extends StatefulWidget {
    final String groupId;
    final String groupName;

    const GroupChatPage({
      super.key,
      required this.groupId,
      required this.groupName,
    });

    @override
    State<GroupChatPage> createState() => _GroupChatPageState();
  }

  class _GroupChatPageState extends State<GroupChatPage> {
    final FirebaseFirestore firestore =
        FirebaseFirestore.instance;

    final TextEditingController
    messageController =
    TextEditingController();

    final ScrollController
    scrollController =
    ScrollController();

    final FocusNode
    messageFocusNode =
    FocusNode();



    User? get currentUser =>
        FirebaseAuth.instance.currentUser;

    Future<void> sendMessage() async {
      final text =
      messageController.text.trim();

      if (text.isEmpty ||
          currentUser == null) {
        return;
      }

      // Clear textbox immediately
      messageController.clear();

      messageFocusNode.requestFocus();

      setState(() {});

      final messageRef = firestore
          .collection('group_chats')
          .doc(widget.groupId)
          .collection('messages')
          .doc();

      await messageRef.set({
        'senderId': currentUser!.uid,
        'senderName':
        currentUser!.displayName ??
            'Employee',
        'text': text,
        'messageType': 'text',
        'status': 'sent',
        'edited': false,
        'deleted': false,
        'createdAt':
        FieldValue.serverTimestamp(),
      });

      await firestore
          .collection('group_chats')
          .doc(widget.groupId)
          .update({
        'lastMessage': text,
        'lastMessageSender':
        currentUser!.displayName ??
            'Employee',
        'lastMessageTime':
        FieldValue.serverTimestamp(),
      });

      Future.delayed(
        const Duration(milliseconds: 100),
            () {
          if (scrollController.hasClients) {
            scrollController.animateTo(
              scrollController.position.maxScrollExtent,
              duration: const Duration(
                milliseconds: 300,
              ),
              curve: Curves.easeOut,
            );
          }
        },
      );
    }

    String formatTime(
        Timestamp? timestamp) {
      if (timestamp == null) {
        return '';
      }

      final date = timestamp.toDate();

      return TimeOfDay.fromDateTime(date)
          .format(context);
    }

    Future<void> _editMessage(
        String messageId,
        String currentText,
        ) async {
      final controller =
      TextEditingController(
        text: currentText,
      );

      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title:
            const Text("Edit Message"),
            content: TextField(
              controller: controller,
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child:
                const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  await firestore
                      .collection(
                      'group_chats')
                      .doc(widget.groupId)
                      .collection(
                      'messages')
                      .doc(messageId)
                      .update({
                    'text':
                    controller.text.trim(),
                    'edited': true,
                  });

                  if (mounted) {
                    Navigator.pop(
                        context);
                  }
                },
                child:
                const Text("Save"),
              ),
            ],
          );
        },
      );
    }


    void _showMessageOptions(
        String messageId,
        Map<String, dynamic> data,
        bool isMe,
        ) {
      showModalBottomSheet(
        context: context,
        builder: (_) {
          return SafeArea(
            child: Column(
              mainAxisSize:
              MainAxisSize.min,
              children: [
                ListTile(
                  leading:
                  const Icon(Icons.copy),
                  title:
                  const Text("Copy"),
                  onTap: () {
                    Clipboard.setData(
                      ClipboardData(
                        text:
                        data['text'] ??
                            '',
                      ),
                    );

                    Navigator.pop(
                        context);
                  },
                ),

                if (isMe)
                  ListTile(
                    leading:
                    const Icon(
                        Icons.edit),
                    title: const Text(
                        "Edit Message"),
                    onTap: () {
                      Navigator.pop(
                          context);

                      _editMessage(
                        messageId,
                        data['text'] ??
                            '',
                      );
                    },
                  ),

                if (isMe)
                  ListTile(
                    leading: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    title: const Text(
                        "Delete Message"),
                    onTap: () async {
                      Navigator.pop(
                          context);

                      await firestore
                          .collection(
                          'group_chats')
                          .doc(widget
                          .groupId)
                          .collection(
                          'messages')
                          .doc(messageId)
                          .update({
                        'deleted': true,
                        'text': '',
                        'status': 'deleted',
                      });
                    },
                  ),
              ],
            ),
          );
        },
      );
    }

    @override
    void dispose() {
      messageController.dispose();
      scrollController.dispose();
      messageFocusNode.dispose();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor:
        const Color(0xFFF8FAFC),

        appBar: AppBar(
          elevation: 0,
          backgroundColor:
          Colors.white,
          surfaceTintColor:
          Colors.white,

          title: Column(
            crossAxisAlignment:
            CrossAxisAlignment
                .start,
            children: [
              Text(
                widget.groupName,
                style:
                const TextStyle(
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('group_chats')
                    .doc(widget.groupId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData ||
                      !snapshot.data!.exists) {
                    return const SizedBox();
                  }

                  final data =
                  snapshot.data!.data()
                  as Map<String, dynamic>;

                  final members =
                  List<String>.from(
                    data['members'] ?? [],
                  );

                  if (!members.contains(
                    currentUser?.uid,
                  )) {
                    return const Text(
                      'Access Denied',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                      ),
                    );
                  }

                  return Text(
                    '${members.length} Members',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ],
          ),


        ),

        body: Column(
          children: [
            Expanded(
              child: StreamBuilder<
                  QuerySnapshot>(
                stream: firestore
                    .collection(
                    'group_chats')
                    .doc(widget.groupId)
                    .collection(
                    'messages')
                    .orderBy(
                  'createdAt',
                  descending:
                  false,
                )
                    .snapshots(),
                builder:
                    (context, snapshot) {
                  if (!snapshot
                      .hasData) {
                    return const Center(
                      child:
                      CircularProgressIndicator(),
                    );
                  }

                  final messages =
                      snapshot
                          .data!
                          .docs;

                  if (messages
                      .isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                        children: [
                          Icon(
                            Icons.groups,
                            size: 70,
                            color:
                            Colors.grey,
                          ),
                          SizedBox(
                              height:
                              10),
                          Column(
                            children: [
                              const Text(
                                "Start your team conversation",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Messages sent here are visible to all group members.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }

                  WidgetsBinding
                      .instance
                      .addPostFrameCallback(
                          (_) {
                        if (scrollController
                            .hasClients) {
                          scrollController
                              .jumpTo(
                            scrollController
                                .position
                                .maxScrollExtent,
                          );
                        }
                      });

                  return ListView.builder(
                    controller:
                    scrollController,
                    padding:
                    const EdgeInsets
                        .all(16),
                    itemCount:
                    messages.length,
                    itemBuilder:
                        (context,
                        index) {
                      final doc =
                      messages[index];

                      final data =
                      doc.data()
                      as Map<String,
                          dynamic>;

                      final isMe =
                          data['senderId'] ==
                              currentUser
                                  ?.uid;

                      return Align(
                        alignment: isMe
                            ? Alignment
                            .centerRight
                            : Alignment
                            .centerLeft,
                        child:
                        GestureDetector(
                          onLongPress:
                              () {
                            _showMessageOptions(
                              doc.id,
                              data,
                              isMe,
                            );
                          },
                          child:
                          Container(
                            margin:
                            const EdgeInsets
                                .only(
                              bottom:
                              10,
                            ),
                            padding:
                            const EdgeInsets
                                .all(
                              12,
                            ),
                            constraints:
                            const BoxConstraints(
                              maxWidth:
                              320,
                            ),
                            decoration: BoxDecoration(
                              color: isMe
                                  ? const Color(0xFFDCF8C6)
                                  : Colors.white,
                              borderRadius:
                              BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child:
                            Column(
                              crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                              children: [
                                if (!isMe) ...[
                                  Builder(
                                    builder: (_) {
                                      final senderName =
                                          data['senderName'] ?? '';

                                      return Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 12,
                                            backgroundColor:
                                            Colors.blue.shade100,
                                            child: Text(
                                              senderName.isNotEmpty
                                                  ? senderName[0]
                                                  .toUpperCase()
                                                  : 'E',
                                              style:
                                              const TextStyle(
                                                fontSize: 11,
                                                fontWeight:
                                                FontWeight.bold,
                                              ),
                                            ),
                                          ),

                                          const SizedBox(width: 6),

                                          Expanded(
                                            child: Text(
                                              senderName,
                                              overflow:
                                              TextOverflow.ellipsis,
                                              style:
                                              const TextStyle(
                                                fontWeight:
                                                FontWeight.bold,
                                                color: Colors.blue,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),

                                  const SizedBox(height: 6),
                                ],

                                Text(
                                  data['deleted'] == true
                                      ? '🚫 Message deleted'
                                      : data['text'] ?? '',
                                  style: TextStyle(
                                    color: data['deleted'] == true
                                        ? Colors.grey
                                        : Colors.black87,
                                    fontSize: 15,
                                    height: 1.4,
                                    fontStyle:
                                    data['deleted'] == true
                                        ? FontStyle.italic
                                        : FontStyle.normal,
                                  ),
                                ),

                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.end,
                                  children: [
                                    if (data['edited'] == true)
                                      const Text(
                                        'edited',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                        ),
                                      ),

                                    if (data['edited'] == true)
                                      const SizedBox(width: 5),

                                    Text(
                                      formatTime(
                                        data['createdAt']
                                        as Timestamp?,
                                      ),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),

                                    if (isMe) ...[
                                      const SizedBox(width: 4),

                                      Icon(
                                        data['status'] == 'read'
                                            ? Icons.done_all
                                            : data['status'] ==
                                            'delivered'
                                            ? Icons.done_all
                                            : Icons.done,
                                        size: 16,
                                        color:
                                        data['status'] ==
                                            'read'
                                            ? Colors.blue
                                            : Colors.grey,
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            SafeArea(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(
                  12,
                  8,
                  12,
                  8,
                ),
                child: Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller:
                        messageController,
                        focusNode:
                        messageFocusNode,

                        textCapitalization:
                        TextCapitalization
                            .sentences,

                        keyboardType:
                        TextInputType.multiline,

                        textInputAction:
                        TextInputAction.newline,

                        minLines: 1,
                        maxLines: 5,

                        decoration:
                        InputDecoration(
                          hintText:
                          "Type a message...",
                          hintStyle: TextStyle(
                            color:
                            Colors.grey.shade600,
                          ),

                          contentPadding:
                          const EdgeInsets
                              .symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),

                          filled: true,
                          fillColor:
                          Colors.grey.shade100,

                          border:
                          OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(
                              24,
                            ),
                            borderSide:
                            BorderSide.none,
                          ),

                          enabledBorder:
                          OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(
                              24,
                            ),
                            borderSide:
                            BorderSide.none,
                          ),

                          focusedBorder:
                          OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(
                              24,
                            ),
                            borderSide:
                            const BorderSide(
                              color: Colors.blue,
                              width: 1,
                            ),
                          ),
                        ),

                        onSubmitted: (_) async {
                          if (messageController.text
                              .trim()
                              .isEmpty) {
                            return;
                          }

                          await sendMessage();
                        },                     ),
                    ),

                    const SizedBox(width: 8),

                    Container(
                      decoration:
                      const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () async {
                          if (messageController.text
                              .trim()
                              .isEmpty) {
                            return;
                          }

                          await sendMessage();
                        },
                        icon: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      );
    }
  }