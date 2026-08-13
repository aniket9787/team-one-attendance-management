
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AnnouncementsPage extends StatelessWidget {
const AnnouncementsPage({super.key});

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: const Color(0xFFF5F7FA),

appBar: AppBar(
title: const Text(
"Announcements",
),
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

  if (snapshot.hasError) {
    return Center(
      child: Text(
        "Firestore Error:\n${snapshot.error}",
        textAlign: TextAlign.center,
      ),
    );
  }


if (snapshot.connectionState ==
ConnectionState.waiting) {
return const Center(
child: CircularProgressIndicator(),
);
}

if (!snapshot.hasData ||
snapshot.data!.docs.isEmpty) {
return const Center(
child: Text(
"No Announcements Available",
style: TextStyle(
fontSize: 16,
fontWeight: FontWeight.w500,
),
),
);
}

final announcements =
snapshot.data!.docs;

return ListView.builder(
padding: const EdgeInsets.all(16),

itemCount: announcements.length,

itemBuilder: (context, index) {

final doc =
announcements[index];

final data =
doc.data()
as Map<String, dynamic>;


final timestamp =
data['createdAt']
as Timestamp?;

final priority =
    data['priority'] ??
        'Normal';

final isPinned =
    data['isPinned'] ??
        false;

String formattedDate =
    "N/A";

if (timestamp != null) {
  final date =
  timestamp.toDate();

  formattedDate =
  "${date.day.toString().padLeft(2, '0')}/"
      "${date.month.toString().padLeft(2, '0')}/"
      "${date.year}";
}

return Card(
elevation: 4,
margin:
const EdgeInsets.only(
bottom: 12,
),
shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(
16,
),
),
child: Padding(
padding:
const EdgeInsets.all(
16,
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Row(
children: [
Icon(
isPinned
? Icons.push_pin
: Icons.campaign_rounded,
color: isPinned
? Colors.orange
: Colors.blue,
),

const SizedBox(
width: 8,
),

Expanded(
child: Text(
data['title'] ?? '',
style:
const TextStyle(
fontSize: 18,
fontWeight:
FontWeight.bold,
),
),
),

Container(
padding:
const EdgeInsets.symmetric(
horizontal: 10,
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
color:
Colors.white,
fontWeight:
FontWeight.bold,
fontSize: 11,
),
),
),
],
),

const SizedBox(
height: 12,
),

Text(
data['description'] ??
'',
style: TextStyle(
color: Colors
.grey.shade700,
fontSize: 15,
height: 1.4,
),
),

const SizedBox(
height: 15,
),

Row(
mainAxisAlignment:
MainAxisAlignment
.spaceBetween,
children: [
Text(
formattedDate,
style:
TextStyle(
color: Colors
.grey.shade600,
fontSize: 12,
),
),

if (isPinned)
Container(
padding:
const EdgeInsets.symmetric(
horizontal: 10,
vertical: 4,
),
decoration:
BoxDecoration(
color:
Colors.orange
.shade100,
borderRadius:
BorderRadius.circular(
20,
),
),
child: const Text(
"Pinned",
style:
TextStyle(
color:
Colors.orange,
fontWeight:
FontWeight.bold,
),
),
)
else
Container(
padding:
const EdgeInsets.symmetric(
horizontal: 10,
vertical: 4,
),
decoration:
BoxDecoration(
color:
Colors.green
.shade100,
borderRadius:
BorderRadius.circular(
20,
),
),
  child: const Text(
    "Latest",
    style: TextStyle(
      color: Colors.green,
      fontWeight: FontWeight.w600,
    ),
  ),
),
],
),
],
),
),
);
},
);
},
),
);
}
}