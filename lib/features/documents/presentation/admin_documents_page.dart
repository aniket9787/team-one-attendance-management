import 'package:flutter/material.dart';

import '../data/document_service.dart';
import '../domain/document_model.dart';

class AdminDocumentsPage extends StatefulWidget {
  const AdminDocumentsPage({super.key});

  @override
  State<AdminDocumentsPage> createState() =>
      _AdminDocumentsPageState();
}

class _AdminDocumentsPageState
    extends State<AdminDocumentsPage> {

final DocumentService documentService =
DocumentService();

final TextEditingController
searchController =
TextEditingController();

final TextEditingController
titleController =
TextEditingController();

final TextEditingController
descriptionController =
TextEditingController();

final TextEditingController
fileNameController =
TextEditingController();

final TextEditingController
fileUrlController =
TextEditingController();

final TextEditingController
uploadedByController =
TextEditingController();

final TextEditingController
fileSizeController =
TextEditingController();

String selectedCategory = "All";

String documentCategory =
"Company Policy";

final List<String> categories = [
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
searchController.dispose();
titleController.dispose();
descriptionController.dispose();
fileNameController.dispose();
fileUrlController.dispose();
uploadedByController.dispose();
fileSizeController.dispose();
super.dispose();
}

IconData getFileIcon(
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

Color getFileColor(
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

@override
Widget build(BuildContext context) {

return Scaffold(

backgroundColor:
const Color(0xffF5F7FA),

appBar: AppBar(
centerTitle: true,
title: const Text(
"Document Management",
),
),

floatingActionButton:
FloatingActionButton.extended(
onPressed: () {

//=========================
// PART 2 STARTS HERE



showDialog(
context: context,
builder: (_) {
return AlertDialog(
title: const Text(
"Upload Document",
),
content: SingleChildScrollView(
child: Column(
mainAxisSize:
MainAxisSize.min,
children: [

TextField(
controller:
titleController,
decoration:
const InputDecoration(
labelText:
"Document Title",
),
),

const SizedBox(
height: 12),

TextField(
controller:
descriptionController,
maxLines: 3,
decoration:
const InputDecoration(
labelText:
"Description",
),
),

const SizedBox(
height: 12),

DropdownButtonFormField<
String>(
value:
documentCategory,
decoration:
const InputDecoration(
labelText:
"Category",
),
items: categories
.where(
(e) =>
e != "All",
)
.map(
(e) =>
DropdownMenuItem(
value: e,
child:
Text(e),
),
)
.toList(),
onChanged:
(value) {
if (value ==
null) return;

setState(() {
documentCategory =
value;
});
},
),

const SizedBox(
height: 12),

TextField(
controller:
fileNameController,
decoration:
const InputDecoration(
labelText:
"File Name",
),
),

const SizedBox(
height: 12),

TextField(
controller:
fileUrlController,
decoration:
const InputDecoration(
labelText:
"File URL",
),
),

const SizedBox(
height: 12),

TextField(
controller:
fileSizeController,
keyboardType:
TextInputType.number,
decoration:
const InputDecoration(
labelText:
"File Size (Bytes)",
),
),

const SizedBox(
height: 12),

TextField(
controller:
uploadedByController,
decoration:
const InputDecoration(
labelText:
"Uploaded By",
),
),
],
),
),

actions: [

TextButton(
onPressed: () {
Navigator.pop(
context);
},
child:
const Text(
"Cancel",
),
),

ElevatedButton(
onPressed:
() async {

if (titleController.text
.trim()
.isEmpty ||
fileNameController
.text
.trim()
.isEmpty ||
fileUrlController
.text
.trim()
.isEmpty) {
ScaffoldMessenger.of(
context)
.showSnackBar(
const SnackBar(
content: Text(
"Please fill all required fields",
),
),
);
return;
}

await documentService
.addDocument(
title:
titleController
.text
.trim(),
description:
descriptionController
.text
.trim(),
category:
documentCategory,
fileName:
fileNameController
.text
.trim(),
fileUrl:
fileUrlController
.text
.trim(),
fileSize:
int.tryParse(
fileSizeController
.text,
) ??
0,
uploadedBy:
uploadedByController
.text
.trim()
.isEmpty
? "Admin"
: uploadedByController
.text
.trim(),
);

titleController.clear();
descriptionController
.clear();
fileNameController
.clear();
fileUrlController
.clear();
uploadedByController
.clear();
fileSizeController
.clear();

if (mounted) {
Navigator.pop(
context);

ScaffoldMessenger.of(
context)
.showSnackBar(
const SnackBar(
backgroundColor:
Colors.green,
content: Text(
"Document Uploaded Successfully",
),
),
);
}
},
child:
const Text(
"Upload",
),
),
],
);
},
);

},

icon: const Icon(
Icons.upload_file,
),

label: const Text(
"Upload",
),
),

body: Column(
children: [

Padding(
padding:
const EdgeInsets.all(
16),
child: FutureBuilder<int>(
future:
documentService
.totalDocuments(),
builder:
(context,
snapshot) {
return Card(
child: Padding(
padding:
const EdgeInsets
.all(
16),
child: Row(
children: [

const Icon(
Icons.folder,
size: 40,
color:
Colors.blue,
),

const SizedBox(
width:
15),

Column(
crossAxisAlignment:
CrossAxisAlignment
.start,
children: [

const Text(
"Total Documents",
style:
TextStyle(
fontWeight:
FontWeight.bold,
),
),

Text(
"${snapshot.data ?? 0}",
style:
const TextStyle(
fontSize:
24,
fontWeight:
FontWeight.bold,
),
),
],
),
],
),
),
);
},
),
),

Padding(
padding:
const EdgeInsets
.symmetric(
horizontal: 16,
),
child: TextField(
controller:
searchController,
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
12),
),
),
onChanged: (_) {
setState(() {});
},
),
),

const SizedBox(
height: 15),

Padding(
padding:
const EdgeInsets
.symmetric(
horizontal: 16,
),
child:
DropdownButtonFormField<
String>(
value:
selectedCategory,
decoration:
const InputDecoration(
labelText:
"Category",
),
items: categories
.map(
(category) =>
DropdownMenuItem(
value:
category,
child:
Text(
category,
),
),
)
.toList(),
onChanged:
(value) {
if (value ==
null) return;

setState(() {
selectedCategory =
value;
});
},
),
),

const SizedBox(
height: 15),

Expanded(
child:
StreamBuilder<
List<
DocumentModel>>(
stream:
documentService
.documentStream(),
builder: (
context,
snapshot,
) {

//=========================
// PART 3 STARTS HERE



  if (snapshot.connectionState ==
      ConnectionState.waiting) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  if (!snapshot.hasData ||
      snapshot.data!.isEmpty) {
    return const Center(
      child: Text(
        "No Documents Found",
      ),
    );
  }

  List<DocumentModel> documents =
  snapshot.data!;

// Search
  if (searchController.text
      .trim()
      .isNotEmpty) {
    final keyword =
    searchController.text
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

// Category Filter
  if (selectedCategory != "All") {
    documents = documents.where((doc) {
      return doc.category ==
          selectedCategory;
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
    const EdgeInsets.symmetric(
      horizontal: 16,
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
          bottom: 12,
        ),
        shape:
        RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(
            15,
          ),
        ),
        child: ListTile(

          leading: CircleAvatar(
            backgroundColor:
            getFileColor(
              document,
            ),
            child: Icon(
              getFileIcon(
                document,
              ),
              color: Colors.white,
            ),
          ),

          title: Text(
            document.title,
            style:
            const TextStyle(
              fontWeight:
              FontWeight.bold,
            ),
          ),

          subtitle: Column(
            crossAxisAlignment:
            CrossAxisAlignment
                .start,
            children: [

              const SizedBox(
                  height: 4),

              Text(
                document.description,
              ),

              const SizedBox(
                  height: 6),

              Wrap(
                spacing: 8,
                children: [

                  Chip(
                    label: Text(
                      document.category,
                    ),
                  ),

                  Chip(
                    label: Text(
                      document.formattedSize,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                  height: 6),

              Text(
                "Uploaded : ${document.formattedDate}",
              ),
            ],
          ),

          trailing:
          PopupMenuButton<String>(
            onSelected:
                (value) async {

              if (value ==
                  "delete") {

                final confirm =
                await showDialog<bool>(
                  context:
                  context,
                  builder:
                      (_) =>
                      AlertDialog(
                        title:
                        const Text(
                          "Delete Document",
                        ),

                        content:
                        const Text(
                          "Are you sure you want to delete this document?",
                        ),

                        actions: [

                          TextButton(
                            onPressed:
                                () {
                              Navigator.pop(
                                context,
                                false,
                              );
                            },
                            child:
                            const Text(
                              "Cancel",
                            ),
                          ),

                          ElevatedButton(
                            onPressed:
                                () {
                              Navigator.pop(
                                context,
                                true,
                              );
                            },
                            child:
                            const Text(
                              "Delete",
                            ),
                          ),
                        ],
                      ),
                );

                if (confirm ==
                    true) {

                  await documentService
                      .deleteDocument(
                    document.id,
                  );

                  if (!mounted)
                    return;

                  ScaffoldMessenger.of(
                      context)
                      .showSnackBar(
                    const SnackBar(
                      backgroundColor:
                      Colors.red,
                      content: Text(
                        "Document Deleted",
                      ),
                    ),
                  );
                }
              }

              if (value ==
                  "edit") {

                titleController.text =
                    document.title;

                descriptionController
                    .text =
                    document.description;

                setState(() {
                  documentCategory =
                      document.category;
                });

                showDialog(
                  context:
                  context,
                  builder: (_) =>
                      AlertDialog(
                        title:
                        const Text(
                          "Edit Document",
                        ),

                        content:
                        Column(
                          mainAxisSize:
                          MainAxisSize.min,
                          children: [

                            TextField(
                              controller:
                              titleController,
                              decoration:
                              const InputDecoration(
                                labelText:
                                "Title",
                              ),
                            ),

                            const SizedBox(
                                height:
                                12),

                            TextField(
                              controller:
                              descriptionController,
                              decoration:
                              const InputDecoration(
                                labelText:
                                "Description",
                              ),
                            ),
                          ],
                        ),

                        actions: [

                          TextButton(
                            onPressed:
                                () {
                              Navigator.pop(
                                  context);
                            },
                            child:
                            const Text(
                              "Cancel",
                            ),
                          ),

                          ElevatedButton(
                            onPressed:
                                () async {

                              await documentService
                                  .updateDocument(
                                id:
                                document.id,
                                title:
                                titleController
                                    .text,
                                description:
                                descriptionController
                                    .text,
                                category:
                                documentCategory,
                              );

                              if (mounted) {
                                Navigator.pop(
                                    context);
                              }
                            },
                            child:
                            const Text(
                              "Save",
                            ),
                          ),
                        ],
                      ),
                );
              }
            },

            itemBuilder:
                (context) => [

              const PopupMenuItem(
                value: "edit",
                child: Row(
                  children: [

                    Icon(
                      Icons.edit,
                    ),

                    SizedBox(
                        width: 8),

                    Text(
                      "Edit",
                    ),
                  ],
                ),
              ),

              const PopupMenuItem(
                value:
                "delete",
                child: Row(
                  children: [

                    Icon(
                      Icons.delete,
                      color:
                      Colors.red,
                    ),

                    SizedBox(
                        width: 8),

                    Text(
                      "Delete",
                    ),
                  ],
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