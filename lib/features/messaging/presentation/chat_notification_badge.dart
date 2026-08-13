
  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:flutter/material.dart';

  class ChatNotificationBadge extends StatelessWidget {
  final Widget child;

  const ChatNotificationBadge({
  super.key,
  required this.child,
  });

  @override
  Widget build(BuildContext context) {
  final user =
  FirebaseAuth.instance.currentUser;

  if (user == null) {
  return child;
  }

  return StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
      .collection('direct_chats')
      .where(
  'participants',
  arrayContains: user.uid,
  )
      .snapshots(),
  builder: (
  context,
  snapshot,
  ) {
  int unreadCount = 0;

  if (snapshot.hasData) {
  for (final doc
  in snapshot.data!.docs) {
  final data =
  doc.data()
  as Map<String, dynamic>;

  final unread =
  (data['unreadCount']
  as Map<
  String,
  dynamic>?)?[
  user.uid] ??
  0;

  unreadCount +=
  unread as int;
  }
  }

  return Stack(
  clipBehavior: Clip.none,
  children: [
  child,

  if (unreadCount > 0)
  Positioned(
  top: -6,
  right: -6,
  child: Container(
  constraints:
  const BoxConstraints(
  minWidth: 20,
  minHeight: 20,
  ),
  padding:
  const EdgeInsets
      .symmetric(
  horizontal: 6,
  vertical: 2,
  ),
  decoration:
  BoxDecoration(
  color: Colors.red,
  borderRadius:
  BorderRadius
      .circular(
  20,
  ),
  border: Border.all(
  color:
  Colors.white,
  width: 2,
  ),
  ),
  child: Center(
  child: Text(
  unreadCount > 99
  ? '99+'
      : unreadCount
      .toString(),
  style:
  const TextStyle(
  color:
  Colors.white,
  fontSize: 11,
  fontWeight:
  FontWeight
      .bold,
  ),
  ),
  ),
  ),
  ),
  ],
  );
  },
  );
  }
  }
