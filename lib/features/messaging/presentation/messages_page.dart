
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../data/chat_service.dart';
import '../widgets/online_status_widget.dart';
import 'create_group_page.dart';
import 'direct_chat_page.dart';
import 'group_chat_page.dart';



class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final ChatService chatService = ChatService();

  final TextEditingController searchController =
  TextEditingController();

  String searchText = '';

  User? get currentUser =>
      FirebaseAuth.instance.currentUser;

  Future<void> _createGroup() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
        const CreateGroupPage(),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  String formatChatTime(DateTime date) {
    final now = DateTime.now();

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return TimeOfDay.fromDateTime(date)
          .format(context);
    }

    final yesterday =
    now.subtract(const Duration(days: 1));

    if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return "Yesterday";
    }

    return "${date.day}/${date.month}";
  }

  @override
  Widget build(BuildContext context) {

    final screenWidth =
        MediaQuery.of(context).size.width;

    final isDesktop =
        screenWidth >= 1000;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text("User not logged in"),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),

      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: chatService.getRecentChats(
            currentUser!.uid,
          ),
          builder: (context, chatSnapshot) {
            if (chatSnapshot.hasError) {
              return Center(
                child: Text(
                  chatSnapshot.error.toString(),
                ),
              );
            }

            if (!chatSnapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final chats =
                chatSnapshot.data!.docs;

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('employees')
                  .snapshots(),
              builder:
                  (context, employeeSnapshot) {
                if (!employeeSnapshot.hasData) {
                  return const Center(
                    child:
                    CircularProgressIndicator(),
                  );
                }

                final employees =
                    employeeSnapshot.data!.docs;

                return Center(
                    child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth:
                          isDesktop ? 850 : double.infinity,
                        ),
                        child: CustomScrollView(
                  slivers: [

                    SliverAppBar(
                      pinned: true,
                      elevation: 0,
                      backgroundColor:
                      const Color(
                        0xffF8FAFC,
                      ),
                      title: const Text(
                        "Messages",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      actions: [
                        PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.group,
                            color: Colors.black,
                          ),
                          onSelected: (value) {
                            if (value == 'company') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                  const GroupChatPage(
                                    groupId:
                                    'company_group',
                                    groupName:
                                    'Company Group',
                                  ),
                                ),
                              );
                            }

                            if (value == 'create') {
                              _createGroup();
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'company',
                              child: Text(
                                'Company Group',
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'create',
                              child: Text(
                                'Create Group',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal:
                          isDesktop ? 30 : 16,
                          vertical: 16,
                        ),
                        child: TextField(
                          controller:
                          searchController,
                          decoration:
                          InputDecoration(
                            hintText:
                            "Search chats or employees",
                            prefixIcon:
                            const Icon(
                              Icons.search,
                            ),
                            filled: true,
                            fillColor:
                            Colors.white,
                            border:
                            OutlineInputBorder(
                              borderRadius:
                              BorderRadius
                                  .circular(
                                30,
                              ),
                              borderSide:
                              BorderSide
                                  .none,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              searchText = value
                                  .toLowerCase()
                                  .trim();
                            });
                          },
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        child: Text(
                          "Groups",
                          style: TextStyle(
                            fontSize:
                            isDesktop ? 24 : 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),


                    SliverToBoxAdapter(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('group_chats')
                            .where(
                          'members',
                          arrayContains: currentUser!.uid,
                        )
                            .snapshots(),
                        builder: (context, snapshot) {

                          if (!snapshot.hasData) {
                            return const SizedBox.shrink();
                          }

                          final groups = snapshot.data!.docs;

                          if (groups.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            physics:
                            const NeverScrollableScrollPhysics(),
                            itemCount: groups.length,
                            itemBuilder: (context, index) {

                              final group = groups[index];

                              final data =
                              group.data()
                              as Map<String, dynamic>;

                              return Card(
                                clipBehavior: Clip.antiAlias,
                                margin:
                                const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                child: ListTile(
                                  leading: const CircleAvatar(
                                    child: Icon(
                                      Icons.groups,
                                    ),
                                  ),

                                  title: Text(
                                    data['groupName'] ??
                                        'Group',
                                  ),

                                  subtitle: Text(
                                    data['lastMessage'] ??
                                        'No messages yet',
                                    maxLines: 1,
                                    overflow:
                                    TextOverflow.ellipsis,
                                  ),

                                  trailing: Text(
                                    data['members'] != null
                                        ? '${(data['members']
                                    as List)
                                        .length} Members'
                                        : '',
                                    style:
                                    const TextStyle(
                                      fontSize: 11,
                                    ),
                                  ),

                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            GroupChatPage(
                                              groupId:
                                              group.id,
                                              groupName:
                                              data['groupName'] ??
                                                  'Group',
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding:
                        EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        child: Text(
                          "Recent Chats",
                          style: TextStyle(
                            fontSize:
                            isDesktop ? 24 : 20,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    SliverList(
                      delegate:
                      SliverChildBuilderDelegate(
                            (context, index) {
                          final chat =
                          chats[index];

                          final data =
                          chat.data()
                          as Map<String,
                              dynamic>;

                          final participants =
                          List<String>.from(
                            data[
                            'participants'] ??
                                [],
                          );

                          final names =
                          Map<String,
                              dynamic>.from(
                            data[
                            'participantNames'] ??
                                {},
                          );

                          final photos =
                          Map<String,
                              dynamic>.from(
                            data[
                            'participantPhotos'] ??
                                {},
                          );

                          final otherId =
                          participants
                              .firstWhere(
                                (id) =>
                            id !=
                                currentUser!
                                    .uid,
                            orElse: () => '',
                          );

                          final otherName =
                              names[otherId] ??
                                  "Employee";

                          final otherPhoto =
                              photos[otherId] ??
                                  "";

                          if (searchText
                              .isNotEmpty &&
                              !otherName
                                  .toLowerCase()
                                  .contains(
                                  searchText)) {
                            return const SizedBox.shrink();
                          }

                          String time = "";

                          if (data[
                          'lastMessageTime'] !=
                              null) {
                            time = formatChatTime(
                              (data[
                              'lastMessageTime']
                              as Timestamp)
                                  .toDate(),
                            );
                          }

                          return RecentChatTile(
                            userId: otherId,
                            image: otherPhoto,
                            name: otherName,
                            role: "",
                            message: data['lastMessage'] ?? "",
                            time: time,
                            unreadCount:
                            (data['unreadCount']
                            as Map<String, dynamic>?)?[
                            currentUser!.uid] ??
                                0,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      DirectChatPage(
                                        chatId:
                                        chat.id,
                                        otherUserId:
                                        otherId,
                                        otherUserName:
                                        otherName,
                                      ),
                                ),
                              );
                            },
                          );
                        },
                        childCount:
                        chats.length,
                      ),
                    ),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding:
                        EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        child: Text(
                          "Employees",
                          style: TextStyle(
                            fontSize:
                            isDesktop ? 24 : 20,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    SliverList(
                      delegate:
                      SliverChildBuilderDelegate(
                            (context, index) {
                          final employee =
                          employees[index];

                          final data =
                          employee.data()
                          as Map<String,
                              dynamic>;

                          final uid =
                              data['uid'] ??
                                  employee.id;

                          if (uid ==
                              currentUser!.uid) {
                            return const SizedBox.shrink();
                          }

                          final name =
                              data['name'] ??
                                  '';

                          final role =
                              data['role'] ??
                                  '';

                          final image =
                              data['profileImage'] ??
                                  '';

                          if (searchText
                              .isNotEmpty &&
                              !name
                                  .toLowerCase()
                                  .contains(
                                  searchText)) {
                            return const SizedBox.shrink();
                          }

                          return EmployeeTile(
                            image: image,
                            name: name,
                            role: role,
                            userId: uid,
                            onTap: () async {
                              final chatId =
                              await chatService
                                  .createDirectChat(
                                currentUserId:
                                currentUser!
                                    .uid,
                                currentUserName:
                                currentUser!
                                    .displayName ??
                                    "Employee",
                                currentUserPhoto:
                                currentUser!
                                    .photoURL ??
                                    "",
                                otherUserId:
                                uid,
                                otherUserName:
                                name,
                                otherUserPhoto:
                                image,
                              );

                              if (!mounted)
                                return;

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      DirectChatPage(
                                        chatId:
                                        chatId,
                                        otherUserId:
                                        uid,
                                        otherUserName:
                                        name,
                                      ),
                                ),
                              );
                            },
                          );
                        },
                        childCount:
                        employees.length,
                      ),
                    ),

                    SliverToBoxAdapter(
                      child:
                      SizedBox(height: 30),
                    ),
                  ],
                        ),
                    ),
                );

              },
            );
          },
        ),
      ),
    );
  }
}

