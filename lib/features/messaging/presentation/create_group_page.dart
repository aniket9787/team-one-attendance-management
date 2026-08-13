import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../data/chat_service.dart';
import 'group_chat_page.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() =>
      _CreateGroupPageState();
}

class _CreateGroupPageState
    extends State<CreateGroupPage> {
  final ChatService chatService =
  ChatService();

  final TextEditingController
  groupNameController =
  TextEditingController();

  final TextEditingController
  searchController =
  TextEditingController();

  final List<String> selectedUsers = [];

  String searchText = '';

  User? get currentUser =>
      FirebaseAuth.instance.currentUser;

  Future<void> createGroup() async {
    final groupName =
    groupNameController.text.trim();

    if (groupName.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Enter group name',
          ),
        ),
      );
      return;
    }

    if (selectedUsers.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Select at least one employee',
          ),
        ),
      );
      return;
    }

    final groupId =
    await chatService.createGroup(
      groupName: groupName,

      createdBy:
      currentUser!.uid,

      createdByName:
      currentUser!
          .displayName ??
          'Employee',

      memberIds:
      selectedUsers,
    );


    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => GroupChatPage(
          groupId: groupId,
          groupName: groupName,
        ),
      ),
    );
  }

  @override
  void dispose() {
    groupNameController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      const Color(0xFFF8FAFC),

      appBar: AppBar(
        title: const Text(
          'Create Group',
        ),
      ),

      body: Column(
        children: [
          Padding(
            padding:
            const EdgeInsets.all(16),
            child: TextField(
              controller:
              groupNameController,
              decoration:
              const InputDecoration(
                labelText:
                'Group Name',
                border:
                OutlineInputBorder(),
              ),
            ),
          ),

          Padding(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: TextField(
              controller:
              searchController,
              decoration:
              const InputDecoration(
                hintText:
                'Search employees',
                prefixIcon:
                Icon(Icons.search),
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

          const SizedBox(height: 10),

          Expanded(
            child:
            StreamBuilder<QuerySnapshot>(
              stream:
              FirebaseFirestore
                  .instance
                  .collection(
                  'employees')
                  .orderBy('name')
                  .snapshots(),
              builder:
                  (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child:
                    CircularProgressIndicator(),
                  );
                }

                final employees =
                    snapshot.data!.docs;

                return ListView.builder(
                  itemCount:
                  employees.length,
                  itemBuilder:
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
                      return const SizedBox();
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
                      return const SizedBox();
                    }

                    final selected =
                    selectedUsers
                        .contains(uid);

                    return CheckboxListTile(
                      value: selected,
                      onChanged: (value) {
                        setState(() {
                          if (value ==
                              true) {
                            if (!selectedUsers.contains(uid)) {
                              selectedUsers.add(uid);
                            }
                          } else {
                            selectedUsers
                                .remove(uid);
                          }
                        });
                      },

                      secondary:
                      CircleAvatar(
                        backgroundImage:
                        image.isNotEmpty
                            ? NetworkImage(
                            image)
                            : null,
                        child:
                        image.isEmpty
                            ? Text(
                          name
                              .isNotEmpty
                              ? name[
                          0]
                              .toUpperCase()
                              : 'E',
                        )
                            : null,
                      ),

                      title: Text(name),

                      subtitle:
                      Text(role),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton:
      FloatingActionButton.extended(
        onPressed: createGroup,
        icon:
        const Icon(Icons.groups),
        label: const Text(
          'Create Group',
        ),
      ),
    );
  }
}