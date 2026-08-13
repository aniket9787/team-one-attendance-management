import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/document_service.dart';
import '../domain/document_model.dart';

class EmployeeDocumentsPage extends StatefulWidget {
  const EmployeeDocumentsPage({super.key});

  @override
  State<EmployeeDocumentsPage> createState() =>
      _EmployeeDocumentsPageState();
}

class _EmployeeDocumentsPageState
    extends State<EmployeeDocumentsPage> {

final DocumentService _documentService =
DocumentService();

final TextEditingController
_searchController =
TextEditingController();

String _selectedCategory = "All";

final List<String> _categories = const [
"All",
"Company Policy",
"Offer Letter",
"Appointment Letter",
"Salary Slip",
"ID Card",
"Certificate",
"HR Form",
"General",
];

@override
void dispose() {
_searchController.dispose();
super.dispose();
}

IconData _getFileIcon(
DocumentModel document) {
if (document.isPdf) {
return Icons.picture_as_pdf;
}

if (document.isWord) {
return Icons.description;
}

if (document.isExcel) {
return Icons.table_chart;
}

if (document.isPowerPoint) {
return Icons.slideshow;
}

if (document.isImage) {
return Icons.image;
}

return Icons.insert_drive_file;
}

Color _getFileColor(
DocumentModel document) {
if (document.isPdf) {
return Colors.red;
}

if (document.isWord) {
return Colors.blue;
}

if (document.isExcel) {
return Colors.green;
}

if (document.isPowerPoint) {
return Colors.orange;
}

if (document.isImage) {
return Colors.purple;
}

return Colors.grey;
}

Future<void> _openDocument(
String url) async {
final uri = Uri.parse(url);

if (await canLaunchUrl(uri)) {
await launchUrl(
uri,
mode:
LaunchMode.externalApplication,
);
} else {
if (!mounted) return;

ScaffoldMessenger.of(context)
.showSnackBar(
const SnackBar(
content:
Text("Unable to open file"),
),
);
}
}

@override
Widget build(BuildContext context) {
return Scaffold(

backgroundColor:
const Color(0xffF5F7FA),

appBar: AppBar(
centerTitle: true,
title: const Text(
"Company Documents",
),
),

body: Column(
children: [

Container(
width: double.infinity,
margin:
const EdgeInsets.all(16),
padding:
const EdgeInsets.all(20),
decoration: BoxDecoration(
gradient:
const LinearGradient(
colors: [
Color(0xff2563EB),
Color(0xff1D4ED8),
],
),
borderRadius:
BorderRadius.circular(18),
),
child: const Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [

Text(
"Employee Documents",
style: TextStyle(
color: Colors.white,
fontSize: 24,
fontWeight:
FontWeight.bold,
),
),

SizedBox(height: 8),

Text(
"Access company policies, offer letters, salary slips and other important documents.",
style: TextStyle(
color:
Colors.white70,
),
),
],
),
),

Padding(
padding:
const EdgeInsets.symmetric(
horizontal: 16,
),
child: TextField(
controller:
_searchController,
decoration:
InputDecoration(
hintText:
"Search Documents",
prefixIcon:
const Icon(
Icons.search,
),
border:
OutlineInputBorder(
borderRadius:
BorderRadius.circular(
12,
),
),
),
onChanged: (_) {
setState(() {});
},
),
),

const SizedBox(height: 15),

Padding(
padding:
const EdgeInsets.symmetric(
horizontal: 16,
),
child:
DropdownButtonFormField<
String>(
value:
_selectedCategory,
decoration:
const InputDecoration(
labelText:
"Category",
),
items: _categories
.map(
(category) =>
DropdownMenuItem(
value: category,
child:
Text(category),
),
)
.toList(),
onChanged:
(value) {
if (value == null)
return;

setState(() {
_selectedCategory =
value;
});
},
),
),

const SizedBox(height: 15),

Expanded(
child:
StreamBuilder<
List<DocumentModel>>(
stream:
_documentService
.documentStream(),
builder:
(context, snapshot) {

// ===============================
// PART 2 STARTS HERE

if (snapshot.connectionState ==
ConnectionState.waiting) {
return const Center(
child: CircularProgressIndicator(),
);
}

if (snapshot.hasError) {
return Center(
child: Text(
snapshot.error.toString(),
),
);
}

if (!snapshot.hasData ||
snapshot.data!.isEmpty) {
return const Center(
child: Column(
mainAxisAlignment:
MainAxisAlignment.center,
children: [
Icon(
Icons.folder_open,
size: 80,
color: Colors.grey,
),
SizedBox(height: 15),
Text(
"No Documents Available",
style: TextStyle(
fontSize: 18,
fontWeight:
FontWeight.bold,
),
),
],
),
);
}

List<DocumentModel> documents =
snapshot.data!;

//============================
// SEARCH FILTER
//============================

if (_searchController.text
.trim()
.isNotEmpty) {
final keyword =
_searchController.text
.toLowerCase();

documents = documents.where((doc) {
return doc.title
.toLowerCase()
.contains(keyword) ||
doc.description
.toLowerCase()
.contains(keyword) ||
doc.category
.toLowerCase()
.contains(keyword) ||
doc.fileName
.toLowerCase()
.contains(keyword);
}).toList();
}

//============================
// CATEGORY FILTER
//============================

if (_selectedCategory != "All") {
documents = documents.where((doc) {
return doc.category ==
_selectedCategory;
}).toList();
}

if (documents.isEmpty) {
return const Center(
child: Text(
"No Matching Documents",
),
);
}

return ListView.builder(
padding:
const EdgeInsets.only(
left: 16,
right: 16,
bottom: 16,
),
itemCount: documents.length,
itemBuilder:
(context, index) {

final document =
documents[index];

return Card(
elevation: 3,
margin:
const EdgeInsets.only(
bottom: 14,
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
CrossAxisAlignment
.start,
children: [

Row(
children: [

CircleAvatar(
radius: 28,
backgroundColor:
_getFileColor(
document,
),
child: Icon(
_getFileIcon(
document,
),
color:
Colors.white,
size: 28,
),
),

const SizedBox(
width: 16),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment
.start,
children: [

Text(
document.title,
style:
const TextStyle(
fontSize: 17,
fontWeight:
FontWeight.bold,
),
),

const SizedBox(
height: 5),

Text(
document.description,
style:
TextStyle(
color: Colors
.grey
.shade700,
),
),
],
),
),
],
),

const SizedBox(height: 15),

Wrap(
spacing: 8,
runSpacing: 8,
children: [

Chip(
avatar: const Icon(
Icons.folder,
size: 18,
),
label: Text(
document.category,
),
),

Chip(
avatar: const Icon(
Icons.storage,
size: 18,
),
label: Text(
document.formattedSize,
),
),

if (document.isPdf)
const Chip(
label: Text("PDF"),
),

if (document.isWord)
const Chip(
label: Text("WORD"),
),

if (document.isExcel)
const Chip(
label: Text("EXCEL"),
),

if (document.isImage)
const Chip(
label: Text("IMAGE"),
),
],
),

const SizedBox(height: 15),

//============================
// PART 3 STARTS HERE

  Row(
    children: [
      const Icon(
        Icons.calendar_today,
        size: 16,
        color: Colors.blue,
      ),

      const SizedBox(width: 6),

      Text(
        document.formattedDate,
        style: TextStyle(
          color: Colors.grey.shade700,
        ),
      ),

      const Spacer(),

      const Icon(
        Icons.person,
        size: 16,
        color: Colors.green,
      ),

      const SizedBox(width: 6),

      Flexible(
        child: Text(
          document.uploadedBy,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.grey.shade700,
          ),
        ),
      ),
    ],
  ),

  const SizedBox(height: 10),

  Row(
    children: [

      const Icon(
        Icons.insert_drive_file,
        size: 16,
        color: Colors.deepPurple,
      ),

      const SizedBox(width: 6),

      Expanded(
        child: Text(
          document.fileName,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ],
  ),

  const SizedBox(height: 18),

  SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      icon: const Icon(
        Icons.download,
      ),
      label: const Text(
        "Open / Download Document",
      ),
      onPressed: () {
        _openDocument(
          document.fileUrl,
        );
      },
    ),
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
],
),
);
}
}