class RecentChatTile extends StatelessWidget {
  final String image;
  final String name;
  final String role;
  final String message;
  final String time;
  final int unreadCount;
  final String userId;
  final VoidCallback onTap;

  const RecentChatTile({
    super.key,
    required this.image,
    required this.name,
    required this.role,
    required this.message,
    required this.time,
    required this.unreadCount,
    required this.userId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth =
        MediaQuery.of(context).size.width;

    final isMobile = screenWidth < 600;

    final isTablet =
        screenWidth >= 600 &&
            screenWidth < 1000;

    final isDesktop =
        screenWidth >= 1000;
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      margin: EdgeInsets.symmetric(
        horizontal:
        MediaQuery.of(context).size.width > 700
            ? 24
            : 16,
        vertical: 6,
      ),
      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius:
          MediaQuery.of(context).size.width > 700
              ? 32
              : 26,
          backgroundImage:
          image.isNotEmpty
              ? NetworkImage(image)
              : null,
          child: image.isEmpty
              ? Text(
            name.isNotEmpty
                ? name[0].toUpperCase()
                : 'E',
          )
              : null,
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            OnlineStatusWidget(
              userId: userId,
            ),

            const SizedBox(height: 4),

            Text(
              message,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            FittedBox(
              child: Text(
                time,
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
            ),              Container(
                margin:
                const EdgeInsets.only(
                  top: 4,
                ),
                padding:
                const EdgeInsets.all(6),
                decoration:
                const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                  ),
                ),
              ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

class EmployeeTile extends StatelessWidget {
  final String image;
  final String name;
  final String role;
  final String userId;
  final VoidCallback onTap;


  const EmployeeTile({
    super.key,
    required this.image,
    required this.name,
    required this.role,
    required this.userId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    final screenWidth =
        MediaQuery.of(context).size.width;

    final isDesktop =
        screenWidth >= 1000;
    return Card(
    clipBehavior: Clip.antiAlias,
      elevation: 1,
      margin: EdgeInsets.symmetric(
        horizontal:
        MediaQuery.of(context).size.width > 700
            ? 24
            : 16,
        vertical: 6,
      ),
      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius:
          MediaQuery.of(context).size.width > 700
              ? 32
              : 26,
          backgroundImage:
          image.isNotEmpty
              ? NetworkImage(image)
              : null,
          child: image.isEmpty
              ? Text(
            name.isNotEmpty
                ? name[0].toUpperCase()
                : 'E',
          )
              : null,
        ),
        title: Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              role,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 4),

            OnlineStatusWidget(
              userId: userId,
            ),
          ],
        ),
        trailing: const Icon(
          Icons.chat_bubble_outline,
        ),
        onTap: onTap,
      ),
    );
  }
}
