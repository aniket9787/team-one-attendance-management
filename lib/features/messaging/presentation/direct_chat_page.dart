
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/chat_service.dart';
import '../widgets/online_status_widget.dart';

class DirectChatPage extends StatefulWidget {
final String chatId;
final String otherUserId;
final String otherUserName;

const DirectChatPage({
super.key,
required this.chatId,
required this.otherUserId,
required this.otherUserName,
});

@override
State<DirectChatPage> createState() =>
_DirectChatPageState();
}

class _DirectChatPageState
extends State<DirectChatPage> {

final ChatService chatService =
ChatService();

final TextEditingController
messageController =
TextEditingController();

final ScrollController
scrollController =
ScrollController();

final currentUser =
FirebaseAuth.instance.currentUser;

@override
void initState() {
  super.initState();

  _resetUnreadCount();

  _markMessagesAsRead();

  chatService.updateLastSeen(
    chatId: widget.chatId,
    userId: currentUser!.uid,
  );
}

Future<void> _resetUnreadCount() async {
try {
await FirebaseFirestore.instance
    .collection('direct_chats')
    .doc(widget.chatId)
    .update({
'unreadCount.${currentUser?.uid}':
0,
});
} catch (_) {}
}

Future<void> _markMessagesAsRead() async {
  final snapshot = await FirebaseFirestore
      .instance
      .collection('direct_chats')
      .doc(widget.chatId)
      .collection('messages')
      .where(
    'senderId',
    isNotEqualTo: currentUser!.uid,
  )
      .get();

  for (final doc in snapshot.docs) {
    final data = doc.data();

    if (data['status'] != 'read') {
      await doc.reference.update({
        'status': 'read',
        'seen': true,
        'seenAt':
        FieldValue.serverTimestamp(),
      });
    }
  }
}

Future<void> sendMessage() async {
final text =
messageController.text.trim();

if (text.isEmpty) return;

await chatService.sendMessage(
  chatId: widget.chatId,
  senderId: currentUser!.uid,
  senderName:
  currentUser?.displayName ??
      "Employee",
  text: text,
);

await chatService.updateTypingStatus(
  chatId: widget.chatId,
  userId: currentUser!.uid,
  isTyping: false,
);

messageController.clear();

Future.delayed(
const Duration(milliseconds: 100),
() {
if (scrollController
    .hasClients) {
scrollController.animateTo(
scrollController
    .position
    .maxScrollExtent,
duration:
const Duration(
milliseconds: 300,
),
curve: Curves.easeOut,
);
}
},
);
}

String formatMessageTime(
Timestamp? timestamp) {
if (timestamp == null) {
return '';
}

final date =
timestamp.toDate();

return TimeOfDay.fromDateTime(
date,
).format(context);
}

@override
void dispose() {

  chatService.updateTypingStatus(
    chatId: widget.chatId,
    userId: currentUser!.uid,
    isTyping: false,
  );

  messageController.dispose();
  scrollController.dispose();

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

titleSpacing: 0,

title: Row(
children: [

CircleAvatar(
radius: 20,
child: Text(
widget.otherUserName
    .isNotEmpty
? widget
    .otherUserName[0]
    .toUpperCase()
    : "E",
),
),

const SizedBox(
width: 12,
),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment
    .start,
children: [

Text(
widget
    .otherUserName,
style:
const TextStyle(
fontSize: 16,
fontWeight:
FontWeight
    .bold,
),
),
  OnlineStatusWidget(
    userId: widget.otherUserId,
  ),
],
),
),
],
),
),

