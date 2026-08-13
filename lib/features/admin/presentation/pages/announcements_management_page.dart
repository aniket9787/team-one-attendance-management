
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AnnouncementsManagementPage extends StatefulWidget {
const AnnouncementsManagementPage({super.key});

@override
State<AnnouncementsManagementPage> createState() =>
_AnnouncementsManagementPageState();
}

class _AnnouncementsManagementPageState
extends State<AnnouncementsManagementPage> {

final titleController = TextEditingController();
final descriptionController = TextEditingController();

Future<void> addAnnouncement() async {
  if (titleController.text.trim().isEmpty ||
      descriptionController.text.trim().isEmpty) {
    return;
  }

  await FirebaseFirestore.instance
      .collection('announcements')
      .add({
    'title': titleController.text.trim(),
    'description':
    descriptionController.text.trim(),

    'priority': 'Normal',

    'isPinned': false,

    'createdBy': 'Admin',

    'isActive': true,

    'createdAt':
    FieldValue.serverTimestamp(),
  });

  titleController.clear();
  descriptionController.clear();

  if (mounted) {
    Navigator.pop(context);
  }
}
void showAddDialog() {
showDialog(
context: context,
builder: (_) {
return AlertDialog(
title: const Text(
"Add Announcement",
),

content: Column(
mainAxisSize: MainAxisSize.min,
children: [
TextField(
controller: titleController,
decoration:
const InputDecoration(
labelText: "Title",
),
),

const SizedBox(height: 10),

TextField(
controller:
descriptionController,
maxLines: 4,
decoration:
const InputDecoration(
labelText: "Description",
),
),
],
),

actions: [
TextButton(
onPressed: () {
Navigator.pop(context);
},
child: const Text(
"Cancel",
),
),

ElevatedButton(
onPressed: addAnnouncement,
child: const Text(
"Save",
),
),
],
);
},
);
}

Future<void> deleteAnnouncement(
    String id,
    ) async {
  final confirm =
  await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text(
        "Delete Announcement",
      ),
      content: const Text(
        "Are you sure you want to delete this announcement?",
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(
              context,
              false,
            );
          },
          child: const Text(
            "Cancel",
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(
              context,
              true,
            );
          },
          child: const Text(
            "Delete",
          ),
        ),
      ],
    ),
  );

  if (confirm == true) {
    await FirebaseFirestore.instance
        .collection('announcements')
        .doc(id)
        .delete();
  }
}


@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor:
const Color(0xFFF5F7FA),

appBar: AppBar(
title:
const Text("Announcements"),
),

floatingActionButton:
FloatingActionButton(
onPressed: showAddDialog,
child: const Icon(Icons.add),
),

body: StreamBuilder<QuerySnapshot>(
stream: FirebaseFirestore.instance
    .collection('announcements')
    .orderBy(
'createdAt',
descending: true,
)
    .snapshots(),

builder: (context, snapshot) {

if (snapshot.connectionState ==
ConnectionState.waiting) {
return const Center(
child:
CircularProgressIndicator(),
);
}

if (!snapshot.hasData ||
    snapshot.data!.docs.isEmpty) {
  return const Center(
    child: Column(
      mainAxisAlignment:
      MainAxisAlignment.center,
      children: [
        Icon(
          Icons.campaign_outlined,
          size: 70,
          color: Colors.grey,
        ),
        SizedBox(height: 10),
        Text(
          "No Announcements Available",
        ),
      ],
    ),
  );
}
final announcements =
snapshot.data!.docs;

return ListView.builder(
  padding: const EdgeInsets.all(15),

  itemCount: announcements.length,

  itemBuilder: (context, index) {
    final doc = announcements[index];

    final data =
    doc.data() as Map<String, dynamic>;

    final createdAt =
    data['createdAt'] as Timestamp?;

    final priority =
        data['priority'] ?? 'Normal';

    return Card(
      elevation: 3,
      margin:
      const EdgeInsets.only(
        bottom: 12,
      ),
      shape:
      RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(
          12,
        ),
      ),
      child: ListTile(
        contentPadding:
        const EdgeInsets.all(
          12,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                data['title'] ?? '',
                style:
                const TextStyle(
                  fontWeight:
                  FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Container(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration:
              BoxDecoration(
                color: priority ==
                    'Urgent'
                    ? Colors.red
                    : priority ==
                    'Important'
                    ? Colors.orange
                    : Colors.green,
                borderRadius:
                BorderRadius.circular(
                  20,
                ),
              ),
              child: Text(
                priority,
                style:
                const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 8,
            ),
            Text(
              data['description'] ?? '',
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 14,
                  color: Colors.grey,
                ),
                const SizedBox(
                  width: 4,
                ),
                Text(
                  createdAt != null
                      ? createdAt
                      .toDate()
                      .toString()
                      .split('.')
                      .first
                      : '',
                  style:
                  const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(
            Icons.delete_outline,
            color: Colors.red,
          ),
          onPressed: () {
            deleteAnnouncement(
              doc.id,
            );
          },
        ),
      ),
    );
  },
);
}, // <-- closes StreamBuilder builder
),
);
}
}