body: Column(
children: [

Expanded(
child: StreamBuilder<
QuerySnapshot>(
stream: chatService
    .messagesStream(
widget.chatId,
),

builder: (
context,
snapshot,
) {

if (snapshot.hasError) {
return Center(
child: Text(
snapshot.error
    .toString(),
),
);
}

if (!snapshot.hasData) {
return const Center(
child:
CircularProgressIndicator(),
);
}

final messages =
snapshot
    .data!.docs;

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
},
);

return ListView.builder(
controller:
scrollController,

padding:
const EdgeInsets
    .all(16),

itemCount:
messages.length,

itemBuilder:
(
context,
index,
) {

final message =
messages[index];

final data =
message.data()
as Map<
String,
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
message.id,
data,
isMe,
);
},

child:
Container(
margin:
const EdgeInsets
    .only(
bottom: 10,
),

padding:
const EdgeInsets
    .all(
12,
),

constraints:
const BoxConstraints(
maxWidth:
300,
),

decoration:
BoxDecoration(
color: isMe
? const Color(
0xFFDCF8C6,
)
    : Colors
    .white,

borderRadius:
BorderRadius.circular(
18,
),

boxShadow: [
BoxShadow(
color: Colors
    .black
    .withOpacity(
0.05,
),
blurRadius:
8,
offset:
const Offset(
0,
2,
),
),
],
),

child:
Column(
crossAxisAlignment:
CrossAxisAlignment
    .start,
children: [

  Text(
    data['deleted'] == true
        ? "🚫 This message was deleted"
        : data['text'] ?? '',
    style: TextStyle(
      color: data['deleted'] == true
          ? Colors.grey.shade600
          : Colors.black87,
      fontSize: 15,
      fontStyle: data['deleted'] == true
          ? FontStyle.italic
          : FontStyle.normal,
    ),
  ),
const SizedBox(
height:
6,
),

Row(
mainAxisSize:
MainAxisSize
    .min,
children: [

if (data[
'edited'] ==
true)
const Text(
"edited",
style:
TextStyle(
fontSize:
10,
color:
Colors.grey,
),
),

const SizedBox(
width:
6,
),

Text(
formatMessageTime(
data['createdAt']
as Timestamp?,
),
style:
const TextStyle(
fontSize:
11,
color:
Colors.grey,
),
),

  if (isMe)
    Padding(
      padding: const EdgeInsets.only(
        left: 4,
      ),
      child: Builder(
        builder: (context) {
          switch (data['status']) {
            case 'read':
              return const Icon(
                Icons.done_all,
                size: 16,
                color: Colors.blue,
              );

            case 'delivered':
              return const Icon(
                Icons.done_all,
                size: 16,
                color: Colors.grey,
              );

            default:
              return const Icon(
                Icons.done,
                size: 16,
                color: Colors.grey,
              );
          }
        },
      ),
    ),
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

  StreamBuilder<DocumentSnapshot>(
    stream: chatService.chatStream(
      widget.chatId,
    ),
    builder: (context, snapshot) {

      if (!snapshot.hasData) {
        return const SizedBox();
      }

      final data =
      snapshot.data!.data()
      as Map<String, dynamic>?;

      if (data == null) {
        return const SizedBox();
      }

      final typing =
      Map<String, dynamic>.from(
        data['typing'] ?? {},
      );

      final isTyping =
          typing[widget.otherUserId] ?? false;

      if (!isTyping) {
        return const SizedBox();
      }

      return Padding(
        padding: const EdgeInsets.only(
          left: 16,
          bottom: 8,
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius:
              BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.edit,
                  size: 14,
                  color: Colors.green,
                ),

                const SizedBox(width: 6),

                Text(
                  "${widget.otherUserName} is typing...",
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  ),

  Container(
    padding: const EdgeInsets.fromLTRB(
      12,
      8,
      12,
      12,
    ),
    decoration: const BoxDecoration(
      color: Colors.white,
    ),

    child: Row(
      children: [

IconButton(
onPressed: () {},
icon: const Icon(
Icons
    .emoji_emotions_outlined,
),
),

Expanded(
child: TextField(
  controller:
  messageController,

  onChanged: (value) {
    chatService.updateTypingStatus(
      chatId: widget.chatId,
      userId: currentUser!.uid,
      isTyping: value.isNotEmpty,
    );
  },

  minLines: 1,
  maxLines: 5,

decoration:
InputDecoration(
hintText:
"Type a message",

filled: true,

fillColor:
Colors.grey
    .shade100,

border:
OutlineInputBorder(
borderRadius:
BorderRadius.circular(
30,
),
borderSide:
BorderSide.none,
),

enabledBorder:
OutlineInputBorder(
borderRadius:
BorderRadius.circular(
30,
),
borderSide:
BorderSide.none,
),
),
),
),

const SizedBox(
width: 8,
),

Container(
decoration:
BoxDecoration(
color:
Theme.of(
context,
)
    .colorScheme
    .primary,
shape: BoxShape
    .circle,
),
child: IconButton(
onPressed:
sendMessage,
icon:
const Icon(
Icons
    .send_rounded,
color:
Colors.white,
),
),
),
],
),
),
],
),
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
const Icon(
Icons.copy,
),
title:
const Text(
"Copy",
),
onTap: () {

Clipboard.setData(
ClipboardData(
text:
data['text'] ??
'',
),
);

Navigator.pop(
context,
);
},
),

if (isMe)
ListTile(
leading:
const Icon(
Icons.edit,
),
title:
const Text(
"Edit Message",
),
onTap: () {
Navigator.pop(
context,
);

_editMessage(
messageId,
data['text'] ??
'',
);
},
),

if (isMe)
ListTile(
leading:
const Icon(
Icons.delete,
color:
Colors.red,
),
title:
const Text(
"Delete Message",
),
onTap:
() async {

Navigator.pop(
context,
);

await chatService
    .deleteMessage(
chatId:
widget
    .chatId,
messageId:
messageId,
);
},
),
],
),
);
},
);
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
title: const Text(
"Edit Message",
),

content: TextField(
controller:
controller,
autofocus: true,
),

actions: [

TextButton(
onPressed: () {
Navigator.pop(
context,
);
},
child:
const Text(
"Cancel",
),
),

ElevatedButton(
onPressed:
() async {

await chatService
    .editMessage(
chatId:
widget.chatId,
messageId:
messageId,
newText:
controller
    .text
    .trim(),
);

if (mounted) {
Navigator.pop(
context,
);
}
},
child:
const Text(
"Save",
),
),
],
);
},
);
}
}
